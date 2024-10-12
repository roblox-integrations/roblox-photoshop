--!nolint LocalShadow
local types = require(script.Parent.types)

type V2 = types.V2
type V3 = types.V3

type _Vertex = { p: V3, n: V3, uv: V2 }
type _Triangle = { a: number, b: number, c: number }

-- implements some functionality of editable mesh
export type IRbxMesh = {
    AddVertex: (self: IRbxMesh, p: V3) -> number,
    AddTriangle: (self: IRbxMesh, v0: number, v1: number, v2: number) -> number,

    RemoveVertex: (self: IRbxMesh, id: number) -> (),
    RemoveTriangle: (self: IRbxMesh, id: number) -> (),

    GetVertices: (self: IRbxMesh) -> { number },
    GetTriangles: (self: IRbxMesh) -> { number },

    GetPosition: (self: IRbxMesh, id: number) -> V3,
    GetUV: (self: IRbxMesh, id: number) -> V2,
    GetVertexNormal: (self: IRbxMesh, id: number) -> V3,
    GetTriangleVertices: (self: IRbxMesh, id: number) -> (number, number, number),

    SetPosition: (self: IRbxMesh, id: number, p: V3) -> (),
    SetUV: (self: IRbxMesh, id: number, uv: V2) -> (),
    SetVertexNormal: (self: IRbxMesh, id: number, n: V3) -> (),

    -- added by me
    for_each_vtx: (self: IRbxMesh, fn: (number, _Vertex) -> ()) -> (),
    for_each_tri: (self: IRbxMesh, fn: (number, _Triangle) -> ()) -> ()
}

local rbx = {}

-- a mesh that emulates the editable mesh API
function rbx.new_mesh(): IRbxMesh
    -- types local to function
    type _Mesh = {
        _vidx: number,
        _tidx: number,
        v: { [number]: _Vertex },
        t: { [number]: _Triangle }    
}

    local mesh = {
        _vidx = 1,
        _tidx = 1,
        v = {},
        t = {},
    } :: _Mesh & IRbxMesh

    local function make_vertex(p: V3): _Vertex
        -- default values matching roblox
        return {
            p = p,
            n = { x = 0, y = 0, z = 1 },
            uv = { x = 0, y = 0 },
        }
    end

    function mesh:AddVertex(p: V3): number
        local self = self :: _Mesh & IRbxMesh -- cast for intellisense
        local i = self._vidx
        self._vidx += 1
        self.v[i] = make_vertex(p)
        return i
    end

    function mesh:AddTriangle(v0: number, v1: number, v2: number): number
        local self = self :: _Mesh & IRbxMesh -- cast for intellisense
        local i = self._tidx
        self._tidx += 1
        self.t[i] = { a = v0, b = v1, c = v2 }
        return i
    end

    function mesh:RemoveVertex(id: number)
        local self = self :: _Mesh & IRbxMesh -- cast for intellisense
        self.v[id] = nil
    end

    function mesh:RemoveTriangle(id: number): ()
        local self = self :: _Mesh & IRbxMesh -- cast for intellisense
        self.t[id] = nil
    end

    function mesh:GetVertices(): { number }
        local self = self :: _Mesh & IRbxMesh -- cast for intellisense
        local verts = {}
        for k, _ in pairs(self.v) do
            table.insert(verts, k)
        end
        return verts
    end

    function mesh:GetTriangles(): { number }
        local self = self :: _Mesh & IRbxMesh -- cast for intellisense
        local tris = {}
        for k, _ in pairs(self.t) do
            table.insert(tris, k)
        end
        return tris
    end

    function mesh:GetPosition(id: number): V3
        local self = self :: _Mesh & IRbxMesh -- cast for intellisense
        return self.v[id].p
    end

    function mesh:GetUV(id: number): V2
        local self = self :: _Mesh & IRbxMesh -- cast for intellisense
        return self.v[id].uv
    end

    function mesh:GetVertexNormal(id: number): V3
        local self = self :: _Mesh & IRbxMesh -- cast for intellisense
        return self.v[id].n
    end

    function mesh:GetTriangleVertices(id: number): (number, number, number)
        local self = self :: _Mesh & IRbxMesh -- cast for intellisense
        local tri = self.t[id]
        return tri.a, tri.b, tri.c
    end

    function mesh:SetPosition(id: number, p: V3): ()
        local self = self :: _Mesh & IRbxMesh -- cast for intellisense
        self.v[id].p = p
    end

    function mesh:SetUV(id: number, uv: V2): ()
        local self = self :: _Mesh & IRbxMesh -- cast for intellisense
        self.v[id].uv = uv
    end

    function mesh:SetVertexNormal(id: number, n: V3): ()
        local self = self :: _Mesh & IRbxMesh -- cast for intellisense
        self.v[id].n = n
    end

    function mesh:for_each_vtx(fn: (number, _Vertex) -> ()): ()
        local self = self :: _Mesh & IRbxMesh -- cast for intellisense
        for i, v in pairs(self.v) do
            fn(i, v)
        end
    end

    function mesh:for_each_tri(fn: (number, _Triangle) -> ()): ()
        local self = self :: _Mesh & IRbxMesh -- cast for intellisense
        for i, t in pairs(self.t) do
            fn(i, t)
        end
    end

    return mesh
end

-- forwards IRbxMesh calls to a real editable mesh
function rbx.new_mesh_bridge(em: EditableMesh): IRbxMesh
    type _Bridge = {
        _em: EditableMesh    
}
    local bridge = {
        _em = em,
    } :: _Bridge & IRbxMesh

    local function to_rbx_vec3(p: V3): Vector3
        return Vector3.new(p.x, p.y, p.z)
    end

    local function to_rbx_vec2(p: V2): Vector2
        return Vector2.new(p.x, p.y)
    end

    local function to_vec3(p: Vector3): V3
        return { x = p.X, y = p.Y, z = p.Z }
    end

    local function to_vec2(p: Vector2): V2
        return { x = p.X, y = p.Y }
    end

    function bridge:AddVertex(p: V3): number
        local self = self :: _Bridge & IRbxMesh -- cast for intellisense
        return self._em:AddVertex(to_rbx_vec3(p))
    end

    function bridge:AddTriangle(v0: number, v1: number, v2: number): number
        local self = self :: _Bridge & IRbxMesh -- cast for intellisense
        return self._em:AddTriangle(v0, v1, v2)
    end

    function bridge:RemoveVertex(id: number)
        local self = self :: _Bridge & IRbxMesh -- cast for intellisense
        self._em:RemoveVertex(id)
    end

    function bridge:RemoveTriangle(id: number): ()
        local self = self :: _Bridge & IRbxMesh -- cast for intellisense
        self._em:RemoveTriangle(id)
    end

    function bridge:GetVertices(): { number }
        local self = self :: _Bridge & IRbxMesh -- cast for intellisense
        return self._em:GetVertices()
    end

    function bridge:GetTriangles(): { number }
        local self = self :: _Bridge & IRbxMesh -- cast for intellisense
        return self._em:GetTriangles()
    end

    function bridge:GetPosition(id: number): V3
        local self = self :: _Bridge & IRbxMesh -- cast for intellisense
        return to_vec3(self._em:GetPosition(id))
    end

    function bridge:GetUV(id: number): V2
        local self = self :: _Bridge & IRbxMesh -- cast for intellisense
        return to_vec2(self._em:GetUV(id))
    end

    function bridge:GetVertexNormal(id: number): V3
        local self = self :: _Bridge & IRbxMesh -- cast for intellisense
        return to_vec3(self._em:GetVertexNormal(id))
    end

    function bridge:GetTriangleVertices(id: number): (number, number, number)
        local self = self :: _Bridge & IRbxMesh -- cast for intellisense
        local a, b, c = nil, nil, nil -- roblox gave this function the wron return type...
        a, b, c = self._em:GetTriangleVertices(id)
        return a, b, c
    end

    function bridge:SetPosition(id: number, p: V3): ()
        local self = self :: _Bridge & IRbxMesh -- cast for intellisense
        self._em:SetPosition(id, to_rbx_vec3(p))
    end

    function bridge:SetUV(id: number, uv: V2): ()
        local self = self :: _Bridge & IRbxMesh -- cast for intellisense
        self._em:SetUV(id, to_rbx_vec2(uv))
    end

    function bridge:SetVertexNormal(id: number, n: V3): ()
        local self = self :: _Bridge & IRbxMesh -- cast for intellisense
        self._em:SetVertexNormal(id, to_rbx_vec3(n))
    end

    function bridge:for_each_vtx(fn: (number, _Vertex) -> ()): ()
        local self = self :: _Bridge & IRbxMesh -- cast for intellisense
        for _, i in ipairs(self._em:GetVertices()) do
            fn(i, {
                p = self:GetPosition(i),
                n = self:GetVertexNormal(i),
                uv = self:GetUV(i),
            })
        end
    end

    function bridge:for_each_tri(fn: (number, _Triangle) -> ()): ()
        local self = self :: _Bridge & IRbxMesh -- cast for intellisense
        for _, i in ipairs(self._em:GetTriangles()) do
            local a, b, c = self:GetTriangleVertices(i)
            fn(i, {
                a = a,
                b = b,
                c = c,
            })
        end
    end

    return bridge :: IRbxMesh
end

return rbx
