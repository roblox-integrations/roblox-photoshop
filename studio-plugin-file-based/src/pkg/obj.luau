--!nolint LocalShadow
local types = require(script.Parent.types)
local utl = require(script.Parent.utl)
-- Roblox require statements!
local obj = {}

type V2 = types.V2
type V3 = types.V3

export type ObjMesh = {
    name: string,
    v: { [number]: V3 },
    n: { [number]: V3 },
    uv: { [number]: V2 },
    f: { [number]: { { v: number, n: number, uv: number? } } }
}

function obj.new_mesh(): ObjMesh
    return {
        name = "",
        v = {},
        n = {},
        uv = {},
        f = {},
    }
end

type LineStarter = "o" | "v" | "vn" | "vt" | "f" -- anything else we ignore
function obj.parse(data: string): ({ [number]: ObjMesh }?, string?)
    type LineHandler = ({ [number]: string }) -> string?

    local objects = {} :: { [number]: ObjMesh }
    local current_object: ObjMesh? = nil

    -- common handler checks
    local function req_current_object(tokens: { [number]: string }): string?
        if current_object == nil then
            return "no current object, 'o' line must appear above this line"
        end
        return nil
    end

    local function num_args_ge(n: number): ({ [number]: string }) -> string?
        return function(tokens: { [number]: string }): string?
            if #tokens < n then
                return `too few args, expected {n - 1}`
            end
            return nil
        end
    end

    -- parsing helper
    local function slice_to_number<T>(arr: { [number]: string }, s: number, n: number?): ({ [number]: number }?, string?)
        local rtn = {}
        local e = if n ~= nil then s + n - 1 else #arr
        for i = s, e do
            local num = tonumber(arr[i])
            if num == nil then
                return nil, `expected number, "{arr[i]}" is not a number`
            end
            table.insert(rtn, num)
        end
        return rtn, nil
    end

    local line_handlers: { [LineStarter]: LineHandler } = {
        ["o"] = utl.fn.chain_if_nil(num_args_ge(2), function(tokens: { [number]: string }): string?
            current_object = obj.new_mesh()
            assert(current_object ~= nil)
            current_object.name = tokens[2]
            table.insert(objects, current_object)
            return nil
        end),
        ["v"] = utl.fn.chain_if_nil(req_current_object, num_args_ge(4), function(tokens: { [number]: string }): string?
            assert(current_object ~= nil)
            local nums, err = slice_to_number(tokens, 2, 3)
            if err ~= nil then
                return err
            end
            assert(nums ~= nil)
            table.insert(current_object.v, { x = nums[1], y = nums[2], z = nums[3] })
            return nil
        end),
        ["vn"] = utl.fn.chain_if_nil(
            req_current_object,
            num_args_ge(4),
            function(tokens: { [number]: string }): string?
                assert(current_object ~= nil)
                local nums, err = slice_to_number(tokens, 2, 3)
                if err ~= nil then
                    return err
                end
                assert(nums ~= nil)
                table.insert(current_object.n, { x = nums[1], y = nums[2], z = nums[3] })
                return nil
            end
        ),
        ["vt"] = utl.fn.chain_if_nil(
            req_current_object,
            num_args_ge(3),
            function(tokens: { [number]: string }): string?
                assert(current_object ~= nil)
                local nums, err = slice_to_number(tokens, 2, 2)
                if err ~= nil then
                    return err
                end
                assert(nums ~= nil)
                table.insert(current_object.uv, { x = nums[1], y = nums[2] })
                return nil
            end
        ),
        ["f"] = utl.fn.chain_if_nil(req_current_object, num_args_ge(4), function(tokens: { [number]: string }): string?
            if #tokens > 5 then
                return "too many args, only supports tris and quads"
            end

            assert(current_object ~= nil)
            local err: string? = nil
            local face = utl.iter.chain(tokens):slice(2):map(function(v)
                local split = utl.strs.split(v, "/")
                if #split < 3 then
                    err = "too few components, expected form v/vt/vn"
                end
                local split: { [number]: number? } = utl.iter.map(split, function(v): number?
                    if v == "" then
                        return nil
                    end
                    local num = tonumber(v)
                    if num == nil then
                        err = `expected number, "{v}" is not a number`
                    end
                    return num :: number
                end)
                return { v = split[1], uv = split[2], n = split[3] }
            end)

            if err ~= nil then
                return err
            end

            -- validate for consistency
            local uv_nil = face:get()[1].uv == nil
            face:for_each(function(v)
                if v.v == nil or v.n == nil then
                    err = "face argument missing vertex or normal number"
                elseif (v.uv == nil) ~= uv_nil then
                    err = "inconsistent face arguments, if vt is omitted from one, it must be omitted from all"
                end
            end)

            local face = face:get()

            if err ~= nil then
                return err
            end

            -- triangulate quad
            if #face > 3 then
                table.insert(current_object.f, { face[1], face[2], face[3] })
                table.insert(current_object.f, { face[1], face[3], face[4] })
            else
                table.insert(current_object.f, face)
            end
            return nil
        end),
    }

    for i, line in utl.strs.split_lines(data) do
        local tokens = utl.strs.split_whitespace(line)
        if #tokens == 0 then
            continue
        end
        local handler = line_handlers[tokens[1] :: LineStarter]
        if handler == nil then
            continue -- ignore this line
        end
        local err = handler(tokens)
        if err ~= nil then
            return nil, `error - line[{i}]: {err}`
        end
    end

    return objects, nil
end

-- returns list of error messages
function obj.validate(mesh: ObjMesh): (boolean, { string })
    -- we basically only check that all faces are tris and point to valid indices
    local messages: { string } = {}
    for i, f in ipairs(mesh.f) do
        if #f ~= 3 then
            table.insert(messages, `face[{i}] is not a triangle, has {#f} points`)
        end

        for j, p in ipairs(f) do
            if mesh.v[p.v] == nil then
                table.insert(messages, `face[{i}], point[{j}] 'v' index = {p.v} does not exist`)
            end
            if mesh.n[p.n] == nil then
                table.insert(messages, `face[{i}], point[{j}] 'n' index = {p.n} does not exist`)
            end
            if p.uv ~= nil and mesh.uv[p.uv] == nil then
                table.insert(messages, `face[{i}], point[{j}] 'uv' index = {p.uv} does not exist`)
            end
        end
    end
    return #messages == 0, messages
end

return obj
