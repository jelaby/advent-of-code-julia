#=
day24b:
- Julia version: 1.7.0
- Author: Paul.Mealor
- Date: 2021-12-25
=#

using AoC, Test, Memoize
using Dates: now


function generateAluFunction(lines)
    inputNumber = 1
    body = [
        "(n, w::Int=0, x::Int=0, y::Int=0, z::Int=0) -> begin"
    ]
    for line in lines
        (op, arg...) = split(line, ' ')

        if op == "inp"
            push!(body, arg[1] * " = n[" * string(inputNumber) * "]")
            inputNumber = inputNumber + 1
        elseif op == "add"
            push!(body, arg[1] * " += " * arg[2])
        elseif op == "mul"
            push!(body, arg[1] * " *= " * arg[2])
        elseif op == "div"
            push!(body, arg[1] * " ÷= " * arg[2])
        elseif op == "mod"
            push!(body, arg[1] * " %= " * arg[2])
        elseif op == "eql"
            push!(body, arg[1] * " = (" * arg[1] * " == " * arg[2] * ") ? 1 : 0")
        else
            throw(ArgumentError("Unrecognised command "*line))
        end

    end

    push!(body, "return (w,x,y,z)")
    push!(body, "end")

    return eval(Meta.parse(join(body, "\n")))

end

test1 = generateAluFunction(exampleLines(24,1))
@test test1(1) == (0,0,0,1)
@test test1(2) == (0,0,1,0)
@test test1(4) == (0,1,0,0)
@test test1(8) == (1,0,0,0)
@test test1(15) == (1,1,1,1)
@test test1(5) == (0,1,0,1)

const FOURTEEN_NINES = 99_999_999_999_999

inputLines=Int[]
ll = lines(24)
for i in eachindex(ll)
    if startswith(ll[i], "inp")
        push!(inputLines, i)
    end
end

lastSegment = length(inputLines)

fragments = Array{Function}(undef, lastSegment,lastSegment)

firstPartLine(n) = inputLines[n]
lastPartLine(n) = n < length(inputLines) ? inputLines[n+1]-1 : length(ll)

for i in 1:lastSegment
    for j in 1:lastSegment
        fragments[i,j] = generateAluFunction(ll[firstPartLine(i):lastPartLine(j)])
    end
end

@test fragments[1,14]([parse(Int, c) for c in "13579246899999"])[4] == 3144333912
@test fragments[4,14]([parse(Int, c) for c in "79246899999"], fragments[1,3]([parse(Int, c) for c in "135"])...)[4] == 3144333912

#const ARG_RANGES = sort(-20:20; by=abs)
const ARG_RANGES = [0]
const Z_RANGES = sort(-100000:100000; by=abs)




function findInputs(fragment, minTargetZ, maxTargetZ)
    result = Dict{Int, Tuple{Int,Int}}()
    overallMinZ = typemax(Int)
    overallMaxZ = typemin(Int)
    for input in 1:9
        minZ = typemax(Int)
        maxZ = typemin(Int)
        for z in Z_RANGES
            if minTargetZ <= fragment([input], 0, 0, 0, z)[4] <= maxTargetZ
                if z > maxZ; maxZ=z; end
                if z < minZ; minZ=z; end
                if z > overallMaxZ; overallMaxZ=z; end
                if z < overallMinZ; overallMinZ=z; end
            end
        end
        result[input] = (minZ, maxZ)
    end
    return (overallMinZ, overallMaxZ, result)
end

@show findInputs(fragments[14,14], 0,0)


function nextDigit(part, allInputZs, w,x,y,z, digits=[])

    if part == 15
        if fragments[1,14](digits, 0,0,0,0)[4] == 0
            return digits
        else
            @show :reject, digits
        end
    end

    inputZs = allInputZs[part]
    inputs = filter(sort(collect(keys(inputZs)); rev=true)) do input
        @show z, input,inputZs[input]
        inputZs[input][1] <= z && inputZs[input][2] >= z
    end

    if isempty(inputs)
        @show :no_result,part, allInputZs, w,x,y,z
        return nothing
    end

    for input in inputs
        newRegisters = fragments[part,part]([input], w,x,y,z)
        result = nextDigit(part+1, allInputZs, newRegisters...)
        if !isnothing(result)
            return [[input];result]
        end
    end

    @show :no_children, part, allInputZs, w,x,y,z
    return nothing
end


function findChain(fragments)
    allInputZs = Dict{Int, Tuple{Int, Int}}[]
    targetMinZ = 0
    targetMaxZ = 0
    for part = 14:-1:1
        (targetMinZ, targetMaxZ, inputZs) = findInputs(fragments[part,part], targetMinZ, targetMaxZ)
        push!(allInputZs, inputZs)
    end

    reverse!(allInputZs)

    return nextDigit(1, allInputZs, 0,0,0,0)
end

@show findChain(fragments)

