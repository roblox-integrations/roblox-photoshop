local iter = {}

---Execute predicate on all elements
---@generic T
---@param list T[]
---@param p fun(v:T):nil
function iter.for_each<T>(list: { [number]: T }, p: (T) -> nil)
    for _, v in ipairs(list) do
        p(v)
    end
end

---Return an array starting a [s] of length n (or length #list-s if n is nil)
function iter.slice<T>(list: { [number]: T }, s: number, n: number?): { [number]: T }
    local e = if n == nil then #list else s + n - 1
    local slice = {}
    for i = s, e do
        table.insert(slice, list[i])
    end
    return slice
end

---Filter a list
---@generic T
---@param list table<number, T>
---@param p fun(v:T):boolean
---@return table<any, T>
function iter.filter<T>(list: { [number]: T }, p: (T) -> boolean): { [number]: T }
    local filtered = {}
    for _, v in ipairs(list) do
        if p(v) then
            table.insert(filtered, v)
        end
    end
    return filtered
end

---Map values in a list
---@generic T, U
---@param list T[]
---@param p fun(v:T):U
---@return U[]
function iter.map<T, U>(list: { [number]: T }, p: (T) -> U): { [number]: U }
    local mapped = {}
    for i, v in ipairs(list) do
        mapped[i] = p(v)
    end
    return mapped
end

---Join two lists into a list of 2-value lists
---List will have length of first list passed in
---If second list is shorter, pairs of {v, nil} are created
---@generic T, U
---@param list T[]
---@param other U[]
---@return {a: T, b: U}[]
function iter.zip<T, U>(list: { [number]: T }, other: { [number]: U }): { [number]: { a: T, b: U? } }
    local zipped = {} :: { [number]: { a: T, b: U? } }
    for i, v in ipairs(list) do
        if i <= #other then
            table.insert(zipped, { a = v, b = other[i] })
        else
            table.insert(zipped, { a = v, b = nil })
        end
    end
    return zipped
end

---Fold (reduce) values in list
---@generic T
---@param list T[]
---@param p fun(acc:T, v:T):T
---@return T
function iter.fold<T, U>(list: { [number]: T }, acc_init: U, p: (U, T) -> U): U
    local acc = acc_init
    for _, v in ipairs(list) do
        acc = p(acc, v)
    end
    return acc
end

type AnyChainMonad = {
    for_each: (self: AnyChainMonad, p: (any) -> nil) -> AnyChainMonad,
    slice: (self: AnyChainMonad, s: number, n: number?) -> AnyChainMonad,
    zip: <any>(self: AnyChainMonad, other: { [number]: any }) -> AnyChainMonad,
    filter: (self: AnyChainMonad, p: (any) -> boolean) -> AnyChainMonad,
    map: <any>(self: AnyChainMonad, p: (any) -> any) -> AnyChainMonad,
    -- unwrap the monad
    get: (self: AnyChainMonad) -> { [number]: any },
    fold: (self: AnyChainMonad, acc_init: any, p: (any, any) -> any) -> any
}

type ChainMonad<T> = {
    for_each: (self: ChainMonad<T>, p: (T) -> nil) -> ChainMonad<T>,
    slice: (self: ChainMonad<T>, s: number, n: number?) -> ChainMonad<T>,
    filter: (self: ChainMonad<T>, p: (T) -> boolean) -> ChainMonad<T>,
    -- loses internal type info because of limitations in luau's type solver
    map: <U>(self: ChainMonad<T>, p: (T) -> U) -> AnyChainMonad,
    zip: <U>(self: ChainMonad<T>, other: { [number]: U }) -> AnyChainMonad,
    -- unwrap the monad
    get: (self: ChainMonad<T>) -> { [number]: T },
    fold: <U>(self: ChainMonad<T>, acc_init: U, p: (U, T) -> U) -> U
}

---Monad for chaining iter functions
function iter.chain<T>(v: { [number]: T }): ChainMonad<T>
    local wrapped = {
        _value = v,
    }

    -- chains monad
    function wrapped:for_each(p: (T) -> nil): ChainMonad<T>
        iter.for_each(self._value, p)
        return iter.chain(self._value)
    end
    function wrapped:slice(s: number, n: number?): ChainMonad<T>
        return iter.chain(iter.slice(self._value, s, n))
    end
    function wrapped:filter(p: (T) -> boolean): ChainMonad<T>
        return iter.chain(iter.filter(self._value, p))
    end
    -- return any because of type system limitations
    function wrapped:zip<U>(other: { [number]: U }): AnyChainMonad
        return iter.chain(iter.zip(self._value, other)) :: any
    end
    function wrapped:map<U>(p: (T) -> U): AnyChainMonad
        local res = iter.map(self._value, p)
        return iter.chain(res) :: any
    end

    -- unwrap the monad
    function wrapped:get(): T
        return self._value
    end
    function wrapped:fold<U>(acc_init: U, p: (U, T) -> U): U
        return iter.fold(self._value, acc_init, p)
    end

    return (wrapped :: any) :: ChainMonad<T>
end

return iter
