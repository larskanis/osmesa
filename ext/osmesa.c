#include <ruby.h>
#include <GL/osmesa.h>

static VALUE rb_mOSMesa;
static VALUE rb_cContext;

static void
gc_free_Context( OSMesaContext ctx )
{
  if( ctx )
    OSMesaDestroyContext( ctx );
}

static VALUE
alloc_Context( VALUE klass )
{
  return Data_Wrap_Struct( klass, NULL, gc_free_Context, NULL );
}

static OSMesaContext
get_Context( VALUE self )
{
  OSMesaContext ctx = DATA_PTR(self);
  if( !ctx )
    rb_raise(rb_eTypeError, "%s is already destroyed", rb_obj_classname(self));
  return ctx;
}

/*
 * Destroy an Off-Screen Mesa rendering context.
 *
 * Input:  ctx - the context to destroy
 */
static VALUE
DestroyContext( VALUE self )
{
  OSMesaDestroyContext( get_Context(self) );
  DATA_PTR(self) = NULL;
  return Qnil;
}

/*
 * Create an Off-Screen Mesa rendering context.  The only attribute needed is
 * an RGBA vs Color-Index mode flag.
 *
 * Input:  format - one of OSMESA_COLOR_INDEX, OSMESA_RGBA, OSMESA_BGRA,
 *                  OSMESA_ARGB, OSMESA_RGB, or OSMESA_BGR.
 *         sharelist - specifies another OSMesaContext with which to share
 *                     display lists.  NULL indicates no sharing.
 * Return:  an OSMesaContext or 0 if error
 */
static VALUE
CreateContext( VALUE self, VALUE format, VALUE sharelist )
{
  OSMesaContext slist = NIL_P(sharelist) ? NULL : get_Context(sharelist);

  OSMesaContext ctx = OSMesaCreateContext( NUM2INT(format), slist );
  if( !ctx )
    rb_raise(rb_eTypeError, "Error in OSMesaCreateContext");
  DATA_PTR(self) = ctx;
  rb_iv_set(self, "@format", format);
  return self;
}


/*
 * Bind an OSMesaContext to an image buffer.  The image buffer is just a
 * block of memory which the client provides.  Its size must be at least
 * as large as width*height*sizeof(type).  Its address should be a multiple
 * of 4 if using RGBA mode.
 *
 * Image data is stored in the order of glDrawPixels:  row-major order
 * with the lower-left image pixel stored in the first array position
 * (ie. bottom-to-top).
 *
 * Since the only type initially supported is GL_UNSIGNED_BYTE, if the
 * context is in RGBA mode, each pixel will be stored as a 4-byte RGBA
 * value.  If the context is in color indexed mode, each pixel will be
 * stored as a 1-byte value.
 *
 * If the context's viewport hasn't been initialized yet, it will now be
 * initialized to (0,0,width,height).
 *
 * Input:  ctx - the rendering context
 *         buffer - the image buffer memory
 *         type - data type for pixel components, only GL_UNSIGNED_BYTE
 *                supported now
 *         width, height - size of image buffer in pixels, at least 1
 * Return:  GL_TRUE if success, GL_FALSE if error because of invalid ctx,
 *          invalid buffer address, type!=GL_UNSIGNED_BYTE, width<1, height<1,
 *          width>internal limit or height>internal limit.
 */
static VALUE
MakeCurrent( VALUE self, VALUE string_buffer, VALUE type, VALUE width, VALUE height )
{
  OSMesaContext ctx = get_Context(self);
  GLenum gltype = NUM2INT(type);
  GLsizei glwidth = NUM2UINT(width);
  GLsizei glheight = NUM2UINT(height);
  GLboolean res;
  GLint format;
  long int size, pixsize;

  StringValue(string_buffer);

  format = NUM2INT(rb_iv_get(self, "@format"));
  switch( format ){
    case OSMESA_RGBA   : pixsize = 4; break;
    case OSMESA_BGRA   : pixsize = 4; break;
    case OSMESA_ARGB   : pixsize = 4; break;
    case OSMESA_RGB    : pixsize = 3; break;
    case OSMESA_BGR    : pixsize = 3; break;
    case OSMESA_RGB_565: pixsize = 2; break;
    default: pixsize = 4;
  }
  switch( gltype ){
    case GL_UNSIGNED_BYTE:  size = (long int)glwidth * glheight * sizeof(GLubyte)  * pixsize; break;
    case GL_UNSIGNED_SHORT: size = (long int)glwidth * glheight * sizeof(GLushort) * pixsize; break;
    default :               size = (long int)glwidth * glheight * sizeof(GLfloat)  * pixsize; break;
  }
  rb_str_modify(string_buffer);
  if( RSTRING_LEN(string_buffer) < size )
    rb_raise(rb_eArgError, "String buffer is too small: %ld < %ld", RSTRING_LEN(string_buffer), size);

  res = OSMesaMakeCurrent( ctx, RSTRING_PTR(string_buffer), gltype, glwidth, glheight );
  if( res != GL_TRUE )
    rb_raise(rb_eArgError, "Error in OSMesaMakeCurrent");

  return Qnil;
}

/*
 * Return an integer value like glGetIntegerv.
 * Input:  pname -
 *                 OSMESA_WIDTH  return current image width
 *                 OSMESA_HEIGHT  return current image height
 *                 OSMESA_FORMAT  return image format
 *                 OSMESA_TYPE  return color component data type
 *                 OSMESA_ROW_LENGTH return row length in pixels
 *                 OSMESA_Y_UP returns 1 or 0 to indicate Y axis direction
 *         value - pointer to integer in which to return result.
 */
static VALUE
GetIntegerv( VALUE self, VALUE pname )
{
  GLint value;
  OSMesaGetIntegerv( NUM2INT(pname), &value);
  return INT2NUM(value);
}


void
Init_osmesa_ext()
{
  rb_mOSMesa = rb_define_module( "OSMesa" );

  rb_define_const(rb_mOSMesa, "MAJOR_VERSION", INT2FIX(OSMESA_MAJOR_VERSION));
  rb_define_const(rb_mOSMesa, "MINOR_VERSION", INT2FIX(OSMESA_MINOR_VERSION));
  rb_define_const(rb_mOSMesa, "PATCH_VERSION", INT2FIX(OSMESA_PATCH_VERSION));

  /*
   * Values for the format parameter of OSMesaCreateContext()
   * New in version 2.0.
   */
  rb_define_const(rb_mOSMesa, "COLOR_INDEX", INT2FIX(OSMESA_COLOR_INDEX));
  rb_define_const(rb_mOSMesa, "RGBA", INT2FIX(OSMESA_RGBA));
  rb_define_const(rb_mOSMesa, "BGRA", INT2FIX(OSMESA_BGRA));
  rb_define_const(rb_mOSMesa, "ARGB", INT2FIX(OSMESA_ARGB));
  rb_define_const(rb_mOSMesa, "RGB", INT2FIX(OSMESA_RGB));
  rb_define_const(rb_mOSMesa, "BGR", INT2FIX(OSMESA_BGR));
  rb_define_const(rb_mOSMesa, "RGB_565", INT2FIX(OSMESA_RGB_565));

  /*
   * OSMesaPixelStore() parameters:
   * New in version 2.0.
   */
  rb_define_const(rb_mOSMesa, "OSMESA_ROW_LENGTH", INT2FIX(OSMESA_ROW_LENGTH));
  rb_define_const(rb_mOSMesa, "OSMESA_Y_UP", INT2FIX(OSMESA_Y_UP));

  /*
   * Accepted by OSMesaGetIntegerv:
   */
  rb_define_const(rb_mOSMesa, "OSMESA_WIDTH", INT2FIX(OSMESA_WIDTH));
  rb_define_const(rb_mOSMesa, "OSMESA_HEIGHT", INT2FIX(OSMESA_HEIGHT));
  rb_define_const(rb_mOSMesa, "OSMESA_FORMAT", INT2FIX(OSMESA_FORMAT));
  rb_define_const(rb_mOSMesa, "OSMESA_TYPE", INT2FIX(OSMESA_TYPE));
  rb_define_const(rb_mOSMesa, "OSMESA_MAX_WIDTH", INT2FIX(OSMESA_MAX_WIDTH));
  rb_define_const(rb_mOSMesa, "OSMESA_MAX_HEIGHT", INT2FIX(OSMESA_MAX_HEIGHT));

  rb_define_singleton_method( rb_mOSMesa, "GetIntegerv", GetIntegerv, 1 );

  rb_cContext = rb_define_class_under( rb_mOSMesa, "Context", rb_cObject );
  rb_define_alloc_func( rb_cContext, alloc_Context );
  rb_define_method( rb_cContext, "initialize", CreateContext, 2 );
  rb_define_method( rb_cContext, "Destroy", DestroyContext, 0 );
  rb_define_method( rb_cContext, "MakeCurrent", MakeCurrent, 4 );
}
