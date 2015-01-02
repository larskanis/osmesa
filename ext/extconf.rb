require 'mkmf'

if enable_config('win32-cross')
  require "mini_portile"

  LIBOSMESA_VERSION = ENV['LIBOSMESA_VERSION'] || '10.4.1'
  LIBOSMESA_SOURCE_URI = "ftp://ftp.freedesktop.org/pub/mesa/#{LIBOSMESA_VERSION}/MesaLib-#{LIBOSMESA_VERSION}.tar.bz2"

  recipe = MiniPortile.new("libosmesa", LIBOSMESA_VERSION)
  recipe.files = [LIBOSMESA_SOURCE_URI]
  recipe.target = portsdir = File.expand_path('../../ports', __FILE__)
  # Prefer host_alias over host in order to use i586-mingw32msvc as
  # correct compiler prefix for cross build, but use host if not set.
  recipe.host = RbConfig::CONFIG["host_alias"].empty? ? RbConfig::CONFIG["host"] : RbConfig::CONFIG["host_alias"]
  recipe.configure_options = [
    "--disable-xvmc",
    "--disable-glx",
    "--disable-dri",
    "--disable-shared-glapi",
    "--disable-egl",
    "--with-dri-drivers=''",
    "--with-egl-platforms=''",
#     "--with-gallium-drivers='swrast'",
#     "--with-llvm-shared-libs",
#     "--enable-gallium-osmesa",
#     "--enable-gallium-llvm=yes",
    "--with-gallium-drivers=''",
    "--enable-osmesa",
    "--enable-gallium-llvm=no",
    "--enable-texture-float",
    "--enable-static",
    "--target=#{recipe.host}",
    "--host=#{recipe.host}",
  ]

  checkpoint = File.join(portsdir, "#{recipe.name}-#{recipe.version}-#{recipe.host}.installed")
  unless File.exist?(checkpoint)
    ENV['PKG_CONFIG'] = 'not_avail'
    ENV['CPPFLAGS'] = '-DBUILD_GL32 -D_GLAPI_NO_EXPORTS'
    recipe.cook
    FileUtils.touch checkpoint
  end
  recipe.activate
  dir_config('gl', "#{recipe.path}/include", "#{recipe.path}/lib")

  CONFIG['CC'] = "#{RbConfig::CONFIG["host"]}-g++" # Hack CXX into Makefile for cross compilation
  CONFIG['LDSHARED'].gsub!('gcc', 'g++') # ensure C++ linker is used, so that libstdc++ is linked static
  $CPPFLAGS << "-DBUILD_GL32 "

  WIN32_SHARED_DLLS = %w[libwinpthread-1.dll libgcc_s_sjlj-1.dll libstdc++-6.dll]
  WIN32_SHARED_DLLS.each do |dll|
    cmd = "#{CONFIG['CC']} -print-file-name=#{dll}"
    puts cmd
    FileUtils.cp `#{cmd}`.chomp, '.', verbose: true
  end
else
  dir_config 'gl'
end

find_header( 'GL/osmesa.h' ) or
    abort "Can't find the 'GL/osmesa.h' header"

$libs = append_library($libs, "OSMesa")

# have_library( 'OSMesa', 'OSMesaCreateContext', ['GL/osmesa.h'] ) or
#     abort "Can't find the OSMesa library (libOSMesa)"

create_makefile( "osmesa_ext" )
