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
    spec.files += dlls.map{|dll| "lib/#{dll}" }

    directory "tmp/#{plat}/stage/lib/"
    dlls.each do |dll|
      ENV['RUBY_CC_VERSION'].to_s.split(':').each do |ruby_version|
        # Not all DLLs are required for all ruby versions
        next unless File.exist?("tmp/#{plat}/#{ext.name}/#{ruby_version}/#{dll}")

        file "tmp/#{plat}/stage/lib/#{dll}" => ["tmp/#{plat}/stage/lib/", "tmp/#{plat}/#{ext.name}/#{ruby_version}/#{dll}"] do
          cp "tmp/#{plat}/#{ext.name}/#{ruby_version}/#{dll}", "tmp/#{plat}/stage/lib"
          sh "x86_64-w64-mingw32-strip", "tmp/#{plat}/stage/lib/#{dll}"
        end
      end
      file "lib/#{dll}" => "tmp/#{plat}/stage/lib/#{dll}"
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

desc "Build windows binary gems per rake-compiler-dock."
task "gem:windows" do
  require "rake_compiler_dock"
  RakeCompilerDock.sh <<-EOT
    sudo apt-get update &&
    sudo apt-get install -y python flex &&
    rake cross native gem MAKE='nice make -j`nproc`' RUBY_CC_VERSION=1.9.3:2.0.0:2.1.6:2.2.2
  EOT
end
