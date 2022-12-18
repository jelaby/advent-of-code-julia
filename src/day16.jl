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
    maxTotalReleasedPerMinute=sum([valve.second.flowRate for valve in valves])

    return (current,neighbour,cameFrom) -> begin
        @show current,neighbour,cameFrom
        if neighbour === NO_VALVE_NAME
            return 0
        end
        time = movetime(valves,current,neighbour)
        totalReleasedPerMinute = sum([valves[valve].flowRate for valve in pathhere(current,cameFrom)])
        @show current,neighbour,cameFrom,time,maxTotalReleasedPerMinute,totalReleasedPerMinute
        return @show time * (maxTotalReleasedPerMinute-totalReleasedPerMinute)
    end
end

valvesWorthVisiting(valves) = sort(collect(filter(keys(valves)) do valve
    valves[valve].flowRate > 0
end), by=valve->valves[valve].flowRate)

function totalReleased(valves, previous, valvesToVisit=valvesWorthVisiting(valves), releaseRate=0, totalTime=0, pathHere=[])
    valvesToVisit = setdiff(valvesToVisit, [previous])
    if totalTime >= 30
        result = 0
    elseif isempty(valvesToVisit)
        result = (30-totalTime) * releaseRate
    else
        result = maximum(valvesToVisit) do valve
            time = max(0, min(30 - totalTime, movetime(valves, previous, valve)))
            amountReleasedMoving = releaseRate * time
            amountReleasedAfterwards = totalReleased(valves, valve, valvesToVisit, releaseRate + valves[valve].flowRate, totalTime + time, [pathHere..., previous])
            return amountReleasedMoving + amountReleasedAfterwards
        end
    end
    return result
end


part1(lines) = parseValves(lines) |> valves -> totalReleased(valves, "AA")


@test part1(example1) == 1651

println("Calculating...")
@time println(part1(lines))
