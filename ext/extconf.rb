require 'mkmf'
require 'fileutils'

if enable_config('win32-cross')
  require "mini_portile"

  LIBOSMESA_VERSION = ENV['LIBOSMESA_VERSION'] || '10.4.2'
  LIBOSMESA_SOURCE_URI = "ftp://ftp.freedesktop.org/pub/mesa/#{LIBOSMESA_VERSION}/MesaLib-#{LIBOSMESA_VERSION}.tar.bz2"

  LLVM_VERSION = ENV['LLVM_VERSION'] || '3.5.1'
  LLVM_SOURCE_URI = "http://llvm.org/releases/#{LLVM_VERSION}/llvm-#{LLVM_VERSION}.src.tar.xz"

  host = RbConfig::CONFIG["host_alias"].empty? ? RbConfig::CONFIG["host"] : RbConfig::CONFIG["host_alias"]
  # i586-mingw32msvc is too old to build llvm
  host = 'i686-w64-mingw32' if host == 'i586-mingw32msvc'

  llvmrecipe = MiniPortile.new("llvm", LLVM_VERSION)
  llvmrecipe.files = [LLVM_SOURCE_URI]
  llvmrecipe.target = portsdir = File.expand_path('../../ports', __FILE__)
  llvmrecipe.host = host
  llvmrecipe.configure_options = [
    "-C",
    "--enable-optimized",
    "--disable-assertions",
    "--enable-targets=#{ llvmrecipe.host=~/^x86_64/ ? 'x86_64' : 'x86' }",
    "--enable-bindings=none",
    "--disable-libffi",
    "--host=#{llvmrecipe.host}",
    ]
  class << llvmrecipe
    def compile
      Dir.chdir(work_path) do
        FileUtils.rm "include/llvm/Config/config.h", verbose: true
      end
      super
    end
  end

  checkpoint = File.join(portsdir, "#{llvmrecipe.name}-#{llvmrecipe.version}-#{llvmrecipe.host}.installed")
  unless File.exist?(checkpoint)
    ENV['LDFLAGS'] = '-static'
    llvmrecipe.cook
    FileUtils.touch checkpoint
  end
  llvmrecipe.activate


  recipe = MiniPortile.new("libosmesa", LIBOSMESA_VERSION)
  recipe.files = [LIBOSMESA_SOURCE_URI]
  recipe.target = portsdir = File.expand_path('../../ports', __FILE__)
  recipe.host = host
  recipe.configure_options = [
    "--disable-xvmc",
    "--disable-glx",
    "--disable-dri",
    "--disable-egl",
    "--with-dri-drivers='swrast'",
    "--with-egl-platforms=''",
    "--with-gallium-drivers='swrast'",
    "--enable-gallium-osmesa",
    "--enable-gallium-llvm",
#     "--with-gallium-drivers=''",
#     "--enable-osmesa",
#     "--enable-gallium-llvm=no",
    "--enable-texture-float",
    "--enable-shared",
    "--enable-shared-glapi",
    "--target=#{recipe.host}",
    "--host=#{recipe.host}",
    "--with-llvm-prefix=#{llvmrecipe.path}",
  ]

  checkpoint = File.join(portsdir, "#{recipe.name}-#{recipe.version}-#{recipe.host}.installed")
  unless File.exist?(checkpoint)
    ENV['PKG_CONFIG'] = 'not_avail'
    ENV['CPPFLAGS'] = "-D_GLAPI_DLL_EXPORTS -DBUILD_GL32"
    ENV['LDFLAGS'] = "-lws2_32 -Wl,--add-stdcall-alias"
    recipe.cook
    FileUtils.touch checkpoint
  end
  recipe.activate


  dir_config('gl', "#{recipe.path}/include", "#{recipe.path}/lib")

  MESA_SHARED_DLLS = %w[lib/libOSMesa-8.dll bin/libglapi-0.dll]
  MESA_SHARED_DLLS.each do |dll|
    FileUtils.cp "#{recipe.path}/#{dll}", '.', verbose: true
  end

  GCC_SHARED_DLLS = %w[libwinpthread-1.dll libgcc_s_dw2-1.dll libgcc_s_sjlj-1.dll libgcc_s_seh-1.dll libstdc++-6.dll]
  GCC_SHARED_DLLS.each do |dll|
    cmd = "#{CONFIG['CC']} -print-file-name=#{dll}"
    res = `#{cmd}`.chomp
    next if dll == res
    puts "#{cmd} => #{res}"
    FileUtils.cp `#{cmd}`.chomp, '.', verbose: true
  end
else
  dir_config 'gl'
end

find_header( 'GL/osmesa.h' ) or
    abort "Can't find the 'GL/osmesa.h' header"

have_library( 'OSMesa', 'OSMesaCreateContext', ['GL/osmesa.h'] ) or
    abort "Can't find the OSMesa library (libOSMesa)"

create_header
create_makefile( "osmesa_ext" )
