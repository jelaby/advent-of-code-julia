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

parseValve(line) = match(r"Valve (..) has flow rate=(\d+); tunnels? leads? to valves? (.*)", line).captures |>
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

valvesWorthVisiting(valves) = sort!(collect(filter(keys(valves)) do valve
    valves[valve].flowRate > 0
end), by=valve->-valves[valve].flowRate)

struct Movement
    target::AbstractString
    time::Int
end

hasArrived(m) = m.time<=0

function totalReleased(valves, current, valvesToVisit=valvesWorthVisiting(valves); maxTime=30, totalPeople=1)
    valvesToVisit=valvesWorthVisiting(valves)

    return totalReleased(valves, fill(Movement(current,0), totalPeople), valvesToVisit, 0, 0, [:start]; maxTime)
end
trCache = Dict()
function totalReleased(valves, movements::Vector{Movement}, valvesToVisit, releaseRate, totalTime, pathHere; maxTime)
    key = (objectid(valves),sort(movements,by=m->m.target),valvesToVisit,releaseRate,totalTime,maxTime)
    return get!(trCache, key) do
        return doTotalReleased(valves,movements,valvesToVisit,releaseRate,totalTime,pathHere;maxTime)
    end
end

function doTotalReleased(valves, movements::Vector{Movement}, valvesToVisit, releaseRate, totalTime, pathHere; maxTime)

    if totalTime >= maxTime
        #@show :overtime,totalTime,maxTime,pathHere,0
        return 0
    elseif isempty(valvesToVisit) && all(hasArrived, movements)
        result = (maxTime-totalTime) * releaseRate
        #@show :complete,totalTime,releaseRate,pathHere,result
        return result
    else
        if all(m->!hasArrived(m), movements) || isempty(valvesToVisit)
            time = minimum(m->m.time, filter(m->!hasArrived(m), movements))

            extraFlow = sum(m->valves[m.target].flowRate, filter(m->0 < m.time <= time, movements))

            amountReleasedMoving = releaseRate * time
            amountReleasedAfterwards = totalReleased(valves,
                [Movement(m.target, m.time - time) for m in movements],
                valvesToVisit,
                releaseRate+extraFlow,
                totalTime + time,
                [pathHere...,:go];
                maxTime)
            result = amountReleasedMoving + amountReleasedAfterwards
            #@show :movement, movements, releaseRate,totalTime,pathHere,result
            return result

        else
            i = findfirst(hasArrived, movements)
            movement = movements[i]

            if isempty(valvesToVisit)
                #@show :error, movements, releaseRate,totalTime,pathHere
            end
            result = foldl(valvesToVisit; init=0) do best,valve
                newMovements = copy(movements)
                time = max(0, min(maxTime - totalTime, movetime(valves, movement.target, valve)))
                newMovements[i] = Movement(valve, time)

                # exclude moving to a valve if that can't possibly help us
                # by assuming that all valves will be opened with the next action
                nextActionTime = max(0,minimum(m->m.time, newMovements))
                totalPeople = length(movements)
                optimisticFlow = releaseRate * (maxTime-totalTime) +
                    reduce((+), [sum(v->valves[v].flowRate, valvesToVisit[i:min(length(valvesToVisit), i+totalPeople-1)]) * (maxTime-totalTime-nextActionTime-2i) for i in 1:(min((maxTime-totalTime-nextActionTime-2) ÷ (2*totalPeople), length(valvesToVisit)))]; init=0)
                if optimisticFlow < best
                    return best
                end

                result = totalReleased(valves, newMovements, filter(v->v!=valve, valvesToVisit), releaseRate, totalTime, [pathHere...,i=>valve]; maxTime)
                return max(best,result)
            end
            #@show :setup, movements, releaseRate,totalTime,pathHere, result
            return result
        end
    end
end


part1(lines) = parseValves(lines) |> valves -> totalReleased(valves, "AA")
part2(lines) = parseValves(lines) |> valves -> totalReleased(valves, "AA", maxTime=26, totalPeople=2)

@test part1(example1) == 1651
@test part2(example1) == 1707

println("Calculating...")
@time println(part1(lines))
@time println(part2(lines))
