#=
day19:
- Julia version: 1.7.0
- Author: Paul.Mealor
- Date: 2021-12-19
=#

using AoC, Test, Memoize

const Beacons = Vector{Vector{Int}}

function parseLines(lines)
    result=Vector{Vector{Vector{Int}}}()
    beacons = nothing
    for line in lines
        if isempty(line)
        elseif startswith(line, "---")
            if !isnothing(beacons)
                push!(result, sort!(beacons))
            end
            beacons = Vector{Vector{Int}}()
        else
            push!(beacons, parse.(Int, split(line, ',')))
        end
    end
    if !isempty(beacons)
        push!(result, sort!(beacons))
    end
    return result
end

@test parseLines(["--- Scanner 0 ---", "1,2,3", "4,5,6", "", "--- Scanner 1 ---", "7,8,9", "10,11,12"]) == [[[1,2,3], [4,5,6]], [[7,8,9], [10,11,12]]]
@test parseLines(["--- Scanner 0 ---", "3,6,5", "3,4,5", "", "--- Scanner 1 ---", "10,11,12", "7,11,12"]) == [[[3,4,5], [3,6,5]], [[7,11,12], [10,11,12]]]

transformations(M::Beacons) = transformations(length(M[1]))
@memoize function transformations(dim::Int)
    cos090 = 0
    cos180 = -1
    cos270 = 0
    sin090 = 1
    sin180 = 0
    sin270 = -1

    if dim == 3
        result = [
        [[ 1, 0, 0] [ 0, 1, 0] [ 0, 0, 1]],

        [[ 1, 0, 0] [ 0, cos090, sin090] [ 0,-sin090, cos090]],
        [[ 1, 0, 0] [ 0, cos180, sin180] [ 0,-sin180, cos180]],
        [[ 1, 0, 0] [ 0, cos270, sin270] [ 0,-sin270, cos270]],

        [[ cos090, 0, -sin090] [ 0, 1, 0] [ sin090, 0, cos090]],
        [[ cos180, 0, -sin180] [ 0, 1, 0] [ sin180, 0, cos180]],
        [[ cos270, 0, -sin270] [ 0, 1, 0] [ sin270, 0, cos270]],

        [[ cos090, sin090, 0] [-sin090, cos090, 0] [ 0, 0, 1]],
        [[ cos180, sin180, 0] [-sin180, cos180, 0] [ 0, 0, 1]],
        [[ cos270, sin270, 0] [-sin270, cos270, 0] [ 0, 0, 1]],
        ]
        rolls = [
            [[ 1, 0, 0] [ 0, 1, 0] [ 0, 0, 1]],
            [[ 1, 0, 0] [ 0, 0, 1] [ 0,-1, 0]],
            [[ 1, 0, 0] [ 0,-1, 0] [ 0, 0,-1]],
            [[ 1, 0, 0] [ 0, 0,-1] [ 0, 1, 0]],
        ]
    elseif dim == 2
        result = [
            [[ 1, 0] [ 0, 1]],

            [[ 0, 1] [-1, 0]],
            [[-1, 0] [ 0,-1]],
            [[ 0,-1] [ 1, 0]],
        ]
        rolls = [
            [[ 1, 0] [ 0, 1]],
        ]
    else
        throw(ArgumentError("Unknown size " * string(dim) * " of " * string(M[1]) * " in " * string(M)))
    end

    return Set([r * roll for roll in rolls for r in result])
end
@test length(transformations(3)) == 24

@memoize function positionFit(M::Beacons, N::Beacons; minMatches=12)
    coordsM = Set(tuple(m...) for m in M)
    for offsetM in M
        for offsetN in N
            offset = offsetM .- offsetN
            matches = 0
            for point in N
                point = tuple((point .+ offset)...)
                if point ∈ coordsM
                    matches += 1
                    if matches >= minMatches
                        return offset
                    end
                end
            end
        end
    end
    return nothing
end

@test positionFit([[1,2],[1,4]], [[1,2],[1,4]]; minMatches=2) == [0,0]
@test positionFit([[1,2],[1,4]], [[2,2],[2,4]]; minMatches=2) == [-1,0]
@test positionFit([[1,2],[1,4]], [[2,2],[2,4]]; minMatches=3) === nothing

transform(m, T) = T * m
transform(m, T, offset) = transform(m, T) .+ offset

transformCols(M, T, offset) = [m .+ offset for m in transformCols(M, T)]
@memoize transformCols(M, T) = [transform(m, T) for m in M]
@test transformCols([[3,4,5],], [[1,0,0] [0,1,0] [0,0,1]]) == [[3,4,5],]
@test transformCols([[3,4,5],], [[1,0,0] [0,0,1] [0,-1,0]]) == [[3,-5,4],]

@test Set([transform([1,0,0], T) for T in transformations(3)]) == Set([
    [1,0,0],

    [1,0,0],
    [1,0,0],
    [1,0,0],

    [0,1,0],
    [0,0,1],
    [-1,0,0],
    [-1,0,0],
    [0,-1,0],
    [0,0,-1],
])
@test length(Set([transform([1,2,3], T) for T in transformations(3)])) == 24

fit(M::Beacons, N::Beacons; minMatches=12) = fit(M, N, minMatches)
@memoize function fit(M::Beacons, N::Beacons, minMatches)
    for T in transformations(M)
        offset = positionFit(M, transformCols(N, T); minMatches=minMatches)
        if !isnothing(offset)
            return (T, offset)
        end
    end
    return nothing
end
@test fit([[1,2],[1,4]], [[1,2],[1,4]]; minMatches=2) == ([[1,0] [0,1]], [0,0])
@test fit([[1,2],[1,4]], [[2,2],[2,4]]; minMatches=2) == ([[1,0] [0,1]], [-1,0])
@test fit([[1,2],[1,4]], [[2,2],[2,4]]; minMatches=3) === nothing
@test fit([[1,2],[1,4]], [[2,-1],[4,-1]]; minMatches=2) == ([[0,1] [-1,0]], [0,0])
@test fit([[1,2],[1,4]], [[2,-2],[4,-2]]; minMatches=2) == ([[0,1] [-1,0]], [-1,0])

function attemptFit!(fitted::Vector{Beacons}, candidate::Beacons; minMatches=12)
    for F in fitted
        result = fit(F, candidate; minMatches=minMatches)
        if !isnothing(result)
            candidate = transformCols(candidate, result...)
            push!(fitted, candidate)
            return (true, result[2])
        end
    end
    return (false, nothing)
end
@test attemptFit!([[[1,2],[1,4]],], [[1,2],[1,4]]; minMatches=2)[1] == true
@test attemptFit!([[[1,2],[1,4]],], [[2,2],[2,4]]; minMatches=2)[1] == true
@test attemptFit!([[[1,2],[1,4]],], [[2,2],[2,4]]; minMatches=3)[1] === false
@test attemptFit!([[[1,2],[1,4]],], [[2,-1],[4,-1]]; minMatches=2)[1] == true
@test attemptFit!([[[1,2],[1,4]],], [[2,-2],[4,-2]]; minMatches=2)[1] == true

function testAttemptFit(fitted, candidate; minMatches=12)
    return attemptFit!(fitted, candidate; minMatches=minMatches)[1] ? fitted : nothing
end
@test testAttemptFit([[[1,2],[1,4]]], [[1,2],[1,4]]; minMatches=2) == ([[[1,2],[1,4]],[[1,2],[1,4]]])
@test testAttemptFit([[[1,2],[1,4]]], [[2,2],[2,4]]; minMatches=2) == ([[[1,2],[1,4]],[[1,2],[1,4]]])
@test testAttemptFit([[[1,2],[1,4]]], [[2,2],[2,4]]; minMatches=3) === nothing
@test testAttemptFit([[[1,2],[1,4]]], [[2,-1],[4,-1]]; minMatches=2) == ([[[1,2],[1,4]],[[1,2],[1,4]]])
@test testAttemptFit([[[1,2],[1,4]]], [[2,-2],[4,-2]]; minMatches=2) == ([[[1,2],[1,4]],[[1,2],[1,4]]])

@test testAttemptFit(
        [[[1,2], [1,1], [1,4], [1,7]]],
        [[-1,-4], [-1,-2], [-1,-7], [-2,-9]]; minMatches=3) == [
        [[1,2], [1,1], [1,4], [1,7]],
        [[1,4], [1,2], [1,7], [2,9]],
    ]
@test testAttemptFit(
        [[[1,1,0], [1,2,0], [2,3,0], [2,5,0], [2,6,0], [2,7,0], [3,5,0], [3,5,1]]],
        [[-3,-3,0], [-4,-3,0], [-3,-4,0], [-3,-5,0], [-3,-7,0], [-4,-7,0], [-4,-6,0], [-5,-6,0], [-4,-3,1]]; minMatches=5) == [
        [[1,1,0], [1,2,0], [2,3,0], [2,5,0], [2,6,0], [2,7,0], [3,5,0], [3,5,1]],
        [[2,5,0], [3,5,0], [2,6,0], [2,7,0], [2,9,0], [3,9,0], [3,8,0], [4,8,0], [3,5,1]]
    ]

function placeAll(M::Vector{Beacons}; minMatches=12)
    fitted = M[1:1]
    unfitted = M[2:end]
    offsets = Vector{Vector{Int}}()

    while !isempty(unfitted)
        found = false
        for I in eachindex(unfitted)
            candidate = unfitted[I]
            (found, offset) = attemptFit!(fitted, candidate; minMatches=minMatches)
            if found
                @show offset
                push!(offsets, offset)
                unfitted = unfitted[[1:I-1; I+1:end]]
                break
            end
        end
        found || throw(ArgumentError("Found no candidates in " * string(unfitted) * " that fit " * string(fitted)))
    end

    return @show (fitted, offsets)
end

@test placeAll([
        [[1,2], [1,4], [3,6]],
        [[11,4], [13,6], [17,9]],
    ]; minMatches=2)[1] == [
        [[1,2], [1,4], [3,6]],
        [[1,4], [3,6], [7,9]],
    ]
@test placeAll([
        [[1,2], [1,4], [3,6]],
        [[27,19], [24,10-4], [27,13]],
        [[11,4], [13,6], [17,9], [14, -4]],
    ]; minMatches=2)[1] == [
        [[1,2], [1,4], [3,6]],
        [[1,4], [3,6], [7,9], [4,-4]],
        [[7,9], [4,-4], [7,3]],
    ]
@test placeAll([
        [[1,2], [1,4], [1,5], [3,7]],
        [[-1,-4], [-1,-5], [-3,-7], [-2,-9]],
    ]; minMatches=3)[1] == [
        [[1,2], [1,4], [1,5], [3,7]],
        [[1,4], [1,5], [3,7], [2,9]],
    ]

deduplicate(M::Vector{Beacons}) = Set((tuple(coord...) for region in M for coord in region))

function part1(lines)
    M = parseLines(lines)

    (fitted, offsets) = placeAll(M)

    return length(deduplicate(fitted))
end

#@test part1(exampleLines(19,1)[[1:27;28:53]]) == 38
#@test part1(exampleLines(19,1)[[28:54;110:136]]) == 39
#@test part1(exampleLines(19,1)[[1:27];[55:82]]) == 0
#@test part1(exampleLines(19,1)[[28:54];[110:136]]) == 0

@test part1(exampleLines(19,1)) == 79

function part2(lines)
    M = parseLines(lines)
    (fitted, offsets) = placeAll(M)

    maxDistance = 0
    for I in offsets
        for J in offsets
            distance = +(abs.(J - I)...)
            if distance > maxDistance
                maxDistance = distance
            end
        end
    end
    return maxDistance
end

@test part2(exampleLines(19,1)) == 3621

println("Testing complete")

@show lines(19) |> ll -> @time part2(ll)
@show lines(19) |> ll -> @time part1(ll)