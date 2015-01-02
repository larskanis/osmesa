require "bundler/gem_tasks"
require 'rake/extensiontask'

task gem: :build

task :test=>:compile do
  sh "ruby -w -W2 -I. -Ilib -e \"#{Dir["test/test_*.rb"].map{|f| "require '#{f}';"}.join}\" -- -v"
end

spec = Gem::Specification.load('osmesa.gemspec')

# Rake-compiler task
Rake::ExtensionTask.new do |ext|
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
