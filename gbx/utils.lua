local utils = {}

-- 16bit integer

function utils.read_s16le(doc, offset)
    return string.unpack('<h', doc:read_data(offset, 2))
end

function utils.read_s16be(doc, offset)
    return string.unpack('>h', doc:read_data(offset, 2))
end

function utils.read_u16le(doc, offset)
    return string.unpack('<H', doc:read_data(offset, 2))
end

function utils.read_u16be(doc, offset)
    return string.unpack('>H', doc:read_data(offset, 2))
end

-- 32bit integer

function utils.read_s32le(doc, offset)
    return string.unpack('<i4', doc:read_data(offset, 4))
end

function utils.read_s32be(doc, offset)
    return string.unpack('>i4', doc:read_data(offset, 4))
end

function utils.read_u32le(doc, offset)
    return string.unpack('<I4', doc:read_data(offset, 4))
end

function utils.read_u32be(doc, offset)
    return string.unpack('>I4', doc:read_data(offset, 4))
end

return utils