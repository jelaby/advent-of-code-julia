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

@enum Material ore=1 clay=2 obsidian=3 geode=4
@show const MATERIALS = Int(typemax(Material))

struct Robot
    type::Material
    cost::Vector{Int}
end
function Robot(type, costs::Pair...)
    costArray = fill(0, MATERIALS)
    for cost in costs
        costArray[Int(cost.first)] = cost.second
    end
    return Robot(type, costArray)
end

struct Blueprint
    number::Int
    robots::Vector{Robot}
end
Blueprint(number, robots...) = Blueprint(number, [robots...])

parseBlueprint(line) = match(r"Blueprint (\d+): Each ore robot costs (\d+) ore. Each clay robot costs (\d+) ore. Each obsidian robot costs (\d+) ore and (\d+) clay. Each geode robot costs (\d+) ore and (\d+) obsidian.", line).captures |>
    captures -> parse.(Int, captures) |>
    captures -> Blueprint(captures[1], Robot(ore, ore=>captures[2]), Robot(clay, ore=>captures[3]), Robot(obsidian, ore=>captures[4], clay=>captures[5]), Robot(geode, ore=>captures[6], obsidian=>captures[7]))

parseBlueprints(lines) = parseBlueprint.(lines)
exampleBlueprints = parseBlueprints(example1)


function asArray(robots::Vector{Pair{Material,Int}})
    result = fill(0,MATERIALS)
    for robot in robots
        result[Int(robot.first)] = robot.second
    end
    return result
end
asArray(robots::Vector{Int}) = robots

maxCreated(blueprint, target, robots, timeLeft) = maxCreated(blueprint, target, asArray(robots), timeLeft)
@memoize Dict function maxCreated(blueprint, target, robots::Vector{Int}, timeLeft, materials=fill(0,MATERIALS))

    if timeLeft <= 0
        return materials[Int(target)]
    end

    nextMaterials = materials .+ robots

    result = maxCreated(blueprint, target, robots, timeLeft - 1, materials .+ robots)

    for robot in blueprint.robots
        if all(m->materials[m] >= robot.cost[m], eachindex(robot.cost))
            nextMaterials = materials .+ robots .- robot.cost
            nextRobots = copy(robots)
            nextRobots[Int(robot.type)] += 1
            result = max(result, maxCreated(blueprint, target, nextRobots, timeLeft - 1, nextMaterials))
        end
    end

    return result
end



@test maxCreated(exampleBlueprints[1], geode, [ore=>1], 24) == 9
@test maxCreated(exampleBlueprints[2], geode, [ore=>1], 24) == 12
@test quality(exampleBlueprints[1], geode, [ore=>1], 24) == 9
@test quality(exampleBlueprints[2], geode, [ore=>1], 24) == 24
@test quality(exampleBlueprints, geode, [ore=>1], 24) == 33

@time @test part1(example1) == 33

println("Calculating...")
@time println(part1(input))
