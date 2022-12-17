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

isextra(valve::Valve) = isextra(valve.name)
isextra(valve::AbstractString) = match(r"^\d+$", valve) !== nothing
extraValve(valve::Valve) = extraValve(valve.name)
function extraValve(valve::AbstractString)
    if isextra(valve)
        number = parse(Int,valve)
        Valve(string(number+1), 0, [valve,string(number+2)])
    else
        Valve("1",0,["2"])
    end
end

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
            extra = extraValve(current)
            valves[extra.name] = extra
            return [extra.name]
        end
        return result
    end
end

@memoize function movetime(valves, start, finish)
    return AoC.astar(start,
        (current,_) -> get(valves, current, EXTRA).targets,
        (current,_) -> current==finish,
        (_,_) -> 1,
        (current,neighbour,_)->1).g + 1
end

function movetimehere(valves,current::T,cameFrom) where T
    path = pathhere(current,cameFrom)
    result = 0
    for i in 1:length(path)-1
        result += movetime(valves, path[i], path[i+1])
    end
    return @show result
end

function isfinish(valves)
    return (current,cameFrom) -> movetimehere(valves,current,cameFrom) >= 30
end

function heuristic(valves)
    return (current, cameFrom) -> typemin(Int)
end

const EXTRA = Valve("EXTRA", 0, [])

# the amount saved while covering the distance, for all the closed valves
function distance(valves)
    return (current,neighbour,camefrom) -> begin
        @show current,neighbour,camefrom
        return @show movetime(valves,current,neighbour) * -sum([get(valves,valve,EXTRA).flowRate for valve in pathhere(current,camefrom)])
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
