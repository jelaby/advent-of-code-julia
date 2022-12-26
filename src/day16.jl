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
    neighbours::Vector{AbstractString}
end

struct Location
    valve::Valve
    path::Set{Valve}
end
Location(valve) = Location(valve, Set())
Location(valve, path) = Location(valve, Set{Valve}(path))

struct State
    locations::Vector{Location}
    valvesOpen::Set{Valve}
    released::Int
end

parseValve(line) = match(r"Valve (..) has flow rate=(\d+); tunnels? leads? to valves? (.*)", line).captures |>
    parts -> Valve(parts[1], parse(Int,parts[2]), split(parts[3],", "))
parseValves(lines) = parseValve.(lines) |>
    valves -> Dict([valve.name => valve for valve in valves])


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

    for neighbour in [valves[n] for n in location.valve.neighbours]
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

@test part1(example1) == 1651
@test part2(example1) == 1707

println("Calculating...")
part1Result = part1(lines)
@time println(part1(lines))
part2Result = part2(lines)
@time println(part2Result)
@test part1Result == 2080
@test part2Result != 2685
