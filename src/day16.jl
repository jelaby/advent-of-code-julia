#=
day16:
- Julia version: 1.8.3
- Author: Paul.Mealor
- Date: 2022-12-16
=#
using Test
using Base.Iterators
using Memoize
using AutoHashEquals
include("AoC.jl")

lines = open(readlines, "src/day16-input.txt")
example1 = open(readlines, "src/day16-example-1.txt")

@auto_hash_equals struct Valve
    name::AbstractString
    flowRate::Int
    neighbours::Vector{AbstractString}
end

@auto_hash_equals struct Location
    valve::Valve
    path::Set{Valve}
end
Location(valve) = Location(valve, Set())
Location(valve, path) = Location(valve, Set{Valve}(path))

@auto_hash_equals struct State
    locations::Vector{Location}
    valvesOpen::Set{Valve}
    released::Int
end

parseValve(line) = match(r"Valve (..) has flow rate=(\d+); tunnels? leads? to valves? (.*)", line).captures |>
    parts -> Valve(parts[1], parse(Int,parts[2]), split(parts[3],", "))
parseValves(lines) = parseValve.(lines) |>
    valves -> Dict([valve.name => valve for valve in valves])

moveTime(valves, start::Valve, finish::Valve) = moveTime(valves, start.name, finish.name)
@memoize function moveTime(valves, start::AbstractString, finish::AbstractString)
    return AoC.astar(start,
        (current,_) -> valves[current].neighbours,
        (current,_) -> current==finish,
        (_,_) -> 1,
        (current,neighbour,_)->1)
end
@memoize function reconstructPath(valves, t)
    path = AoC.reconstructAstar(t)
    return collect([valves[v] for v in path])
end

@memoize worthwhileValves(valves) = Set(filter(collect(values(valves))) do valve; valve.flowRate > 0; end)

"""
Find all the valves worth moving to in the remaining time
(this is the list
"""
reachableInCache=Dict{Tuple{UInt,Set{Valve},Valve,Int},Set{Valve}}()
function reachableIn(valves, alreadyVisited, start::T, timeLeft) where T
    return get!(reachableInCache, (objectid(valves), alreadyVisited, start, timeLeft)) do
        doReachableIn(valves, alreadyVisited, start, timeLeft)
    end
end

function doReachableIn(valves, alreadyVisited, start::T, timeLeft) where T
    @assert valtype(valves) === eltype(alreadyVisited) "$(eltype(valves)) !== $(eltype(alreadyVisited))"
    @assert valtype(valves) === typeof(start) "$(eltype(valves)) !== $(typeof(start))"
    result = Set{T}()
    for valve in setdiff(worthwhileValves(valves), alreadyVisited)
        t = moveTime(valves, start, valve)
        if t !== nothing && t.g <= timeLeft
            union!(result, reconstructPath(valves, t))
        elseif t===nothing
            println("No path at all from $(start) to $(valve)")
        end
    end
    return result
end

function withElement(list, n, value)
    result = copy(list)
    result[n] = value
    return result
end

nextStates(valves, state, timeLeft) = nextStates(valves, state, 1, timeLeft)

function nextStates(valves, state, n, timeLeft)
    if !checkbounds(Bool, state.locations, n)
        return [state]
    end

    result = State[]

    location = state.locations[n]

    if location.valve.flowRate > 0 && location.valve ∉ state.valvesOpen
        append!(result, nextStates(valves,
            State(
                withElement(state.locations, n, Location(location.valve,[])),
                Set([state.valvesOpen..., location.valve]),
                state.released + (timeLeft-1) * location.valve.flowRate),
            n + 1,
            timeLeft))
    end

    valvesWorthTrying = reachableIn(valves, state.valvesOpen, location.valve, timeLeft - 1)

    for neighbour in [valves[n] for n in location.valve.neighbours] ∩ valvesWorthTrying
        if neighbour ∉ location.path
            append!(result, nextStates(valves,
                State(
                    withElement(state.locations, n, Location(neighbour,[location.path...,location.valve])),
                    state.valvesOpen,
                    state.released),
                n+1,
                timeLeft))
        end
    end

    if isempty(result)
        return [state]
    end

    return result
end

function totalReleased(valves, start, totalTime, n)
    states = [State([Location(valves[start]) for _ in 1:n],Set(),0)]

    for timeLeft in totalTime:-1:1
        @show timeLeft
        states = collect(flatten([nextStates(valves, state, timeLeft) for state in states]))
        for state in states
            sort!(state.locations, by=l->l.valve.name)
        end
        states = Set(states)
        states = collect(states)
        result,i = findmax(s->s.released, states)
        println("$(length(states)) $(result) $(states[i])")
    end

    result,i = findmax(states) do state
        state.released
    end

    @show states[i]

    return result
end

part1(lines) = parseValves(lines) |> valves -> totalReleased(valves, "AA", 30, 1)
part2(lines) = parseValves(lines) |> valves -> totalReleased(valves, "AA", 26, 2)

@time @test part1(example1) == 1651
@time @test part2(example1) == 1707

println("Calculating...")
part1Result = part1(lines)
@time println(part1(lines))
part2Result = part2(lines)
@time println(part2Result)
@test part1Result == 2080
@test part2Result != 2685
