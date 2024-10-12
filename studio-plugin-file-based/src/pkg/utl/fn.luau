local fn = {}

function fn.chain_if_nil<T, U...>(...: (U...) -> T?): (U...) -> T?
    local fns = table.pack(...)
    return function(...: U...): T?
        for i = 1, fns.n do
            local rtn = fns[i](...)
            if rtn ~= nil then
                return rtn
            end
        end
        return nil
    end
end

return fn
