require 'minitest/autorun'
require 'osmesa'
require 'opengl'

class TestContext < Minitest::Test
  def test_create_and_destroy
    ctx = OSMesa::Context.new(OSMesa::RGBA, nil)
    assert_kind_of OSMesa::Context, ctx
    ctx.Destroy
  end

  def test_no_destroy
    OSMesa::Context.new(OSMesa::RGBA, nil)
    # Context should be GC'ed
    GC.start
  end

  def test_double_destroy
    ctx = OSMesa::Context.new(OSMesa::RGBA, nil)
    ctx.Destroy
    assert_raises(TypeError){ ctx.Destroy }
  end

  def test_make_current
    ctx = OSMesa::Context.new(OSMesa::RGB, nil)
    buffer = "rgb" * 4
    ctx.MakeCurrent(buffer, GL::GL_UNSIGNED_BYTE, 2, 2)
  end

  def test_make_current_large_buffer
    ctx = OSMesa::Context.new(OSMesa::RGBA, nil)
    buffer = "rgba" * 512 * 512
    ctx.MakeCurrent(buffer, GL::GL_UNSIGNED_BYTE, 512, 512)
  end

  def test_make_current_too_small
    ctx = OSMesa::Context.new(OSMesa::RGBA, nil)
    buffer = "rgba" * 3
    assert_raises(ArgumentError) do
      ctx.MakeCurrent(buffer, GL::GL_UNSIGNED_BYTE, 2, 2)
    end
  end

  def test_buffer_image
    width, height = 2, 2
    ctx = OSMesa::Context.new(OSMesa::RGBA, nil)
    buffer = "rgba" * width * height
    ctx.MakeCurrent(buffer, GL::GL_UNSIGNED_BYTE, width, height)

    GL.MatrixMode(GL::GL_MODELVIEW)
    GL.LoadIdentity()

    GL.Clear(GL::GL_COLOR_BUFFER_BIT)

    GL.Begin(GL::GL_LINES)
    GL.Color4ub(0x80, 0x90, 0xa0, 0xb0)
    GL.Vertex(-1, -1)
    GL.Vertex(1, 1)
    GL.End

    GL.Flush()

    exp = "\x80\x90\xa0\xb0" + "\x00\x00\x00\x00" +
          "\x00\x00\x00\x00" + "\x80\x90\xa0\xb0"

    assert_equal exp.force_encoding(Encoding::BINARY), buffer.force_encoding(Encoding::BINARY)
  end
end
