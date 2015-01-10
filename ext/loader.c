#include "common.h"
#include <GL/osmesa.h>

void *load_gl_function(const char *name, int raise)
{
        void *func_ptr = OSMesaGetProcAddress(name);

        if (func_ptr == NULL && raise == 1)
                rb_raise(rb_eNotImpError,"Function %s is not available in OSMesa", name);

        return func_ptr;
}
