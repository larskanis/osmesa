require 'mkmf'
require 'fileutils'

if enable_config('cross')
  require "mini_portile2"

  LIBOSMESA_VERSION = ENV['LIBOSMESA_VERSION'] || '25.1.8'
  LIBOSMESA_SOURCE_URI = "https://archive.mesa3d.org/mesa-#{LIBOSMESA_VERSION}.tar.xz"

  LLVM_VERSION = ENV['LLVM_VERSION'] || '20.1.8'
  LLVM_SOURCE_URI = "https://github.com/llvm/llvm-project/releases/download/llvmorg-#{LLVM_VERSION}/llvm-#{LLVM_VERSION}.src.tar.xz"

  class MesaRecipe < MiniPortileCMake
    ROOT = File.expand_path("../..", __FILE__)

    def initialize(name, vers, url, sha1)
      super(name, vers)
      self.target = File.join(ROOT, "ports")
      self.files = [url: url, sha1: sha1]
    end

    def port_path
      "#{target}/#{RUBY_PLATFORM}"
    end

    def cook_and_activate
      checkpoint = File.join(target, "#{name}-#{version}-#{RUBY_PLATFORM}.installed")
      unless File.exist?(checkpoint)
        cook
        FileUtils.touch checkpoint
      end
      activate
      self
    end
  end

  # llvmrecipe = MesaRecipe.new("llvm", LLVM_VERSION, LLVM_SOURCE_URI, nil)
  # llvmrecipe.configure_options = [
  #   ]
  #   # "-C",
  #   # "--enable-optimized",
  #   # "--disable-assertions",
  #   # "--enable-targets=#{ llvmrecipe.host=~/^x86_64/ ? 'x86_64' : 'x86' }",
  #   # "--enable-bindings=none",
  #   # "--disable-libffi",
  #   # "--host=#{llvmrecipe.host}",
  #   # ]
  # llvmrecipe.cook_and_activate


  recipe = MesaRecipe.new("libosmesa", LIBOSMESA_VERSION, LIBOSMESA_SOURCE_URI, nil)
  recipe.configure_options = [
    ]

#     "--disable-xvmc",
#     "--disable-glx",
#     "--disable-dri",
#     "--disable-egl",
#     "--with-dri-drivers='swrast'",
#     "--with-egl-platforms=''",
#     "--with-gallium-drivers='swrast'",
#     "--enable-gallium-osmesa",
#     "--enable-gallium-llvm",
# #     "--with-gallium-drivers=''",
# #     "--enable-osmesa",
# #     "--enable-gallium-llvm=no",
#     "--enable-texture-float",
#     "--enable-shared",
#     "--enable-shared-glapi",
#     "--target=#{recipe.host}",
#     "--host=#{recipe.host}",
#     "--with-llvm-prefix=#{llvmrecipe.path}",
#   ]

    # ENV['CPPFLAGS'] = "-D_GLAPI_DLL_EXPORTS -DBUILD_GL32"
    # ENV['LDFLAGS'] = "-lws2_32 -Wl,--add-stdcall-alias"
  recipe.cook_and_activate


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
