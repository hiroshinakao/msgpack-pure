#! ruby -Ku
# coding: utf-8

require "test_helper"
require "stringio"
require "msgpack_pure/packer"

class PackerTest < Test::Unit::TestCase
  def setup
    @module = MessagePackPure::Packer
  end

  def test_write__positive_fixnum
    assert_equal("\x00", @module.write(sio, 0x00).string)
    assert_equal("\x01", @module.write(sio, 0x01).string)
    assert_equal("\x7F", @module.write(sio, 0x7F).string)
  end

  def test_write__negative_fixnum
    assert_equal("\xFF", @module.write(sio, -0x01).string)
    assert_equal("\xE0", @module.write(sio, -0x20).string)
  end

  def test_write__uint8
    assert_equal("\xCC\x80", @module.write(sio, 0x80).string)
    assert_equal("\xCC\xFF", @module.write(sio, 0xFF).string)
  end

  def test_write__uint16
    assert_equal("\xCD\x01\x00", @module.write(sio, 0x0100).string)
    assert_equal("\xCD\xFF\xFF", @module.write(sio, 0xFFFF).string)
  end

  def test_write__uint32
    assert_equal("\xCE\x00\x01\x00\x00", @module.write(sio, 0x00010000).string)
    assert_equal("\xCE\xFF\xFF\xFF\xFF", @module.write(sio, 0xFFFFFFFF).string)
  end

  def test_write__uint64
    assert_equal("\xCF\x00\x00\x00\x01\x00\x00\x00\x00", @module.write(sio, 0x0000000100000000).string)
    assert_equal("\xCF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF", @module.write(sio, 0xFFFFFFFFFFFFFFFF).string)
  end

  def test_write__int8
    assert_equal("\xD0\xDF", @module.write(sio, -0x21).string)
    assert_equal("\xD0\x80", @module.write(sio, -0x80).string)
  end

  def test_write__int16
    assert_equal("\xD1\xFF\x7F", @module.write(sio, -0x0081).string)
    assert_equal("\xD1\x80\x00", @module.write(sio, -0x8000).string)
  end

  def test_write__int32
    assert_equal("\xD2\xFF\xFF\x7F\xFF", @module.write(sio, -0x00008001).string)
    assert_equal("\xD2\x80\x00\x00\x00", @module.write(sio, -0x80000000).string)
  end

  def test_write__int64
    assert_equal("\xD3\xFF\xFF\xFF\xFF\x7F\xFF\xFF\xFF", @module.write(sio, -0x0000000080000001).string)
    assert_equal("\xD3\x80\x00\x00\x00\x00\x00\x00\x00", @module.write(sio, -0x8000000000000000).string)
  end

  def test_write__nil
    assert_equal("\xC0", @module.write(sio, nil).string)
  end

  def test_write__true
    assert_equal("\xC3", @module.write(sio, true).string)
  end

  def test_write__false
    assert_equal("\xC2", @module.write(sio, false).string)
  end

  def test_write__float
    assert_equal("\xCB\x00\x00\x00\x00\x00\x00\x00\x00", @module.write(sio, +0.0).string)
    assert_equal("\xCB\x3F\xE0\x00\x00\x00\x00\x00\x00", @module.write(sio, +0.5).string)
    assert_equal("\xCB\xBF\xE0\x00\x00\x00\x00\x00\x00", @module.write(sio, -0.5).string)
  end

  def test_write__fixraw
    assert_equal("\xA0",    @module.write(sio, "").string)
    assert_equal("\xA3ABC", @module.write(sio, "ABC").string)
    assert_equal(
      "\xBF" + "A" * 31,
      @module.write(sio, "A" * 31).string)
  end

  def test_write__raw16
    assert_equal(
      "\xDA\x00\x20" + "A" * 0x0020,
      @module.write(sio, "A" * 0x0020).string)
    assert_equal(
      "\xDA\xFF\xFF" + "A" * 0xFFFF,
      @module.write(sio, "A" * 0xFFFF).string)
  end

  def test_write__raw32
    assert_equal(
      "\xDB\x00\x01\x00\x00" + "A" * 0x00010000,
      @module.write(sio, "A" * 0x00010000).string)
  end

  def test_write__fixarray
    assert_equal("\x90",             @module.write(sio, []).string)
    assert_equal("\x93\x00\x01\x02", @module.write(sio, [0, 1, 2]).string)

    io = StringIO.new("\x9F", "a+")
    array = 0x0F.times.map { |i|
      @module.write(io, i)
      i
    }
    assert_equal(io.string, @module.write(sio, array).string)
  end

  def test_write__array16_min
    io = StringIO.new("\xDC\x00\x10", "a+")
    array = 0x0010.times.map { |i|
      @module.write(io, i)
      i
    }
    assert_equal(io.string, @module.write(sio, array).string)
  end

  def test_write__array16_max
    io = StringIO.new("\xDC\xFF\xFF", "a+")
    array = 0xFFFF.times.map { |i|
      @module.write(io, i)
      i
    }
    assert_equal(io.string, @module.write(sio, array).string)
  end

  def test_write__array32_min
    io = StringIO.new("\xDD\x00\x01\x00\x00", "a+")
    array = 0x00010000.times.map { |i|
      @module.write(io, i)
      i
    }
    assert_equal(io.string, @module.write(sio, array).string)
  end

  def test_write__fixmap
    assert_equal("\x80", @module.write(sio, {}).string)
    assert_equal(
      "\x82\x00\x01\x02\x03",
      @module.write(sio, {0 => 1, 2 => 3}).string)

    io = StringIO.new("\x8F", "a+")
    hash = 0x0F.times.inject({}) { |memo, i|
      @module.write(io, i)
      @module.write(io, 0)
      memo[i] = 0
      memo
    }
    assert_equal(io.string, @module.write(sio, hash).string)
  end

  def test_write__map16_min
    io = StringIO.new("\xDE\x00\x10", "a+")
    hash = 0x0010.times.inject({}) { |memo, i|
      @module.write(io, i)
      @module.write(io, 0)
      memo[i] = 0
      memo
    }
    assert_equal(io.string, @module.write(sio, hash).string)
  end

  def test_write__map16_max
    io = StringIO.new("\xDE\xFF\xFF", "a+")
    hash = 0xFFFF.times.inject({}) { |memo, i|
      @module.write(io, i)
      @module.write(io, 0)
      memo[i] = 0
      memo
    }
    assert_equal(io.string, @module.write(sio, hash).string)
  end

  def test_write__map32_min
    io = StringIO.new("\xDF\x00\x01\x00\x00", "a+")
    hash = 0x00010000.times.inject({}) { |memo, i|
      @module.write(io, i)
      @module.write(io, 0)
      memo[i] = 0
      memo
    }
    assert_equal(io.string, @module.write(sio, hash).string)
  end

  private

  def sio
    return StringIO.new
  end
end