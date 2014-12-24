require 'minitest/autorun'
require 'osmesa'

class TestConstants < Minitest::Test
  def test_version
    assert_kind_of Integer, OSMesa::MAJOR_VERSION
    assert_operator OSMesa::MAJOR_VERSION, :>, 0
    assert_kind_of Integer, OSMesa::MINOR_VERSION
    assert_kind_of Integer, OSMesa::PATCH_VERSION
  end
end
