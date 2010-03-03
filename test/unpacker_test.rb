#! ruby -Ku
# coding: utf-8

require "test_helper"
require "msgpack_pure/unpacker"

class UnpackerTest < Test::Unit::TestCase
  def setup
    @module = MessagePackPure::Unpacker
  end

  def test_positive_fixnum
    assert_equal(  0, @module.unpack(StringIO.new("\x00")))
    assert_equal(127, @module.unpack(StringIO.new("\x7F")))
  end

  def test_negative_fixnum
    assert_equal( -1, @module.unpack(StringIO.new("\xFF")))
    assert_equal(-32, @module.unpack(StringIO.new("\xE0")))
  end

  def test_uint8
    assert_equal(128,        @module.unpack(StringIO.new("\xCC\x80")))
    assert_equal(2 ** 8 - 1, @module.unpack(StringIO.new("\xCC\xFF")))
  end

  def test_uint16
    assert_equal(2 ** 8,      @module.unpack(StringIO.new("\xCD\x01\x00")))
    assert_equal(2 ** 16 - 1, @module.unpack(StringIO.new("\xCD\xFF\xFF")))
  end

  def test_uint32
    assert_equal(2 ** 16,     @module.unpack(StringIO.new("\xCE\x00\x01\x00\x00")))
    assert_equal(2 ** 32 - 1, @module.unpack(StringIO.new("\xCE\xFF\xFF\xFF\xFF")))
  end

  def test_uint64
    assert_equal(2 ** 32,     @module.unpack(StringIO.new("\xCF\x00\x00\x00\x01\x00\x00\x00\x00")))
    assert_equal(2 ** 64 - 1, @module.unpack(StringIO.new("\xCF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF")))
  end

  def test_int8
    assert_equal(-33,  @module.unpack(StringIO.new("\xD0\xDF")))
    assert_equal(-128, @module.unpack(StringIO.new("\xD0\x80")))
  end

  def test_int16
    # TODO:
  end

  def test_int32
    # TODO:
  end

  def test_int64
    # TODO:
  end

  def test_nil
    assert_equal(nil, @module.unpack(StringIO.new("\xC0")))
  end

  def test_true
    assert_equal(true, @module.unpack(StringIO.new("\xC3")))
  end

  def test_false
    assert_equal(false, @module.unpack(StringIO.new("\xC2")))
  end

  def test_ok
    assert true
  end
end