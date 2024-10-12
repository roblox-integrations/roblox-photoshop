local slice = {}

export type Slice<T> = {
    _arr: { [number]: T },
    _i: number,
    _n: number
}

function slice.new<T>() end

return slice
