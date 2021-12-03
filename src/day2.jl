#=
day1:
- Julia version: 1.5.2
- Author: Paul.Mealor
- Date: 2020-12-01
=#

using AoC



step(pos, line::AbstractString) = step(pos, parseLine(line, String, Int)...)
step(pos, direction, distance) = step(pos, Val(Symbol(direction)), distance)
step(pos, ::Val{:forward},distance) = pos + [1,0,0]*distance + [0,1,0]*pos[3]*distance
step(pos, ::Val{:up}, distance) = pos + [0,0,1]*distance
step(pos, ::Val{:down},distance) = pos + [0,0,-1] * distance

function exec(lines)
    pos=[0,0,0]
    for line in lines
        pos = step(pos, line)
    end
    return pos[1:2]
end

show(exampleLines(2,1   ) |> ll -> @time exec(ll))
show(lines(2) |> ll -> @time exec(ll))
show(exampleLines(2,1) |> ll -> @time *(exec(ll)...))
show(lines(2) |> ll -> @time *(exec(ll)...))
