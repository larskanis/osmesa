require 'minitest/autorun'
require 'osmesa'

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
end
