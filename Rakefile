require "bundler/gem_tasks"
require 'rake/extensiontask'

task gem: :build

task :test do
  sh "ruby -w -W2 -I. -Ilib -e \"#{Dir["test/test_*.rb"].map{|f| "require '#{f}';"}.join}\" -- -v"
end

spec = Gem::Specification.load('osmesa.gemspec')

PLATFORMS = %w[
  aarch64-linux-gnu
  aarch64-linux-musl
  arm-linux-gnu
  arm-linux-musl
  arm64-darwin
  x64-mingw-ucrt
  x64-mingw32
  x86-linux-gnu
  x86-linux-musl
  x86-mingw32
  x86_64-darwin
  x86_64-linux-gnu
  x86_64-linux-musl
]
# Will be available with rake-compiler-dock-1.10:
#   aarch64-mingw-ucrt


# Rake-compiler task
Rake::ExtensionTask.new do |ext|
  ext.name           = 'osmesa_ext'
  ext.gem_spec       = spec
  ext.ext_dir        = 'ext'
  ext.lib_dir        = 'lib'
  ext.source_pattern = "*.{c,h}"

  ext.cross_compile = true
  ext.cross_platform = PLATFORMS
  ext.cross_config_options += [
    "--enable-cross",
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

task 'gem:native:prepare' do
	require 'io/console'
	require 'rake_compiler_dock'

	# Copy gem signing key and certs to be accessible from the docker container
	mkdir_p 'build/gem'
	sh "cp ~/.gem/gem-*.pem build/gem/ || true"
	sh "bundle package"
	begin
		OpenSSL::PKey.read(File.read(File.expand_path("~/.gem/gem-private_key.pem")), ENV["GEM_PRIVATE_KEY_PASSPHRASE"] || "")
	rescue OpenSSL::PKey::PKeyError
		ENV["GEM_PRIVATE_KEY_PASSPHRASE"] = STDIN.getpass("Enter passphrase of gem signature key: ")
		retry
	end
end

PLATFORMS.each do |platform|
	desc "Build fat binary gem for platform #{platform}"
	task "gem:native:#{platform}" => "gem:native:prepare" do
		RakeCompilerDock.sh <<-EOT, platform: platform
      sudo apt-get update &&
      sudo apt-get install -y python flex &&
      bundle install --local &&
      rake native:#{platform} pkg/#{spec.full_name}-#{platform}.gem MAKEOPTS=-j`nproc` RUBY_CC_VERSION=#{RakeCompilerDock.ruby_cc_version("~>2.7", "~>3.0")}
		EOT
	end
	desc "Build the native binary gems"
	multitask 'gem:native' => "gem:native:#{platform}"
end
