require 'osmesa'
require 'opengl'
require 'chunky_png'

width, height = 100, 70
ctx = OSMesa::Context.new(OSMesa::RGBA, nil)
buffer = "rgba" * width * height
ctx.MakeCurrent(buffer, GL::GL_UNSIGNED_BYTE, width, height)

GL.MatrixMode(GL::GL_MODELVIEW)
GL.LoadIdentity()

GL.Clear(GL::GL_COLOR_BUFFER_BIT)

GL.Begin(GL::GL_LINES)
GL.Vertex(0.5, 0.5)
GL.Vertex(-0.5, -0.5)
GL.End

GL.Flush()

png = ChunkyPNG::Image.from_rgba_stream(width, height, buffer)
png.save('test.png')
