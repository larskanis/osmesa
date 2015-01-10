require "bundler/gem_tasks"
require 'rake/extensiontask'

task gem: :build

task :test=>:compile do
  sh "ruby -w -W2 -I. -Ilib -e \"#{Dir["test/test_*.rb"].map{|f| "require '#{f}';"}.join}\" -- -v"
end

OPENGL_FILES = %w[
  common.h
  conv.h
  funcdef.h
  gl-1.0-1.1.c
  gl-1.2.c
  gl-1.3.c
  gl-1.4.c
  gl-1.5.c
  gl-2.0.c
  gl-2.1.c
  gl-3.0.c
  gl_buffer.c
  gl.c
  gl-enums.c
  gl-enums.h
  gl-error.c
  gl-error.h
  gl-ext-3dfx.c
  gl-ext-arb.c
  gl-ext-ati.c
  gl-ext-ext.c
  gl-ext-gremedy.c
  gl-ext-nv.c
  gl-types.h
]

spec = Gem::Specification.load('osmesa.gemspec')
spec.files += OPENGL_FILES.map{|f| "ext/#{f}" }

class OSMesaExtensionTask < Rake::ExtensionTask
  def source_files
    `git ls-files -z`.split("\x0") + OPENGL_FILES.map{|f| "ext/#{f}" }
  end
end

# Rake-compiler task
OSMesaExtensionTask.new do |ext|
  ext.name           = 'osmesa_ext'
  ext.gem_spec       = spec
  ext.ext_dir        = 'ext'
  ext.lib_dir        = 'lib'
  ext.source_pattern = "*.{c,h}"

  ext.cross_compile = true
  ext.cross_platform = ['x86-mingw32', 'x64-mingw32']
  ext.cross_config_options += [
    "--enable-win32-cross",
  ]

  # Add dependent DLLs to the cross gems
  ext.cross_compiling do |spec|
    plat = spec.platform
    dlls = Dir["tmp/#{plat}/#{ext.name}/*/*.dll"].map{|dll| File.basename(dll) }.uniq
    spec.files += dlls.map{|dll| "lib/#{plat}/#{dll}" }

    directory "tmp/#{plat}/stage/lib/#{plat}/"
    dlls.each do |dll|
      ENV['RUBY_CC_VERSION'].to_s.split(':').each do |ruby_version|
        file "tmp/#{plat}/stage/lib/#{plat}/#{dll}" => ["tmp/#{plat}/stage/lib/#{plat}/", "tmp/#{plat}/#{ext.name}/#{ruby_version}/#{dll}"] do
          cp "tmp/#{plat}/#{ext.name}/#{ruby_version}/#{dll}", "tmp/#{plat}/stage/lib/#{plat}"
          sh "x86_64-w64-mingw32-strip", "tmp/#{plat}/stage/lib/#{plat}/#{dll}"
        end
      end
      file "lib/#{plat}/#{dll}" => "tmp/#{plat}/stage/lib/#{plat}/#{dll}"
    end
  end
end

# To reduce the gem file size strip mingw32 dlls before packaging
ENV['RUBY_CC_VERSION'].to_s.split(':').each do |ruby_version|
  task "tmp/x86-mingw32/stage/lib/#{ruby_version[/^\d+\.\d+/]}/osmesa_ext.so" do |t|
    sh "i686-w64-mingw32-strip -S tmp/x86-mingw32/stage/lib/#{ruby_version[/^\d+\.\d+/]}/osmesa_ext.so"
  end

  task "tmp/x64-mingw32/stage/lib/#{ruby_version[/^\d+\.\d+/]}/osmesa_ext.so" do |t|
    sh "x86_64-w64-mingw32-strip -S tmp/x64-mingw32/stage/lib/#{ruby_version[/^\d+\.\d+/]}/osmesa_ext.so"
  end
end

file "ext/extconf.rb" => OPENGL_FILES.map{|f| "ext/#{f}" }

OPENGL_FILES.each do |f|
  file "ext/#{f}" => "opengl/ext/opengl/#{f}" do |t|
    cp t.prerequisites[0], t.name
  end

  directory "opengl"
  file "opengl/ext/opengl/#{f}" => "opengl" do
    url = ENV['OPENGL_GIT_URL'] || 'http://github.com/larskanis/opengl'

    sh "git clone #{url.inspect} opengl"
  end
end

# Add opengl-files to gitignore
file '.gitignore' => OPENGL_FILES.map{|f| "ext/#{f}" } do |t|
  t.prerequisites.each do |pr|
    unless IO.readlines('.gitignore').map(&:chomp).include?(pr)
      File.open('.gitignore', 'a+'){|fd| fd.puts pr }
    end
  end
end

task :update_opengl do
  chdir "opengl" do
    sh "git pull"
  end
end

CLEAN.include(OPENGL_FILES.map{|f| "ext/#{f}" })
CLOBBER.include("opengl")
