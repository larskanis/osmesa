require "bundler/gem_tasks"
require 'rake/extensiontask'

task gem: :build

task :test=>:compile do
  sh "ruby -w -W2 -I. -Ilib -e \"#{Dir["test/test_*.rb"].map{|f| "require '#{f}';"}.join}\" -- -v"
end

spec = Gem::Specification.load('osmesa.gemspec')

WIN32_ADDITIONAL_DLLS = %w[libwinpthread-1.dll libgcc_s_sjlj-1.dll libstdc++-6.dll]

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

  ext.cross_compiling do |spec|
    spec.files += WIN32_ADDITIONAL_DLLS.map{|dll| "lib/#{spec.platform}/#{dll}" }
  end

  ENV['RUBY_CC_VERSION'].to_s.split(':').each do |ruby_version|
    ext.cross_platform.each do |plat|
      WIN32_ADDITIONAL_DLLS.each do |dll|
        directory "tmp/#{plat}/stage/lib/#{plat}/"
        file "tmp/#{plat}/stage/lib/#{plat}/#{dll}" => ["tmp/#{plat}/stage/lib/#{plat}/", "tmp/#{plat}/#{ext.name}/#{ruby_version}/#{dll}"] do
          cp "tmp/#{plat}/#{ext.name}/#{ruby_version}/#{dll}", "tmp/#{plat}/stage/lib/#{plat}"
        end
        file "lib/#{plat}/#{dll}" => "tmp/#{plat}/stage/lib/#{plat}/#{dll}"
      end
    end
  end
end
