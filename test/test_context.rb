require 'minitest/autorun'
require 'osmesa'

class TestContext < Minitest::Test

  def test_create_and_destroy
    ctx = OSMesa::Context.new(OSMesa::RGBA, nil)
    assert_kind_of OSMesa::Context, ctx
    assert_nil ctx.buffer_string
    assert_nil ctx.buffer_addr
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
    ctx.MakeCurrent(buffer, GL::UNSIGNED_BYTE, 2, 2)
    assert_same buffer, ctx.buffer_string
    assert_operator ctx.buffer_addr, :>, 0
  end

  def test_make_current_large_buffer
    ctx = OSMesa::Context.new(OSMesa::RGBA, nil)
    buffer = "rgba" * 512 * 512
    ctx.MakeCurrent(buffer, GL::UNSIGNED_BYTE, 512, 512)
  end

  def test_make_current_too_small
    ctx = OSMesa::Context.new(OSMesa::RGBA, nil)
    buffer = "rgba" * 3
    assert_raises(ArgumentError) do
      ctx.MakeCurrent(buffer, GL::UNSIGNED_BYTE, 2, 2)
    end
  end
end
