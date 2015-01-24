require 'minitest/autorun'
require 'osmesa'

class TestContext < Minitest::Test
  include OSMesa

  def test_create_and_destroy
    ctx = Context.new(RGBA, nil)
    assert_kind_of Context, ctx
    assert_nil ctx.buffer_string
    assert_nil ctx.buffer_addr
    ctx.Destroy
  end

  def test_no_destroy
    Context.new(RGBA, nil)
    # Context should be GC'ed
    GC.start
  end

  def test_double_destroy
    ctx = Context.new(RGBA, nil)
    ctx.Destroy
    assert_raises(TypeError){ ctx.Destroy }
  end

  def test_make_current
    ctx = Context.new(RGB, nil)
    buffer = "rgb" * 4
    ctx.MakeCurrent(buffer, GL::GL_UNSIGNED_BYTE, 2, 2)
    assert_same buffer, ctx.buffer_string
    assert_operator ctx.buffer_addr, :>, 0
  end

  def test_make_current_large_buffer
    ctx = Context.new(RGBA, nil)
    buffer = "rgba" * 512 * 512
    ctx.MakeCurrent(buffer, GL::GL_UNSIGNED_BYTE, 512, 512)
  end

  def test_make_current_too_small
    ctx = Context.new(RGBA, nil)
    buffer = "rgba" * 3
    assert_raises(ArgumentError) do
      ctx.MakeCurrent(buffer, GL::GL_UNSIGNED_BYTE, 2, 2)
    end
  end
end
