#include <ruby.h>
#include <GL/osmesa.h>

VALUE rb_mOSMesa;

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

}
