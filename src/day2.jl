#=
day1:
- Julia version: 1.5.2
- Author: Paul.Mealor
- Date: 2020-12-01
=#

import AoC



step(pos, direction, distance) = step(pos, Val(Symbol(direction)), distance)
step(pos, ::Val{:forward},distance) = step(pos, [1,0],distance)
step(pos, ::Val{:up}, distance) = step(pos, [0,1],distance)
step(pos, ::Val{:down},distance) = step(pos, [0,-1],distance)
step(pos, dir::AbstractVector, distance) = step(pos, dir * distance)
step(pos, vec::AbstractVector) = pos + vec
step(pos, line::AbstractString) = step(pos, split(line, r"\s+")...)
step(pos, dir, distance::AbstractString) = step(pos, dir, parse(Int, distance))

function exec(lines)
    pos=[0,0]
    for line in lines
        pos = step(pos, line)
    end
    return pos
end

show(AoC.exampleLines(2,1) |> ll -> @time *(exec(ll)...))
show(AoC.lines(2) |> ll -> @time *(exec(ll)...))
