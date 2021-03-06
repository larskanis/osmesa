require 'minitest/autorun'
require 'osmesa'

class TestSingletons < Minitest::Test
  def test_GetIntegerv
    ctx = OSMesa::Context.new(OSMesa::RGBA, nil)
    ctx.MakeCurrent("rgba"*2*3, GL::UNSIGNED_BYTE, 2, 3)
    assert_equal 2, OSMesa.GetIntegerv(OSMesa::OSMESA_WIDTH)
    assert_equal 3, OSMesa.GetIntegerv(OSMesa::OSMESA_HEIGHT)
  end
end
