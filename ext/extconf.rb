require 'mkmf'

dir_config 'gl'

find_header( 'GL/osmesa.h' ) or
    abort "Can't find the 'GL/osmesa.h' header"

have_library( 'OSMesa', 'OSMesaCreateContext', ['GL/osmesa.h'] ) or
    abort "Can't find the OSMesa library (libOSMesa)"

create_makefile( "osmesa_ext" )
