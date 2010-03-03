# coding: utf-8

# MessagePack format specification
# http://msgpack.sourceforge.jp/spec

module MessagePackPure
  module Packer
  end
end

module MessagePackPure::Packer
  def self.pack(io, value)
    case value
    when Integer    then self.pack_integer(io, value)
    when NilClass   then self.pack_nil(io)
    when TrueClass  then self.pack_true(io)
    when FalseClass then self.pack_false(io)
    when Float      then self.pack_float(io, value)
    when String     then self.pack_string(io, value)
    when Array      then self.pack_array(io, value)
    when Hash       then self.pack_hash(io, value)
    else raise("unknown type")
    end
    return io
  end

  def self.pack_integer(io, num)
    case num
    when (-0x20..0x7F)
      # positive fixnum, negative fixnum
      io.write(self.pack_int8(num))
    when (0x00..0xFF)
      # uint8
      io.write("\xCC")
      io.write(self.pack_uint8(num))
    when (-0x80..0x7F)
      # int8
      io.write("\xD0")
      io.write(self.pack_int8(num))
    when (0x0000..0xFFFF)
      # uint16
      io.write("\xCD")
      io.write([num].pack("n"))
    when (-0x8000..0x7FFF)
      # int16
      io.write("\xD1")
      num += (2 ** 16) if num < 0
      io.write([num].pack("n"))
    when (0x00000000..0xFFFFFFFF)
      # uint32
      io.write("\xCE")
      io.write([num].pack("N"))
    when (-0x80000000..0x7FFFFFFF)
      # int32
      io.write("\xD2")
      num += (2 ** 32) if num < 0
      io.write([num].pack("N"))
    when (0x0000000000000000..0xFFFFFFFFFFFFFFFF)
      # uint64
      high = (num >> 32)
      low  = (num & 0xFFFFFFFF)
      io.write("\xCF")
      io.write([high].pack("N"))
      io.write([low].pack("N"))
    when (-0x8000000000000000..0x7FFFFFFFFFFFFFFF)
      # int64
      num += (2 ** 64) if num < 0
      high = (num >> 32)
      low  = (num & 0xFFFFFFFF)
      io.write("\xD3")
      io.write([high].pack("N"))
      io.write([low].pack("N"))
    else
      raise("invalid integer")
    end
  end

  def self.pack_nil(io)
    io.write("\xC0")
  end

  def self.pack_true(io)
    io.write("\xC3")
  end

  def self.pack_false(io)
    io.write("\xC2")
  end

  def self.pack_float(io, value)
    io.write("\xCB")
    io.write([value].pack("G"))
  end

  def self.pack_string(io, value)
    case value.size
    when (0x00..0x1F)
      # fixraw
      io.write([0b10100000 + value.size].pack("C"))
      io.write(value)
    when (0x0000..0xFFFF)
      # raw16
      io.write("\xDA")
      io.write([value.size].pack("n"))
      io.write(value)
    when (0x00000000..0xFFFFFFFF)
      # raw32
      io.write("\xDB")
      io.write([value.size].pack("N"))
      io.write(value)
    else
      raise("invalid length")
    end
  end

  def self.pack_array(io, value)
    case value.size
    when (0x00..0x0F)
      # fixarray
      io.write(self.pack_uint8(0b10010000 + value.size))
    when (0x0000..0xFFFF)
      # array16
      io.write("\xDC")
      io.write([value.size].pack("n"))
    when (0x00000000..0xFFFFFFFF)
      # array32
      io.write("\xDD")
      io.write([value.size].pack("N"))
    else
      raise("invalid length")
    end

    value.each { |item|
      self.pack(io, item)
    }
  end

  def self.pack_hash(io, value)
    case value.size
    when (0x00..0x0F)
      # fixmap
      io.write(self.pack_uint8(0b10000000 + value.size))
    when (0x0000..0xFFFF)
      # map16
      io.write("\xDE")
      io.write([value.size].pack("n"))
    when (0x00000000..0xFFFFFFFF)
      # map32
      io.write("\xDF")
      io.write([value.size].pack("N"))
    else
      raise("invalid length")
    end

    value.sort_by { |key, value| key }.each { |key, value|
      self.pack(io, key)
      self.pack(io, value)
    }
  end

  def self.pack_uint8(value)
    return [value].pack("C")
  end

  def self.pack_int8(value)
    return [value].pack("c")
  end
end
