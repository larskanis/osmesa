require 'minitest/autorun'
require 'osmesa'

class TestContext < Minitest::Test
  OSMesa.load_lib

  def with_context(width, height)
    ctx = OSMesa::Context.new(OSMesa::RGBA, nil)
    buffer = "rgba" * width * height
    ctx.MakeCurrent(buffer, GL::UNSIGNED_BYTE, width, height)
    yield ctx, buffer
    ctx.Destroy
  end

  def test_buffer_image
    with_context(2, 2) do |ctx, buffer|
      GL.MatrixMode(GL::MODELVIEW)
      GL.LoadIdentity()

      GL.Clear(GL::COLOR_BUFFER_BIT)

      GL.Begin(GL::LINES)
      GL.Color4ub(0x80, 0x90, 0xa0, 0xb0)
      GL.Vertex2i(-1, -1)
      GL.Vertex2i(1, 1)
      GL.End

      GL.Flush()

      exp = "\x80\x90\xa0\xb0" + "\x00\x00\x00\x00" +
            "\x00\x00\x00\x00" + "\x80\x90\xa0\xb0"

      assert_equal exp.force_encoding(Encoding::BINARY), buffer.force_encoding(Encoding::BINARY)
    end
  end

  def test_dynamic_loader
    with_context(2, 2) do
      shader = GL.CreateShader(GL::VERTEX_SHADER)
      GL.DeleteShader(shader)
    end
  end
end
