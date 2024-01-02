local gbx = {}

-- Requires

local utils = require('utils')

-- Comments

local com_empty = rehex.Comment.new(' ')
local com_version = rehex.Comment.new('Version')
local com_type = rehex.Comment.new('Type')
local com_class = rehex.Comment.new('Class ID')
local com_header = rehex.Comment.new('Header')
local com_chunk = rehex.Comment.new('Chunk ID')
local com_userdata = rehex.Comment.new('User data')
local com_size = rehex.Comment.new('Size')
local com_numheadchunks = rehex.Comment.new('Number of chunks')
local com_chunkentries = rehex.Comment.new('Chunk entries')
local com_chunkdata = rehex.Comment.new('Chunk data')
local com_numnodes = rehex.Comment.new('Number of nodes')
local com_numexnodes = rehex.Comment.new('Number of ex nodes')
local com_referencetable = rehex.Comment.new('Reference table')
local com_ancestor = rehex.Comment.new('Ancestor level')
local com_folders = rehex.Comment.new('Folders')
local com_flags = rehex.Comment.new('Flags')
local com_nodeindex = rehex.Comment.new('Node index')
local com_usefile = rehex.Comment.new('Use file')
local com_folderindex = rehex.Comment.new('Folder index')
local com_files = rehex.Comment.new('Files')
local com_facade01 = rehex.Comment.new('FACADE01')
local com_body = rehex.Comment.new('Body')

-- Local global variables

local fic = 0                   -- Binary file cursor
local gbx_version = 0           -- GBX format version
local gbx_data_type = 'B'       -- Data type ('B' - binary, 'T' - text)
local folder_index_counter = 0  -- Folder used to give every folder an index that a file later references

-- Local functions

local function analyse_user_data(doc)
    -- Analysis of the user data portion of the file (only for versions >= 6)

    local user_data_pos = fic
    -- 4 bytes
    local user_data_size = utils.read_u32le(doc, fic)
    doc:set_comment(user_data_pos, user_data_size + 4, com_userdata)
    doc:set_comment(fic, 0, com_size)
    doc:set_data_type(fic, 4, 'u32le')
    fic = fic + 4
    if user_data_size == 0 then
        return
    end
    -- 4 bytes
    local num_head_chunks = utils.read_u32le(doc, fic)
    doc:set_comment(fic, 0, com_numheadchunks)
    doc:set_data_type(fic, 4, 'u32le')
    fic = fic + 4

    local head_chunks = {}

    for i=1, num_head_chunks do
        doc:set_comment(fic, 8, rehex.Comment.new(tostring(i)))
        -- 4 bytes
        doc:set_comment(fic, 0, com_chunk)
        fic = fic + 4
        -- 4 bytes
        head_chunks[i] = utils.read_u32le(doc, fic)
        -- Get bit 31 to check if chunk is skippable
        local skip = bit32.extract(head_chunks[i], 31, 1)
        local com_csize = com_size
        if skip == 1 then
            -- Is skippable, clearing bit 31 to get actual size
            head_chunks[i] = bit32.replace(head_chunks[i], 0, 31, 1)
            com_csize = rehex.Comment.new('Size (bit 31, skippable)')
            -- Not setting to u32le to make it look better
        else
            -- Not skippable, safe to set to u32le
            doc:set_data_type(fic, 4, 'u32le')
        end
        doc:set_comment(fic, 0, com_csize)
        
        fic = fic + 4
    end
    local data_pos = fic
    for i=1, num_head_chunks do
        local chunk_size = head_chunks[i]
        doc:set_comment(fic, chunk_size, rehex.Comment.new(tostring(i)))
        fic = fic + chunk_size
    end
    -- Group the entire user data section in a comment
    doc:set_comment(data_pos, fic - data_pos, com_chunkdata)
end

local function analyse_ref_folder(doc)
    -- Analysis of each folder (seperate function for recursion)

    local folder_position = fic
    folder_index_counter = folder_index_counter + 1
    -- 4 bytes + n bytes
    local string_s = utils.read_u32le(doc, fic)
    fic = fic + 4
    local str_foldername = '(' .. folder_index_counter .. ') ' .. doc:read_data(fic, string_s)
    local com_foldername = rehex.Comment.new(str_foldername)
    fic = fic + string_s

    -- 4 bytes
    local folder_cnt = utils.read_u32le(doc, fic)
    doc:set_data_type(fic, 4, 'u32le')
    fic = fic + 4

    for i=1, folder_cnt do
        analyse_ref_folder(doc)
    end

    doc:set_comment(folder_position, fic - folder_position, com_foldername)
end

local function analyse_ref_file(doc)
    -- Analysis of each reference file

    local file_position = fic
    local filename = ''
    -- 4 bytes
    local flags = utils.read_u32le(doc, fic)
    doc:set_comment(fic, 0, com_flags)
    doc:set_data_type(fic, 4, 'u32le')
    fic = fic + 4
    if bit32.band(flags, 4) == 0 then
        -- 4 bytes + n bytes
        local string_s = utils.read_u32le(doc, fic)
        fic = fic + 4
        filename = doc:read_data(fic, string_s)
        fic = fic + string_s
    else
        -- 4 bytes
        local res_index = utils.read_u32le(doc, fic)
        filename = 'Resource index ' .. res_index
        doc:set_data_type(fic, 4, 'u32le')
        fic = fic + 4
    end
    -- 4 bytes
    doc:set_comment(fic, 0, com_nodeindex)
    doc:set_data_type(fic, 4, 'u32le')
    fic = fic + 4
    if gbx_version >= 5 then
        -- 4 bytes
        doc:set_comment(fic, 0, com_usefile)
        doc:set_data_type(fic, 4, 'u32le')
        fic = fic + 4
    end
    if bit32.band(flags, 4) == 0 then
        -- 4 bytes
        doc:set_comment(fic, 0, com_folderindex)
        doc:set_data_type(fic, 4, 'u32le')
        fic = fic + 4
    end
    -- Group the entire file in a comment
    local com_filename = rehex.Comment.new(filename)
    doc:set_comment(file_position, fic - file_position, com_folderindex)
end

local function analyse_reference_table(doc)
    -- 4 bytes
    local num_ex_nodes = utils.read_u32le(doc, fic)
    doc:set_comment(fic, 0, com_numexnodes)
    doc:set_data_type(fic, 4, 'u32le')
    fic = fic + 4

    if num_ex_nodes == 0 then
        return fic
    end

    local table_position = fic
    -- 4 bytes
    local ancestor = utils.read_u32le(doc, fic)
    doc:set_comment(fic, 0, com_ancestor)
    doc:set_data_type(fic, 4, 'u32le')
    fic = fic + 4
    local folder_position = fic
    -- 4 bytes
    local folder_cnt = utils.read_u32le(doc, fic)
    doc:set_data_type(fic, 4, 'u32le')
    fic = fic + 4
    -- Do folders
    for i=1, folder_cnt do
        analyse_ref_folder(doc)
    end
    -- Group the entire folders section in a comment
    doc:set_comment(folder_position, fic - folder_position, com_folders)
    -- Do files
    local file_position = fic
    for i=1, num_ex_nodes do
        analyse_ref_file(doc)
    end
    -- Group the entire files section in a comment
    doc:set_comment(file_position, fic - file_position, com_files)
    -- Group the entire reference table section in a comment
    doc:set_comment(table_position, fic - table_position, com_referencetable)
end

local function analyse_body(doc)
    -- Simple body analysis, just mark all node terminators
    while true do
        local status, facade = pcall(utils.read_u32le, doc, fic)
        if not status then
            -- Failed to read, means eof, returning...
            break
        end
        if facade == 0xfacade01 then
            doc:set_comment(fic, 0, com_facade01)
            fic = fic + 4
        else
            fic = fic + 1
        end
    end
end

-- Entry

function gbx.analyse(doc)
    -- Analysis of the GBX file

    fic = 3                     -- binary file cursor (starting from 3, we know its a GBX file)
    folder_index_counter = 0
    
    gbx_version = utils.read_u16le(doc, fic)
    gbx_data_type = doc:read_data(fic + 2, 1)           -- 'B' - binary, 'T' - text (currently not supported)
    local gbx_compressed = doc:read_data(fic + 4, 1)    -- 'C' - compressed, 'U' - uncompressed

    if gbx_version < 3 then
        -- No avaialable specifications for versions < 3
        error('This version of GBX file is unsupported.')
    end
    if gbx_data_type ~= 'B' then
        -- Not a binary file, currently only binary files are supported
        error('Only binary type files are supported.')
    end
    -- 2 bytes
    doc:set_comment(fic, 0, com_version)
    doc:set_data_type(fic, 2, 'u16le')
    fic = fic + 2
    if gbx_version >= 4 then
        -- 4 bytes
        doc:set_comment(fic, 4, com_type)
        fic = fic + 4
    else
        -- 3 bytes
        doc:set_comment(fic, 3, com_type)
        fic = fic + 3
    end
    -- 4 bytes
    doc:set_comment(fic, 0, com_class)
    fic = fic + 4
    -- Group the entire header section in a comment
    doc:set_comment(0, fic, com_header)

    if gbx_version >= 6 then
        analyse_user_data(doc, fic)
    end
    -- 4 bytes
    local num_nodes = utils.read_u32le(doc, fic)
    doc:set_comment(fic, 0, com_numnodes)
    doc:set_data_type(fic, 4, 'u32le')
    fic = fic + 4

    analyse_reference_table(doc, fic)
    
    if gbx_compressed == 'C' then
        -- Compressed files not supported
        doc:set_comment(fic, 0, com_body)
        error('Please decompress the file to analyse the body.')
    end
    local body_position = fic
    analyse_body(doc)
    -- Group the entire body section in a comment
    doc:set_comment(body_position, fic - body_position, com_body)
end

return gbx
