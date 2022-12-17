#=
day16:
- Julia version: 1.8.3
- Author: Paul.Mealor
- Date: 2022-12-16
=#
using Test
using Base.Iterators
using Memoize
include("AoC.jl")

lines = open(readlines, "src/day16-input.txt")
example1 = open(readlines, "src/day16-example-1.txt")

struct Valve
    name::AbstractString
    flowRate::Int
    targets::Vector{AbstractString}
end

parseValve(line) = match(r"Valve (..) has flow rate=(\d+); tunnels? leads? to valves? (.*)", @show line).captures |>
    parts -> Valve(parts[1], parse(Int,parts[2]), split(parts[3],", "))
parseValves(lines) = parseValve.(lines) |>
    valves -> Dict([valve.name => valve for valve in valves])


function cost(valves, start::T) where T
    allValves = collect(keys(valves))

    @memoize function movetime(valves, start, finish)
        return AoC.astar(start,
            (current,_) -> valves[current].targets,
            (current,_) -> current==finish,
            (current) -> 1,
            (current,neighbour,_)->1).g + 1
    end

    function neighbours(current,cameFrom)
        unvisited = allValves
        prev = get(cameFrom,current,nothing)
        while prev !== nothing
            setdiff!(unvisited, [prev])
            prev = get(cameFrom,prev,nothing)
        end
        setdiff!(unvisited, [current])

        return unvisited;
    end

    function pathhere(current::T,cameFrom) where T
        result = T[]
        prev = get(cameFrom,current,nothing)
        while prev !== nothing
            push!(result, prev)
            prev = get(cameFrom,prev,nothing)
        end
        push!(result, current)

        return result
    end

    function movetimehere(current::T,cameFrom) where T
        path = pathhere(current,cameFrom)
        result = 0
        for i in 1:length(path)-1
            result += movetime(valves, path[i], path[i+1])
        end
        return @show result
    end

    function isfinish(current,cameFrom)
        movetimehere(current,cameFrom) >= 30
    end

    # the amount saved while covering the distance, for all the closed valves
    function distance(current,neighbour,camefrom)
        @show current,neighbour,camefrom
        return @show movetime(valves,current,neighbour) * -sum([valves[valve].flowRate for valve in pathhere(current,camefrom)])
    end

    return AoC.astar(start,
        neighbours,
        isfinish,
        current -> typemin(Int),
        distance,
        )
end


part1(lines) = parseValves(lines) |> valves -> cost(valves, "AA")


@test part1(example1) == 1651

println("Calculating...")
@time println(part1(lines))
