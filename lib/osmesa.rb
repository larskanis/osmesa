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
    ENV['PATH'] = "#{File.expand_path("../#{RUBY_PLATFORM}", __FILE__)};#{old_path}"
    require "#{major_minor}/osmesa_ext"
    ENV['PATH'] = old_path
  else
    raise
  end
end

# (OSMesa::Gl.)glVertex -> OSMesa::GL.Vertex
# (OSMesa::Gl::)GL_TRUE -> OSMesa::GL::TRUE
module OSMesa
  module GL
    extend self
    include Gl

    Gl.constants.each do |cn|
      n = cn.to_s.sub(/^GL_/,'')
      # due to ruby naming scheme, we can't export constants with leading decimal,
      # e.g. (OSMesa::Gl::)GL_2D would under old syntax become (OSMesa::GL::)2D which is illegal
      next if n =~ /^[0-9]/
      const_set( n, Gl.const_get( cn ) )
    end

    Gl.methods( false ).each do |mn|
      n = mn.to_s.sub(/^gl/,'')
      alias_method( n, mn )
      public( n )
    end
  end
end
