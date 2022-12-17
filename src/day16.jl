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

const NO_VALVE_NAME = "NONE"
const NO_VALVE = Valve(NO_VALVE_NAME,0,[])

parseValve(line) = match(r"Valve (..) has flow rate=(\d+); tunnels? leads? to valves? (.*)", @show line).captures |>
    parts -> Valve(parts[1], parse(Int,parts[2]), split(parts[3],", "))
parseValves(lines) = parseValve.(lines) |>
    valves -> Dict([valve.name => valve for valve in valves])


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

function neighbours(valves)
    @show allValves = collect(filter(k->valves[k].flowRate > 0, keys(valves)))
    return (current,cameFrom) -> begin
        result = setdiff(allValves, pathhere(current, cameFrom))
        if isempty(result)
            return [NO_VALVE_NAME]
        else
            return result
        end
    end
end

@memoize function movetime(valves, start, finish)
    return AoC.astar(start,
        (current,_) -> valves[current].targets,
        (current,_) -> current==finish,
        (_,_) -> 1,
        (current,neighbour,_)->1).g + 1
end

function movetimehere(valves,current,cameFrom)
    path = pathhere(current,cameFrom)
    result = 0
    for i in 1:length(path)-1
        result += movetime(valves, path[i], path[i+1])
    end
    return @show result
end

function isfinish(valves)
    return (current,cameFrom) -> current === NO_VALVE_NAME || movetimehere(valves,current,cameFrom) >= 30
end

function heuristic(valves)
    maxRelease=sum([valve.second.flowRate for valve in valves])
    return (current, cameFrom) -> typemin(Int) + (current == NO_VALVE_NAME ? 0 : maxRelease - valves[current].flowRate)
end

# the amount saved while covering the distance, for all the closed valves
function distance(valves)
    return (current,neighbour,cameFrom) -> begin
        time = neighbour === NO_VALVE_NAME ? 30-movetimehere(valves,current,cameFrom) : movetime(valves,current,neighbour)
        @show current,neighbour,cameFrom,time
        return time * -sum([valves[valve].flowRate for valve in pathhere(current,cameFrom)])
    end
end

function cost(valves, start::T) where T
    allValves = collect(keys(valves))

    return AoC.astar(start,
        neighbours(valves),
        isfinish(valves),
        heuristic(valves),
        distance(valves))
end


part1(lines) = parseValves(lines) |> valves -> cost(valves, "AA")


@test part1(example1) == 1651

println("Calculating...")
@time println(part1(lines))
