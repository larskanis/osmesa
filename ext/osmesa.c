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
  return self;
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

  rb_cContext = rb_define_class_under( rb_mOSMesa, "Context", rb_cObject );
  rb_define_alloc_func( rb_cContext, alloc_Context );
  rb_define_method( rb_cContext, "initialize", CreateContext, 2 );
  rb_define_method( rb_cContext, "Destroy", DestroyContext, 0 );
}
