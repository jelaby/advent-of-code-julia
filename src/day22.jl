#=
day22:
- Julia version: 1.7.0
- Author: Paul.Mealor
- Date: 2021-12-22
=#

using AoC, Test

struct Volume
    min::NTuple{3,Int}
    max::NTuple{3,Int}
end
Volume(xmin, xmax, ymin, ymax, zmin, zmax) = Volume((xmin, ymin, zmin), (xmax, ymax, zmax))
@test Volume(1,2,3,4,5,6) == Volume((1,3,5),(2,4,6))

const EMPTY = Volume(0,0,0,0,0,0)

struct Step
    state::Bool
    volume::Volume
end
Step(state, xmin, xmax, ymin, ymax, zmin, zmax) = Step(state, Volume((xmin, ymin, zmin),(xmax+1, ymax+1, zmax+1)))

parseTargetState(s) = s=="on"
parseRange(s) = parse.(Int, split(s, r"=|\.{2}")[2:3])

function parseLine(line)
    parts = split(line, r"[ ,]")
    return Step(parseTargetState(parts[1]), parseRange(parts[2])..., parseRange(parts[3])..., parseRange(parts[4])...)
end

@test parseLine("on x=-20..26,y=-36..17,z=-47..7") == Step(true, Volume((-20,-36,-47), (27,18,8)))

Base.isempty(volume::Volume) = any(i->volume.min[i]>=volume.max[i], eachindex(volume.min))
isnotempty(volume::Volume) = !isempty(volume)

@show :volumeOf
volumeOf(volumes) = sum(volumeOf, volumes)
volumeOf(volume::Volume) = prod(volume.max .- volume.min)
@test volumeOf(Volume((0,0,0),(2,2,2))) == 8
@test volumeOf([Volume((0,0,0),(2,2,2))]) == 8
@test volumeOf([Volume((0,0,0),(2,2,2)), Volume((4,4,4),(5,5,5))]) == 9

@show :intersects
intersects(a::Volume, b::Volume) = all(i->a.min[i] < b.max[i] && a.max[i] > b.min[i], eachindex(a.min))
@test intersects(Volume(1,2,1,2,1,2), Volume(1,2,1,2,1,2)) == true
@test intersects(Volume(1,2,1,2,1,2), Volume(0,3,0,3,0,3)) == true
@test intersects(Volume(1,2,1,2,1,2), Volume(1,3,1,3,1,3)) == true
@test intersects(Volume(1,2,1,2,1,2), Volume(0,2,0,2,0,2)) == true
@test intersects(Volume(1,2,1,2,1,2), Volume(1,3,1,3,1,3)) == true
@test intersects(Volume(1,2,1,2,1,2), Volume(3,4,3,4,3,4)) == false
@test intersects(Volume(1,2,1,2,1,2), Volume(2,3,1,2,1,2)) == false
@test intersects(Volume(0,3,1,2,1,2), Volume(1,2,0,3,1,2)) == true
@test intersects(Volume(1,3,1,2,1,2), Volume(1,2,0,3,1,2)) == true
@test intersects(Volume(0,3,1,2,1,2), Volume(1,2,1,2,0,3)) == true
@test intersects(Volume(1,3,1,2,1,2), Volume(1,2,1,2,0,3)) == true

@show :encloses
encloses(a::Volume, b::Volume) = all(i->a.min[i]<=b.min[i] && a.max[i]>=b.max[i], eachindex(a.min))
@test encloses(Volume(1,2,1,2,1,2), Volume(1,2,1,2,1,2)) == true
@test encloses(Volume(1,1,1,1,1,1), Volume(0,3,0,3,0,3)) == false
@test encloses(Volume(0,3,0,3,0,3), Volume(1,1,1,1,1,1)) == true
@test encloses(Volume(1,1,1,1,1,1), Volume(1,2,1,2,1,2)) == false
@test encloses(Volume(1,3,1,2,1,2), Volume(1,2,1,2,1,2)) == true
@test encloses(Volume(1,2,1,3,1,2), Volume(1,2,1,2,1,2)) == true
@test encloses(Volume(1,2,1,2,1,3), Volume(1,2,1,2,1,2)) == true
@test encloses(Volume(1,2,1,2,1,2), Volume(0,1,0,1,0,1)) == false
@test encloses(Volume(1,2,1,2,1,2), Volume(2,3,2,3,2,3)) == false
@test encloses(Volume(1,2,1,2,1,2), Volume(3,3,3,3,3,3)) == false
@test encloses(Volume(1,2,1,2,1,2), Volume(3,3,1,2,1,2)) == false
@test encloses(Volume(0,3,1,2,1,2), Volume(1,2,0,3,1,2)) == false
@test encloses(Volume(1,3,1,2,1,2), Volume(1,2,0,3,1,2)) == false
@test encloses(Volume(0,3,1,2,1,2), Volume(1,2,1,2,0,3)) == false
@test encloses(Volume(1,3,1,2,1,2), Volume(1,2,1,2,0,3)) == false

@show :divide
function divide(v::Volume, axis, offset)
    if v.min[axis] >= offset || v.max[axis] <= offset
        return [v]
    end
    newmax = [v.max...]
    newmax[axis] = offset
    newmin = [v.min...]
    newmin[axis] = offset
    return [Volume(v.min, tuple(newmax...)), Volume(tuple(newmin...), v.max)]
end
@test divide(Volume(0,3,0,3,0,3), 2, -1) == [Volume(0,3,0,3,0,3)]
@test divide(Volume(0,3,0,3,0,3), 2, 0) == [Volume(0,3,0,3,0,3)]
@test divide(Volume(0,3,0,3,0,3), 2, 1) == [Volume(0,3,0,1,0,3), Volume(0,3,1,3,0,3)]
@test divide(Volume(0,3,0,3,0,3), 2, 2) == [Volume(0,3,0,2,0,3), Volume(0,3,2,3,0,3)]
@test divide(Volume(0,3,0,3,0,3), 2, 3) == [Volume(0,3,0,3,0,3)]
@test divide(Volume(0,3,0,3,0,3), 2, 4) == [Volume(0,3,0,3,0,3)]

function Base.intersect(a::Volume, b::Volume)
    if !intersects(a,b)
        return EMPTY
    elseif encloses(a,b)
        return b
    elseif encloses(b,a)
        return a
    else
        return Volume(ntuple(i->max(a.min[i],b.min[i]),length(a.min)), ntuple(i->min(a.max[i],b.max[i]),length(a.max)))
    end
end

function Base.intersect(A::AbstractArray{Volume}, b::Volume)
    result = similar(A, 0)
    for a in A
        intersection = intersect(a,b)
        if isnotempty(intersection)
            push!(result, intersection)
        end
    end
    return result
end

@show :(-)
function Base.:(-)(a::Volume, b::Volume)
    if !intersects(a, b)
        return [a]
    end

    if encloses(b,a)
        return []
    end

    axis = findfirst(i -> a.min[i] < b.min[i], eachindex(a.min))
    if !isnothing(axis)
        slices = divide(a, axis, b.min[axis])
        return [slices[1:1];slices[2] - b]
    end

    axis = findfirst(i -> a.max[i] > b.max[i], eachindex(a.min))
    if !isnothing(axis)
        slices = divide(a, axis, b.max[axis])
        return [slices[1]-b;slices[2:2]]
    end

    throw(ArgumentError("Cannot evaluate " * string(b) * " - " * string(a)))
end

function Base.:(-)(a::Volume, b::AbstractArray{Volume})
    result = [a]
    for other in b
        for i in eachindex(result)
            newVolumes = result[i] - other
            if isempty(newVolumes)
                result[i] = EMPTY
            else
                result[i] = newVolumes[i]
                push!(result, newVolumes[2:end])
            end
        end
    end
    return filter!(isnotempty, result)
end

@show :applyStep!
function applyStep!(volumes, step)
    if step.state
        stepVolumes = [step.volume]
        for existing in volumes
            for i in eachindex(stepVolumes)
                newVolumes = stepVolumes[i] - existing
                if isempty(newVolumes)
                    stepVolumes[i] = EMPTY
                else
                    stepVolumes[i] = newVolumes[1]
                    push!(stepVolumes, newVolumes[2:end]...)
                end
            end
            filter!(isnotempty, stepVolumes)
        end
        push!(volumes, stepVolumes...)

    else
        stepVolume = step.volume
        for i in eachindex(volumes)
            newVolumes = volumes[i] - stepVolume
            if isempty(newVolumes)
                volumes[i] = EMPTY
            else
                volumes[i] = newVolumes[1]
                push!(volumes, newVolumes[2:end]...)
            end
        end
        filter!(isnotempty, volumes)

    end

    return volumes
end

@test applyStep!([], Step(true, 1,1,1,1,1,1)) == [Volume((1,1,1),(2,2,2))]
@test volumeOf(applyStep!([Volume((0,0,0),(2,2,2))],Step(false,1,1,1,1,1,1))) == 7
@test volumeOf(applyStep!([Volume((0,0,0),(2,2,2))],Step(true,1,1,1,1,1,1))) == 8
@test volumeOf(applyStep!([Volume((0,0,0),(2,2,2))],Step(true,2,2,2,2,2,2))) == 9
@test volumeOf(applyStep!([Volume((0,0,0),(2,2,2))],Step(true,1,2,1,2,1,2))) == 15
@test volumeOf(applyStep!([Volume((0,0,0),(2,2,2))],Step(true,-1,1,-1,1,-1,1))) == 27

function applySteps(steps)
    result = Volume[]
    for step in steps
        applyStep!(result, step)
    end
    return result
end

function part1(lines)
    steps = parseLine.(lines)

    result = applySteps(steps)

    return volumeOf(intersect(result, Volume((-50,-50,-50), (51,51,51))))
end

function part2(lines)
    steps = parseLine.(lines)

    result = applySteps(steps)

    return volumeOf(result)
end

@test part1(exampleLines(22,1)) == 590784

@show lines(22) |> ll -> @time part1(ll)
@show lines(22) |> ll -> @time part2(ll)
