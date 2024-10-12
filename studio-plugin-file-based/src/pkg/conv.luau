--!nolint LocalShadow
local types = require(script.Parent.types)
local utl = require(script.Parent.utl)
local obj = require(script.Parent.obj)
local rbx = require(script.Parent.rbx)

type V2 = types.V2
type V3 = types.V3

local conv = {}

-- o will be validated by calling obj.validate:
--     all faces must be triangles
--     all indices must be valid
function conv.obj_to_rbx(o: obj.ObjMesh, r: rbx.IRbxMesh): string?
    local valid, errs = obj.validate(o)
    if not valid then
        local err = "mesh failed validation:" .. utl.strs.merge_multiline(errs, 4)
        return err
    end

    local o_to_r_index_map: { [number]: number } = {}

    for i, f in o.f do
        local v_ids: { number } = {}
        for _, p in f do
            local v_id = r:AddVertex(o.v[p.v])
            table.insert(v_ids, v_id)
            r:SetVertexNormal(v_id, o.n[p.n])
            if p.uv ~= nil then
                r:SetUV(v_id, o.uv[p.uv])
            end
        end
        r:AddTriangle(v_ids[1], v_ids[2], v_ids[3])
    end

    return nil
end

function conv.rbx_to_obj(r: rbx.IRbxMesh): (obj.ObjMesh?, string?)
    local o = obj.new_mesh()
    local r_to_o_index_map: { [number]: number } = {}

    for _, i in ipairs(r:GetVertices()) do
        table.insert(o.v, r:GetPosition(i))
        table.insert(o.n, r:GetVertexNormal(i))
        table.insert(o.uv, r:GetUV(i))
        r_to_o_index_map[i] = #o.v
    end

    for _, i in ipairs(r:GetTriangles()) do
        local p1, p2, p3 = r:GetTriangleVertices(i)
        table.insert(o.f, {
            { v = p1, uv = p1, n = p1 },
            { v = p2, uv = p2, n = p2 },
            { v = p3, uv = p3, n = p3 },
        })
    end

    return o, nil
end

return conv
