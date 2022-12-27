#=
day19:
- Julia version: 1.8.3
- Author: Paul.Mealor
- Date: 2022-12-19
=#
using Test
using Base.Iterators
using Memoize
include("AoC.jl")

input = open(readlines, "src/day19-input.txt")
example1 = open(readlines, "src/day19-example-1.txt")

@enum Material ore=4 clay=3 obsidian=2 geode=1
@show const MATERIALS = Int(typemax(Material))

Base.getindex(A::AbstractArray,i::Material) = getindex(A,Int(i))
Base.setindex!(A::AbstractArray,x,i::Material) = setindex!(A,x,Int(i))

struct Robot
    type::Material
    cost::Vector{Int}
end
function Robot(type, costs::Pair...)
    costArray = fill(0, MATERIALS)
    for cost in costs
        costArray[cost.first] = cost.second
    end
    return Robot(type, costArray)
end
Base.:(==)(a::Robot,b::Robot) = a.type == b.type && a.cost == b.cost
Base.hash(robot::Robot) = hash(robot.type, hash(robot.cost, hash(:Robot)))

struct Blueprint
    number::Int
    robots::Vector{Robot}
end
Blueprint(number, robots...) = Blueprint(number, [robots...])
Base.:(==)(a::Blueprint,b::Blueprint) = a.number == b.number && a.robots == b.robots
Base.hash(b::Blueprint) = hash(b.number, hash(b.robots, hash(:Blueprint)))

parseBlueprint(line) = match(r"Blueprint (\d+): Each ore robot costs (\d+) ore. Each clay robot costs (\d+) ore. Each obsidian robot costs (\d+) ore and (\d+) clay. Each geode robot costs (\d+) ore and (\d+) obsidian.", line).captures |>
    captures -> parse.(Int, captures) |>
    captures -> Blueprint(captures[1], Robot(ore, ore=>captures[2]), Robot(clay, ore=>captures[3]), Robot(obsidian, ore=>captures[4], clay=>captures[5]), Robot(geode, ore=>captures[6], obsidian=>captures[7]))

parseBlueprints(lines) = parseBlueprint.(lines)
exampleBlueprints = parseBlueprints(example1)

function asArray(robots::Vector{Pair{Material,Int}})
    result = fill(0,MATERIALS)
    for robot in robots
        result[robot.first] = robot.second
    end
    return result
end
asArray(robots::Vector{Int}) = robots
@test asArray([ore=>2,obsidian=>3])[Int(ore)] == 2
@test asArray([ore=>2,obsidian=>3])[Int(clay)] == 0
@test asArray([ore=>2,obsidian=>3])[Int(obsidian)] == 3
@test asArray([ore=>2,obsidian=>3])[Int(geode)] == 0

function maxRequired(blueprint, target)
    result = fill(0, MATERIALS)

    for robot in blueprint.robots
        result = max.(result, robot.cost)
    end

    result[target] = typemax(eltype(result))

    return result
end

struct State
    robots::Vector{Int}
    materials::Vector{Int}
end
Base.:(==)(a::State,b::State) = a.robots == b.robots && a.materials == b.materials
Base.hash(state::State) = hash(state.robots, hash(state.materials, hash(:State)))

function copyAndAdd(A, n, v)
    R = copy(A)
    R[n] += v
    return R
end

function nextStates(blueprint, target, state, maxRobots)

    nextMaterials = state.materials .+ state.robots
    result = State[]

    couldWait = false


    for r in blueprint.robots
        if state.robots[r.type] < maxRobots[r.type]
            if all(r.cost .<= state.materials)
            #if all(r.cost .<= state.materials) && any(r.cost .> 0 .&& state.materials .- state.robots .< r.cost .< state.materials .+ state.robots)
                push!(result, State(copyAndAdd(state.robots, r.type, 1), nextMaterials .- r.cost))
            elseif all(state.robots .> 0 .|| r.cost .== 0)
                couldWait = true
            end
        elseif state.robots[target] > 0
            couldWait = true
        end
    end

    if couldWait
        push!(result, State(state.robots,nextMaterials))
    end

    return result
end

triangular(n::Int) = (n^2 + n) ÷ 2

function maxCreated(blueprint, target, robots, timeLeft)
    robots = asArray(robots)

    states = Set([State(robots, fill(0,MATERIALS))])

    maxima = maxRequired(blueprint, target)

    for t in timeLeft:-1:1
        states = Set(flatten([nextStates(blueprint, target, state, maxima) for state in states]))

        best = maximum(states) do state; state.materials[target]; end
        if best > 0
            filter!(states) do state
                state.materials[target] + triangular(timeLeft-1) >= best
            end

            if length(states) > 1_000_000
                states = sort!(collect(states), by=state -> state.materials[target], rev=true)[1:1_000_000]
            end
        end

        println("$(t) $(length(states))")
    end

    return @show maximum(states) do state; state.materials[target]; end
end

@show maxCreated(exampleBlueprints[1], geode, [ore=>1], 3)
@show maxCreated(exampleBlueprints[1], geode, [ore=>1], 4)

quality(blueprint::Blueprint, target, robots, timeLeft) = blueprint.number * maxCreated(blueprint, target, robots, timeLeft)
quality(blueprints::Vector, target, robots, timeLeft) = sum([quality(blueprint, target, robots, timeLeft) for blueprint in blueprints])

part1(lines) = parseBlueprints(lines) |> blueprints -> quality(blueprints, geode, [ore=>1], 24)
function part2(lines)
    blueprints = parseBlueprints(lines)[1:3]
    return *([maxCreated(blueprint, geode, [ore=>1], 32) for blueprint in blueprints]...)
end

#@time @test maxCreated(exampleBlueprints[1], geode, [ore=>1], 18) == 0
#@time @test maxCreated(exampleBlueprints[1], geode, [ore=>1], 19) == 1
#@time @test maxCreated(exampleBlueprints[1], geode, [ore=>1], 24) == 9
#@time @test maxCreated(exampleBlueprints[2], geode, [ore=>1], 24) == 12
#@time @test quality(exampleBlueprints[1], geode, [ore=>1], 24) == 9
#@time @test quality(exampleBlueprints[2], geode, [ore=>1], 24) == 24
#@time @test quality(exampleBlueprints, geode, [ore=>1], 24) == 33
#
#@time @test maxCreated(exampleBlueprints[1], geode, [ore=>1], 32) == 56
#@time @test maxCreated(exampleBlueprints[2], geode, [ore=>1], 32) == 62

#@time @test part1(example1) == 33

println("Calculating...")
#@time result = part1(input)
#println(result)
#@test result > 1490
@time result = part2(input)
println(result)
