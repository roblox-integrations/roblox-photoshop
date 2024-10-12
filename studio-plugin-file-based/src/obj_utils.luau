local conv = require(script.Parent.pkg.conv)
local obj = require(script.Parent.pkg.obj)
local rbx = require(script.Parent.pkg.rbx)

local obj_utils = {}

function obj_utils.parse_obj(data: string): EditableMesh?
    local os, err = obj.parse(data)
    if err ~= nil then
        print(err)
        return
    end
    if os == nil or #os < 0 then
        print("error parsing obj, array was nil or empty")
    end

    local em = Instance.new("EditableMesh")
    local iem = rbx.new_mesh_bridge(em)

    err = conv.obj_to_rbx(os[1], iem)
    if err ~= nil then
        print(err)
        return
    end

    return em
end

return obj_utils
