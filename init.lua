minischem = {}

minischem.shapes = {
    {
        --{bfl, bfr, tfl, tfr, bbl, bbr, tbl, tbr}
        {1, 1, 0, 0, 1, 1, 0, 0},
        {"slab", 0}
    },
    {
        {1, 1, 0, 0, 1, 1, 1, 1},
        {"stair", 0}
    },
    {
        {0, 0, 0, 0, 1, 0, 0, 0},
        {"cube", 0}
    },
    {
        {1, 0, 0, 0, 1, 1, 1, 0},
        {"forkstair", 0}
    },
    {
        {1, 0, 0, 0, 1, 0, 1, 0},
        {"halfstair", 0}
    },
    {
        {0, 1, 0, 0, 0, 1, 0, 1},
        {"righthalfstair", 0}
    },
    {
        {1, 1, 0, 0, 0, 0, 1, 1},
        {"splitstair", 0}
    },
    {
        {1, 1, 0, 0, 1, 0, 0, 0},
        {"corner", 0}
    },
    {
        {0, 0, 0, 0, 1, 1, 0, 0},
        {"step", 0}
    },
    {
        {1, 1, 0, 0, 1, 1, 1, 0},
        {"outerstair", 0}
    },
    {
        {1, 1, 1, 0, 1, 1, 1, 1},
        {"innerstair", 0}
    }
}

function minischem.generate_rotations()
    for i=1,#minischem.shapes do
        minischem.add_shape_rotations(minischem.shapes[i])
    end
end

function minischem.append(table, term)
    table[#table+1] = term
end

function minischem.add_shape_rotations(shape)
    local binary = shape[1]
    local param2 = shape[2][2]
    local name = shape[2][1]

    local base_rot
    -- Rotation around y, for every axis
    -- Base first -- -Y
    for i=1,3 do
        base_rot = binary
        for _=1,(4 - i) do
            base_rot = minischem.rotate_y(base_rot)
        end
        local rotated_shape = {
            base_rot,
            {name, param2 + i}
        }
        minischem.append(minischem.shapes, rotated_shape)
    end
    -- -Z
    local base_nz = minischem.rotate_x(binary)
    for _=1,2 do -- Inverted
        base_nz = minischem.rotate_x(base_nz)
    end
    for i=0,3 do
        base_rot = base_nz
        if i>0 then
            for _=1,(4 - i) do
                base_rot = minischem.rotate_z(base_rot)
            end
        end
        local rotated_shape = {
            base_rot,
            {name, param2 + i + 4}
        }
        minischem.append(minischem.shapes, rotated_shape)
    end
    -- +Z
    local base_z = minischem.rotate_x(binary)
    for i=0,3 do
        base_rot = base_z
        if i>0 then
            for _=1,i do
                base_rot = minischem.rotate_z(base_rot)
            end
        end
        local rotated_shape = {
            base_rot,
            {name, param2 + i + 8}
        }
        minischem.append(minischem.shapes, rotated_shape)
    end
    -- -X
    local base_nx = minischem.rotate_z(binary)
    for i=0,3 do
        base_rot = base_nx
        if i>0 then
            for _=1,(4 - i) do
                base_rot = minischem.rotate_x(base_rot)
            end
        end
        local rotated_shape = {
            base_rot,
            {name, param2 + i + 12}
        }
        minischem.append(minischem.shapes, rotated_shape)
    end
    -- X
    local base_x = minischem.rotate_z(binary)
    for _=1,2 do -- Inverted
        base_x = minischem.rotate_z(base_x)
    end
    for i=0,3 do
        base_rot = base_x
        if i>0 then
            for _=1,i do
                base_rot = minischem.rotate_x(base_rot)
            end
        end
        local rotated_shape = {
            base_rot,
            {name, param2 + i + 16}
        }
        minischem.append(minischem.shapes, rotated_shape)
    end
    -- Y
    local base_y = minischem.rotate_z(binary)
    base_y = minischem.rotate_z(base_y)
    for i=0,3 do
        base_rot = base_y
        if i>0 then
            for _=1,i do
                base_rot = minischem.rotate_y(base_rot)
            end
        end
        local rotated_shape = {
            base_rot,
            {name, param2 + i + 20}
        }
        minischem.append(minischem.shapes, rotated_shape)
    end
end

function minischem.rotate_z(binary)
    local result = {binary[2], binary[4], binary[1], binary[3], binary[6], binary[8], binary[5], binary[7]}
    return result
end

function minischem.rotate_x(binary)
    local result = {binary[3], binary[4], binary[7], binary[8], binary[1], binary[2], binary[5], binary[6]}
    return result
end

function minischem.rotate_y(binary)
    local result = {binary[5], binary[1], binary[7], binary[3], binary[6], binary[2], binary[8], binary[4]}
    return result
end

minischem.generate_rotations()

function minischem.load_schem(schemname)
    local worldpath = minetest.get_worldpath()
    local path = worldpath .. "/schems/" .. schemname .. ".mts"

    local schem = minetest.read_schematic(path, {})
    return schem
end

function minischem.read_block(pos, schem_size, schem_data)
    local block = {}
    local y = schem_size.y
    local x = schem_size.x

    block[1] = schem_data[pos]
    block[2] = schem_data[pos + 1]
    block[3] = schem_data[pos + x]
    block[4] = schem_data[pos + x + 1]
    block[5] = schem_data[pos + x * y]
    block[6] = schem_data[pos + x * y + 1]
    block[7] = schem_data[pos + x * y + x]
    block[8] = schem_data[pos + x * y + x + 1]

    return block
end

function minischem.blockify(schemname)
    local schem = minischem.load_schem(schemname)

    local size = schem.size

    local blocky_schem = {
        data = {},
        size = {}
    }
    local pos_counter = 1

    for z = 0, (size.z / 2) - 1 do
        local posz = z * 2
        for y = 0, (size.y / 2) - 1 do
            local posy = y * 2
            for x = 0, (size.x / 2) - 1 do
                local posx = x * 2
                blocky_schem.data[pos_counter] = minischem.read_block(1 + posx + (posy * size.x) + posz * (size.y * size.x), schem.size, schem.data)
                pos_counter = pos_counter + 1
            end
        end
    end

    blocky_schem.size = {x = size.x / 2, y = size.y / 2, z = size.z / 2}

    return blocky_schem
end

function minischem.create_schem(name, schem)
    local schem_srl = minetest.serialize_schematic(schem, "mts", {})

    local worldpath = minetest.get_worldpath()
    local path = worldpath .. "/schems/mini_" .. name .. ".mts"

    -- Debug
    --local path_dbg = worldpath .. "/schems/mini_" .. name .. ".txt"
    --minetest.safe_file_write(path_dbg, dump(schem))

    minetest.safe_file_write(path, schem_srl)
end

function minischem.convert_to_binary(block)
    local binary = {}
    for i=1,8 do
        if block[i].name ~= "air" then
            binary[i] = 1
        else
            binary[i] = 0
        end
    end
    return binary
end

function minischem.compare_arrays(array1, array2)
    local comp = true
    for i=1,#array1 do
        if array1[i] ~= array2[i] then
            comp = false
        end
    end
    return comp
end

function minischem.minify_block(block)
    binary_block = minischem.convert_to_binary(block)
    matching_shape = "none"
    if minischem.compare_arrays(binary_block, {0, 0, 0, 0, 0, 0, 0, 0}) then
        matching_shape = "air"
    elseif minischem.compare_arrays(binary_block, {1, 1, 1, 1, 1, 1, 1, 1}) then
        matching_shape = "full"
    else
        for i=1,#minischem.shapes do
            if minischem.compare_arrays(binary_block, minischem.shapes[i][1]) then
                matching_shape = minischem.shapes[i][2]
            end
        end
    end
    return matching_shape
end

function minischem.scan_materials(block)
    local materials = {}
    local result = { modname = "minetest", nodename = "air"}
    for i=1,8 do
        local material = block[i].name
        if material ~= "air" then
            if minischem.key_exists(materials, material) then
                materials[material] = materials[material] + 1
            else
                materials[material] = 1
            end
        end
    end

    if minischem.check_dict_empty(materials) then
        result = minischem.select_material(materials)
    end
    return result
end

function minischem.check_dict_empty(table)
    local count = 0
    for _ in pairs(table) do
        count = count + 1
    end
    return (count > 0)
end

function minischem.select_material(table)
    local max_ocurrences = 0
    local selected_material
    local result = {}
    for material,ocurrences in pairs(table) do
        if ocurrences > max_ocurrences then
            max_ocurrences = ocurrences
            selected_material = material
        end
    end
    -- Cut the name into modname + nodename
    result.modname = string.match(selected_material, '(.*):')
    result.nodename = string.match(selected_material, ':(.*)')
    return result
end

function minischem.key_exists(table, key)
    local found = false
    for table_key,_ in pairs(table) do
        if table_key == key then
            found = true
        end
    end
    return found
end

function minischem.quantize_block(block, material)
    local count = 0
    for i=1,8 do
        if block[i].name ~= "air" then
            count = count + 1
        end
    end
    if count > 4 then
        return {name = material.modname .. ":" .. material.nodename, prob = 254, param2 = 0}
    else
        return {name = "air", prob = 0, param2 = 0}
    end
end

function minischem.microblockify(blocky_schem_data)
    local microified_data = {}
    for i=1,#blocky_schem_data do
        local matching_shape = minischem.minify_block(blocky_schem_data[i])
        local matching_material = minischem.scan_materials(blocky_schem_data[i])
        if matching_shape == "air" then
            microified_data[i] = {name = "air", prob = 0, param2 = 0}
        elseif matching_shape == "none" then
            microified_data[i] = minischem.quantize_block(blocky_schem_data[i], matching_material) -- Air or base node
        elseif matching_shape == "full" then
            microified_data[i] = {name = matching_material.modname .. ":" .. matching_material.nodename, prob = 254, param2 = 0}
        else
            microified_data[i] = {name = matching_material.modname .. ":shapes_" .. matching_material.nodename .. "_" .. matching_shape[1], prob = 254, param2 = matching_shape[2]}
        end
    end
    return microified_data
end

function minischem.minify(schemname)
    blocky_schem = minischem.blockify(schemname)
    blocky_schem.data = minischem.microblockify(blocky_schem.data)
    minischem.create_schem(schemname, blocky_schem)
end

minetest.register_chatcommand("minify", {
    params = "<file>",
    description = "Minify a schematic",
    func = function(name, param)
        minischem.minify(param)
    end,
})

