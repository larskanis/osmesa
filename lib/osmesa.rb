require "osmesa/bindings_version"

begin
  require 'osmesa_ext'
rescue LoadError
  # If it's a Windows binary gem, try the <major>.<minor> subdirectory
  if RUBY_PLATFORM =~/(mswin|mingw)/i
    major_minor = RUBY_VERSION[ /^(\d+\.\d+)/ ] or
      raise "Oops, can't extract the major/minor version from #{RUBY_VERSION.dump}"

    # Set the PATH environment variable, so that libpq.dll can be found.
    old_path = ENV['PATH']
    ENV['PATH'] = "#{File.expand_path("..", __FILE__)};#{old_path}"
    require "#{major_minor}/osmesa_ext"
    ENV['PATH'] = old_path
  else
    raise
  end
end

require 'opengl'

module OSMesa
  def self.load_lib
    begin
      GL.load_lib("libOSMesa.so")
    rescue LoadError
      raise unless RUBY_PLATFORM=~/mingw|mswin/i
      dllpath = File.expand_path("../libOSMesa-8.dll", __FILE__)
      GL.load_lib(dllpath)
    end
  end
end
