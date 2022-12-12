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

function shortestJourney(map, from, to, height='z', results = blankResults(map, from), best=length(map))
        #show map, from, to, height, results, best
    if !checkbounds(Bool, map, to)
        #show :outofbounds, results
        return UNREACHABLE
    elseif map[to] + 1 < height
        #show :unreachable,results,to,map[to],height
        return UNREACHABLE
    elseif results[to] == CALCULATING
        #show :loop,results,to
        return CALCULATING
    elseif results[to] == DEAD_END
        #show :deadend, results
        return DEAD_END
    elseif results[to] == UNVISITED
        results[to] = CALCULATING
        cost = minimum([shortestJourney(map, from, to+direction, map[to], results) for direction in [RIGHT, DOWN, LEFT, UP]])
        if cost == CALCULATING
            cost = UNVISITED
        elseif cost == UNREACHABLE
            cost = DEAD_END
        elseif cost == UNVISITED
            cost = UNVISITED
        elseif cost == DEAD_END
            cost = DEAD_END
        else
            cost = cost + 1
        end
        results[to] = cost
        #show :calculate, results,to,cost
        return cost
    else
        #show :cached,results
        return results[to]
    end
end

function shortestJourney(map; startHeight='a', endHeight='z')
    start = findStart(map)
    finish = findEnd(map)
    map[start] = startHeight
    map[finish] = endHeight
    @show map, start, finish
    return shortestJourney(map, start, finish, endHeight)
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
