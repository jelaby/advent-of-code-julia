#=
day12:
- Julia version: 1.8.3
- Author: Paul.Mealor
- Date: 2022-12-12
=#
using Test

lines = open(readlines, "src/day12-input.txt")
example1 = open(readlines, "src/day12-example-1.txt")

parseMap(lines) = reshape([c for line in lines for c in line], length(lines[1]), length(lines))

const RIGHT = CartesianIndex((1,0))
const LEFT = CartesianIndex((-1,0))
const UP = CartesianIndex((0,-1))
const DOWN = CartesianIndex((0,1))

const UNVISITED = 10000002
const CALCULATING = 10000004
const UNREACHABLE = 10000008
const DEAD_END = 10000006

function blankResults(map, from)
    results = fill(UNVISITED, size(map))
    results[from] = 0
    return results
end

h(start, finish) = sum(abs.(Tuple(start-finish)))

function shortestJourney(map, start, finish)
    openSet = Set([start])

    cameFrom = Dict{CartesianIndex, CartesianIndex}()

    gScore = fill(typemax(Int), size(map))
    gScore[start] = 0

    fScore = fill(typemax(Int), size(map))
    fScore[start] = h(start, finish)

    while !isempty(openSet)

         current = undef
         currentScore = typemax(Int)
         for candidate in openSet
            if fScore[candidate] < currentScore
                current = candidate
                currentScore = fScore[candidate]
            end
        end

        if current == finish
            return gScore[finish]
        end

        delete!(openSet, current)

        for direction in [LEFT, RIGHT, UP, DOWN]
            neighbour = current + direction

            if checkbounds(Bool, map, neighbour) && map[current] + 1 >= map[neighbour]

                tentativeGScore = gScore[current] + 1
                if tentativeGScore < gScore[neighbour]
                    cameFrom[neighbour] = current
                    gScore[neighbour] = tentativeGScore
                    fScore[neighbour] = tentativeGScore + h(neighbour, finish)
                    push!(openSet, neighbour)
                end
            end
        end
    end

end

function shortestJourney(map; startHeight='a', endHeight='z')
    start = findStart(map)
    finish = findEnd(map)
    map[start] = startHeight
    map[finish] = endHeight
    @show map, start, finish
    return shortestJourney(map, start, finish)
end

findStart(map) = findfirst(c -> c=='S', map)
findEnd(map) = findfirst(c -> c=='E', map)

part1 = shortestJourney ∘ parseMap

@test shortestJourney(parseMap([
"SgE",
"bgf",
"cde"
]); endHeight='g') == 6

@test part1(["SbcdefghijklmnopqrstuvwxyE"]) == 25
@test part1(["SbcdefghijklmnopqrstuvwxyzzzE"]) == 28
@test part1([
"SbcdefghijklmnopqrstuvwxyE",
"abcdefghijklmnopqrstuvwxyz"
]) == 25
@test part1([
"SbcdefghijklmoopqrstuvwxyE",
"abcdefghijklmnopqrstuvwxyz"
]) == 27
@test part1([
"SbcdefghijklmmmpqrstuvwxyE",
"abcdefghijklmnopqrstuvwxyz"
]) == 27
@test part1([
"SbcdefghijklmmmmqrstuvwxyE",
"abcdefghijklmnopqqqquvwxyz"
]) == 27
@test part1([
"SbcdefgzijkzmnozqrstuvwxyE",
"abcdezghizklmzopqrstuvwxyz",
"abcdezzzzzzzzzzzqrstuvwxyz",
"abcdefghijklmnopqrstuvwxyz",
]) == 31
@test part1(example1) == 31

println("Calculating...")
@time println(part1(lines))
