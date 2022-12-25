#=
day24:
- Julia version: 1.8.3
- Author: Paul.Mealor
- Date: 2022-12-24
=#
using Test
using Base.Iterators
using Memoize
import Random
include("AoC.jl")

input = open(readlines, "src/day24-input.txt")
example1 = open(readlines, "src/day24-example-1.txt")
example2 = open(readlines, "src/day24-example-2.txt")

const LEFT = CartesianIndex(-1,0)
const RIGHT = CartesianIndex(1,0)
const UP = CartesianIndex(0,-1)
const DOWN = CartesianIndex(0,1)

struct Wind
    start::CartesianIndex
    direction::CartesianIndex
end

function parseMap(lines)
    winds = Vector{Wind}()
    xwinds = Dict{Int, Vector{Wind}}()
    ywinds = Dict{Int, Vector{Wind}}()

    for y in eachindex(lines)
        for x in eachindex(lines[y])
            c = lines[y][x]
            I = CartesianIndex(x-1,y-1)
            if c == '<'
                wind = Wind(I,LEFT)
                push!(winds, wind)
                push!(get!(xwinds,y,Vector{Wind}()), wind)
            elseif c == '>'
                wind = Wind(I,RIGHT)
                push!(winds, wind)
                push!(get!(xwinds,y,Vector{Wind}()), wind)
            elseif c == '^'
                wind = Wind(I,UP)
                push!(winds, wind)
                push!(get!(ywinds,x,Vector{Wind}()), wind)
            elseif c == 'v'
                wind = Wind(I,DOWN)
                push!(winds, wind)
                push!(get!(ywinds,x,Vector{Wind}()), wind)
            end
        end
    end
    return (;winds, xwinds, ywinds, dims=CartesianIndex(length(lines[1])-2,length(lines)-2))
end

manhattanDistance(a,b) = manhattanSize(b-a)
manhattanSize(v::CartesianIndex) = manhattanSize(Tuple(v))
manhattanSize(numbers) = sum(abs.(numbers))

precalculateWinds((;winds,dims)) = precalculateWinds(winds, dims)
precalculateWinds(winds,dims) = precalculateWinds(winds, dims, lcm(Tuple(dims)...))
function precalculateWinds(winds, dims, rounds)
    result = fill(false, Tuple(dims)...,rounds)
    for wind in winds
        for round in 1:rounds
            position = mod1.(Tuple(wind.start + round * wind.direction), Tuple(dims))
            result[CartesianIndex(Tuple(position)...,round)] = true
        end
    end
    return result
end

w=precalculateWinds(parseMap(example2))
for round in 1:size(w,3)
    println("Round $(round)")
    for y in 1:size(w,2)
        for x in 1:size(w,1)
            print(w[x,y,round] ? "▒" : " ")
        end
        println()
    end
    println("-" ^ size(w,1))
end
#
#exit()

function occupied(winds, round, position)
    x = CartesianIndex(Tuple(position)...,mod1(round, size(winds, ndims(winds))))
    return !checkbounds(Bool, winds, x) || winds[Tuple(position)...,mod1(round, size(winds, ndims(winds)))]
end

cacheForWinds(winds) = Array{Union{Missing, NamedTuple{(:time,:path),Tuple{Union{Nothing,Int},Union{Nothing,Vector{CartesianIndex}}}}}}(missing, size(winds,1)+2, size(winds,2)+4, size(winds,3)*4)

cacheHits = 0
cacheAttempts = 0

@memoize moves(position,targetPosition) = @show [
    CartesianIndex(sign(targetPosition[1] - position[1]), 0),
    CartesianIndex(0, sign(targetPosition[2] - position[2])),
    CartesianIndex(-sign(targetPosition[1] - position[1]), 0),
    CartesianIndex(0, -sign(targetPosition[2] - position[2])),
    CartesianIndex(0, 0),
]

function timeToTarget(winds, round, startPosition, targetPosition, position=startPosition, best=*(size(winds)...), cache=cacheForWinds(winds))
    if position == targetPosition
        return (;time=0,path=[position])
    end

    #global cacheAttempts
    #global cacheHits
    #cacheAttempts += 1
    cachePosition = CartesianIndex(position[1]+1, position[2]+2,mod1(round+1, size(cache,3)))
        cached = cache[cachePosition]
        if !ismissing(cached)
            #cacheHits += 1
            #if cacheAttempts % 100_000 == 0
            #    println("Cache hits: $(cacheHits)/$(cacheAttempts)\t$((cacheHits*100) ÷ cacheAttempts)")
            #end
            return cached
        end

    result = doTimeToTarget(winds, round, startPosition, targetPosition, position, best, cache)

        cache[cachePosition] = result

    return result

end
function doTimeToTarget(winds, round, startPosition, targetPosition, position, best, cache)
    if position == targetPosition
        return (;time=0,path=[position])
    end

    if best !== nothing && manhattanDistance(position, targetPosition) > best
        return (;time=nothing,path=nothing)
    end

    if position != startPosition && occupied(winds, round, position)
        return (;time=nothing,path=nothing)
    end

    result = nothing
    resultPath = nothing
    for move in moves(startPosition, targetPosition)
        (;time,path) = timeToTarget(winds, round+1, startPosition, targetPosition, position+move, best - 1, cache)
        if time !== nothing && (result === nothing || time < best)
            result = time + 1
            best = result
            resultPath = [position,path...]
        end
    end

    return (;time=result,path=resultPath)
end

function visualise(path)
    dims = (maximum(c->c[1], path), maximum(c->c[2], path) + 1)

    result = Array{Vector{Char}}(undef, dims)
    for I in eachindex(result)
        result[I] = []
    end

    prev = path[1]
    for cur = @view path[2:end]
        dir = cur - prev
        if dir == RIGHT
            c = '>'
        elseif dir == LEFT
            c = '<'
        elseif dir == DOWN
            c = 'v'
        elseif dir == UP
            c = '^'
        else
            c = '*'
        end
        push!(result[prev + CartesianIndex(0,1)], c)
        prev = cur
    end


    for y in 1:size(result, 2)
        width = maximum(p -> length(p), result[:,y])
        for i in 1:width
            for x in 1:size(result, 1)
                if !checkbounds(Bool, result[x,y],i)
                    if i == 1
                        print("•")
                    else
                        print(" ")
                    end
                else
                    print(result[x,y][i])
                end
            end
            println()
        end
    end
end


function part1(lines)
    (;winds,dims) = parseMap(lines)
    winds = precalculateWinds(winds,dims)

    (;time, path) = timeToTarget(winds, 0, CartesianIndex(1,0), dims + CartesianIndex(0,1))
    @show time, path
    visualise(path)
    return time
end

function part2(lines)
    (;winds,dims) = parseMap(lines)
    winds = precalculateWinds(winds,dims)

    println("Forwards")
    @show (;time, path) = timeToTarget(winds, 0, CartesianIndex(1,0), dims + CartesianIndex(0,1))
    time1 = time
    visualise(path)
    println("Backwards")
    @show (;time, path) = timeToTarget(winds, time1, dims + CartesianIndex(0,1), CartesianIndex(1,0))
    time2 = time
    visualise(path)
    println("Forwards again")
    @show (;time, path) = timeToTarget(winds, time1+time2, CartesianIndex(1,0), dims + CartesianIndex(0,1))
    time3 = time
    visualise(path)
    return time1+time2+time3
end

#@time @test part1(example1) == 9
@time @test part1(example2) == 18
@time @test part1(input) == 373
@time @test part2(example2) == 54

println("Calculating...")
@time result = part1(input)
println(result)
@test result == 373
@time result = part2(input)
println(result)
