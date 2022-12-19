#=
day17:
- Julia version: 1.8.3
- Author: Paul.Mealor
- Date: 2022-12-17
=#
using Test
using Base.Iterators
using Memoize
include("AoC.jl")

input = open(readlines, "src/day17-input.txt")[1]
example1 = open(readlines, "src/day17-example-1.txt")[1]

const ROCKS = [
    [(0,0),(1,0),(2,0),(3,0)],
    [(1,0),(0,1),(1,1),(2,1),(1,2)],
    [(0,0),(1,0),(2,0),(2,1),(2,2)],
    [(0,0),(0,1),(0,2),(0,3)],
    [(0,0),(1,0),(0,1),(1,1)],
]

const LEFT = (-1,0)
const RIGHT = (1,0)
const DOWN = (0,-1)

@memoize maxX(shape) = maximum(p->p[1], shape)
@memoize maxY(shape) = maximum(p->p[2], shape)

intersects(chamber,rock,position) = any(bit -> position.+bit ∈ chamber, rock)

parseWind(line) = [c == '<' ? LEFT : RIGHT for c in line]
@test parseWind("<><<") == [LEFT,RIGHT,LEFT,LEFT]

windExample1 = parseWind(example1)

function rockFall(chamber,rock,start,wind,windOffset)
    position = start
    while true
        nextPosition = position .+ wind[mod1(windOffset,length(wind))]
        windOffset+=1
        if 1 <= nextPosition[1] <= 7 - maxX(rock) && !intersects(chamber, rock, nextPosition)
            position = nextPosition
        end

        nextPosition = position .+ DOWN

        if nextPosition[2] < 1 || intersects(chamber, rock, nextPosition)
            return (position,windOffset)
        end

        position = nextPosition
    end
end

function solidify!(chamber, rock, position)
    rock .|> (bit -> bit .+ position) .|> bit -> push!(chamber, bit)
    return chamber
end
@test solidify!(Set{Tuple{Int,Int}}(), [(0,0), (1,1), (2,1)], (2,5)) == Set([(2,5),(3,6),(4,6)])

function rockFall!(chamber,rock,start,wind,windOffset)
    (position,windOffset) = rockFall(chamber,rock,start,wind,windOffset)
    solidify!(chamber,rock,position)
    return (position,windOffset)
end
testChamber = Set()
@test rockFall!(testChamber, ROCKS[1], (3,4), windExample1, 1) == ((3,1), 5)
@test rockFall!(testChamber, ROCKS[2], (3,5), windExample1, 5) == ((3,2), 9)

function rocksFall(wind,count)
    chamber = Set{Tuple{Int,Int}}()

    top = 0
    windOffset = 1
    for i = 1:count
        rock = ROCKS[mod1(i,length(ROCKS))]
        (position, windOffset) = rockFall!(chamber, rock, (3,top + 4), wind, windOffset)
        top = max(top, position[2] + maxY(rock))
    end

    return top
end
@test rocksFall(windExample1,1) == 1
@test rocksFall(windExample1,2) == 4
@test rocksFall(windExample1,3) == 6
@test rocksFall(windExample1,4) == 7
@test rocksFall(windExample1,5) == 9
@test rocksFall(windExample1,6) == 10
@test rocksFall(windExample1,7) == 13
@test rocksFall(windExample1,8) == 15
@test rocksFall(windExample1,9) == 17
@test rocksFall(windExample1,10) == 17

part1(input) = parseWind(input) |> wind -> rocksFall(wind, 2022)

@test part1(example1) == 3068

println("Calculating...")
@time println(part1(input))
