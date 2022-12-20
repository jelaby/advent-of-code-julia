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
Base.:(==)(a::Robot,b::Robot) = a.type == b.type && a.cost == b.cost

struct Blueprint
    number::Int
    robots::Vector{Robot}
end
Blueprint(number, robots...) = Blueprint(number, [robots...])
Base.:(==)(a::Blueprint,b::Blueprint) = a.number == b.number && a.robots == b.robots

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
@test asArray([ore=>2,obsidian=>3])[Int(ore)] == 2
@test asArray([ore=>2,obsidian=>3])[Int(clay)] == 0
@test asArray([ore=>2,obsidian=>3])[Int(obsidian)] == 3
@test asArray([ore=>2,obsidian=>3])[Int(geode)] == 0


function heuristic(blueprint, target, robots, timeleft, materials)
    oreRobotCost = blueprint.robots[Int(ore)].cost[Int(ore)]
    targetRobotCost = blueprint.robots[Int(target)].cost[Int(ore)]

    oreForOreRobots = materials[Int(ore)]
    totalOreRobots = robots[Int(ore)]
    oreForTargetRobots = materials[Int(ore)]
    totalTargetRobots = robots[Int(target)]
    totalTarget = materials[Int(target)]
    for time in 1:timeleft
        oreForOreRobots += totalOreRobots
        newOreRobots = oreForOreRobots ÷ oreRobotCost
        oreForOreRobots -= newOreRobots * oreRobotCost
        totalOreRobots+=newOreRobots

        totalTarget += totalTargetRobots
        oreForTargetRobots += totalOreRobots
        newTargetRobots = oreForTargetRobots ÷ targetRobotCost
        oreForTargetRobots -= newTargetRobots * targetRobotCost
        totalTargetRobots+=newTargetRobots
    end

    return totalTargetRobots
end

function maxRequired(blueprint, target)
    result = fill(0, MATERIALS)

    for robot in blueprint.robots
        result = max.(result, robot.cost)
    end

    return result
end

global theMostGeodes = 0
global sample = 0

@memoize Dict maxCreated(blueprint, target, robots, timeLeft) = maxCreated(blueprint, target, asArray(robots), timeLeft, fill(0,MATERIALS), maxRequired(blueprint,target), 0)

global maxCreatedCache = Dict{Tuple{UInt,Material,Vector{Int},Int,Vector{Int}}, Int}()
function maxCreated(blueprint, target, robots::Vector{Int}, timeLeft, materials, maxRobots, best)
    return get!(maxCreatedCache, (objectid(blueprint),target,robots,timeLeft,materials)) do

    if timeLeft <= 0
        #global theMostGeodes
        #global sample
        #if materials[Int(target)] > theMostGeodes
        #    theMostGeodes = materials[Int(target)]
        #    @show materials[Int(target)],robots,materials,typeof(materials)
        #elseif sample > 100000
        #    sample = 0
        #    @show materials[Int(target)],robots,materials,typeof(materials)
        #else
        #    sample += 1
        #end
        return materials[Int(target)]
    end

    result = 0

    robotCouldBeBuilt = false
    couldBuildByWaiting = false

    for robot in blueprint.robots
        if (robots[Int(robot.type)] < maxRobots[Int(robot.type)] || robot.type==target)
            if all(m->materials[m] >= robot.cost[m], eachindex(robot.cost))
                robotCouldBeBuilt = true

                nextMaterials = materials .+ robots .- robot.cost
                nextRobots = copy(robots)
                nextRobots[Int(robot.type)] += 1

                result = max(result, maxCreated(blueprint, target, nextRobots, timeLeft - 1, nextMaterials, maxRobots, result))
            elseif all(m->materials[m] + (robots[m] * (timeLeft-1)) >= robot.cost[m], eachindex(robot.cost)) #= already true: &&
                   any(m->materials[m] < robot.cost[m], eachindex(robot.cost)) =#
                couldBuildByWaiting = true
            end
        end
    end

    if couldBuildByWaiting
        #println((" "^(30-timeLeft)) * "wait $(robots) $(materials) $(blueprint)")
        result = max(result, maxCreated(blueprint, target, robots, timeLeft - 1, materials .+ robots, maxRobots, result))
    #elseif !robotCouldBeBuilt
    #    println((" "^(30-timeLeft)) * "nowaitnorobot $(timeLeft) $(robots) $(materials) $(blueprint)")
    end

    return result
    end
end

quality(blueprint::Blueprint, target, robots, timeLeft) = blueprint.number * maxCreated(blueprint, target, robots, timeLeft)
quality(blueprints::Vector, target, robots, timeLeft) = sum([quality(blueprint, target, robots, timeLeft) for blueprint in blueprints])

part1(lines) = parseBlueprints(lines) |> blueprints -> quality(blueprints, geode, [ore=>1], 24)

@time @test maxCreated(exampleBlueprints[1], geode, [ore=>1], 18) == 0
@time @test maxCreated(exampleBlueprints[1], geode, [ore=>1], 19) == 1
@time @test maxCreated(exampleBlueprints[1], geode, [ore=>1], 24) == 9
@time @test maxCreated(exampleBlueprints[2], geode, [ore=>1], 24) == 12
@time @test quality(exampleBlueprints[1], geode, [ore=>1], 24) == 9
@time @test quality(exampleBlueprints[2], geode, [ore=>1], 24) == 24
@time @test quality(exampleBlueprints, geode, [ore=>1], 24) == 33

@time @test part1(example1) == 33

empty!(maxCreatedCache)

println("Calculating...")
@time result = part1(input)
println(result)
@test result > 1490
