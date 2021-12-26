#=
day24b:
- Julia version: 1.7.0
- Author: Paul.Mealor
- Date: 2021-12-25
=#

using AoC, Test
using Dates: now


function generateAluFunction(name,lines)
    inputNumber = 1
    body = [
        "function "*name*"(n; w=0, x=0, y=0, z=0)"
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
            push!(body, arg[1] * " = (" * arg[1] * " == " * arg[2] * ")")
        else
            throw(ArgumentError("Unrecognised command "*line))
        end

    end

    push!(body, "return (w,x,y,z)")
    push!(body, "end")

    eval(Meta.parse(join(body, "\n")))

end

generateAluFunction("test1", exampleLines(24,1))
@test test1(1) == (0,0,0,1)
@test test1(2) == (0,0,1,0)
@test test1(4) == (0,1,0,0)
@test test1(8) == (1,0,0,0)
@test test1(15) == (1,1,1,1)
@test test1(5) == (0,1,0,1)

generateAluFunction("validate", lines(24))

@test validate([parse(Int, c) for c in "13579246899999"])[4] == 3144333912
@test validate([(13579246899999 ÷ (10^d)) % 10 for d in 13:-1:0])[4] == 3144333912

const FOURTEEN_NINES = 99_999_999_999_999

inputLines=Int[]
ll = lines(24)
startLine = 1
parts=Vector{String}[]
for i in eachindex(ll)
    global startLine
    if startswith(ll[i], "inp")
        push!(inputLines, i)
        if i!=startLine
            push!(parts, ll[startLine:i-1])
        end
        startLine=i
    end
end
push!(parts, ll[startLine:end])

@test sum(length.(parts)) == length(ll)
@test vcat(parts...) == ll
@test [startswith(part[1], "inp") for part in parts] == fill(true, length(parts))
@test [count(startswith.(part, "inp")) for part in parts] == fill(1, length(parts))

generateAluFunction("processInp1", parts[1])
generateAluFunction("processInp2", parts[2])
generateAluFunction("processInp3", parts[3])
generateAluFunction("processInp4", parts[4])
generateAluFunction("processInp5", parts[5])
generateAluFunction("processInp6", parts[6])
generateAluFunction("processInp7", parts[7])
generateAluFunction("processInp8", parts[8])
generateAluFunction("processInp9", parts[9])
generateAluFunction("processInp10", parts[10])
generateAluFunction("processInp11", parts[11])
generateAluFunction("processInp12", parts[12])
generateAluFunction("processInp13", parts[13])
generateAluFunction("processInp14", parts[14])

generateAluFunction("processInp1b", lines(24)[1:end])
generateAluFunction("processInp2b", lines(24)[19:end])
generateAluFunction("processInp3b", lines(24)[37:end])
generateAluFunction("processInp4b", lines(24)[54:end])
generateAluFunction("processInp5b", lines(24)[73:end])
generateAluFunction("processInp6b", lines(24)[91:end])
generateAluFunction("processInp7b", lines(24)[109:end])
generateAluFunction("processInp8b", lines(24)[127:end])
generateAluFunction("processInp9b", lines(24)[145:end])
generateAluFunction("processInp10b", lines(24)[163:end])
generateAluFunction("processInp11b", lines(24)[181:end])
generateAluFunction("processInp12b", lines(24)[199:end])
generateAluFunction("processInp13b", lines(24)[217:end])
generateAluFunction("processInp14b", lines(24)[235:end])

#const ARG_RANGES = sort(-20:20; by=abs)
const ARG_RANGES = [0]
const Z_RANGES = sort(-100000:100000; by=abs, rev=true)

function searchForWXYZ(onSuccess, f,targetZ,inputs)
    for x in ARG_RANGES
        for y in ARG_RANGES
            for w in ARG_RANGES
                for z in Z_RANGES
                    if f(inputs, w=w,x=x,y=y,z=z)[4] == targetZ
                        result = onSuccess(z)
                        if !isnothing(result)
                            return result
                        end
                    end
                end
            end
        end
    end
    return nothing
end

function searchForZ(onSuccess, f,targetZ,otherInputs=Int[])
    for input = 9:-1:1
        inputs=Int[[input];otherInputs]
        result = searchForWXYZ(z->onSuccess(input, z), f, targetZ, inputs)
        if !isnothing(result)
            return result
        end
    end
    return nothing
end

@show searchForZ((args...)->args, processInp14, 0)
@show searchForZ((args...)->args, processInp13, 11)

const processInp=[
        processInp1,
        processInp2,
        processInp3,
        processInp4,
        processInp5,
        processInp6,
        processInp7,
        processInp8,
        processInp9,
        processInp10,
        processInp11,
        processInp12,
        processInp13,
        processInp14,
    ]

const processInpB=[
        processInp1b,
        processInp2b,
        processInp3b,
        processInp4b,
        processInp5b,
        processInp6b,
        processInp7b,
        processInp8b,
        processInp9b,
        processInp10b,
        processInp11b,
        processInp12b,
        processInp13b,
        processInp14b,
    ]

@show searchForZ((args...)->args, processInp[14], 0)

function searchForInputs(targetZ=0, digit=14, inputs=Int[])
    return searchForZ(processInp[digit],targetZ) do input,z
        if digit == 1
            nextInputs = [[input];inputs]
            if validate(nextInputs)[4] == 0
                @show :result,nextInputs
            else
                @show :rejected,nextInputs
            end
        else
            n = 1
            nextInputs = [[input];inputs]
            nextZ = z
            w=0;x=0;y=0
            for d in digit:14
                (w,x,y,nextZ) = processInp[d]([nextInputs[n]], w=w,x=x,y=y,z=nextZ)
                n=n+1
            end
            if nextZ == 0
                searchForInputs(z, digit-1, nextInputs)
            else
                @show :rejected, digit,nextInputs,z,nextZ
                return nothing
            end
        end
    end
    return nothing
end

result = searchForInputs()
@show result
@test result !== nothing && validate([parse(Int, c) for c in result])[4] == 0