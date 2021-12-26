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

generateAluFunction("processInp1", lines(24)[1:18])
generateAluFunction("processInp2", lines(24)[19:36])
generateAluFunction("processInp3", lines(24)[37:54])
generateAluFunction("processInp4", lines(24)[54:72])
generateAluFunction("processInp5", lines(24)[73:90])
generateAluFunction("processInp6", lines(24)[91:108])
generateAluFunction("processInp7", lines(24)[109:126])
generateAluFunction("processInp8", lines(24)[127:144])
generateAluFunction("processInp9", lines(24)[145:162])
generateAluFunction("processInp10", lines(24)[163:180])
generateAluFunction("processInp11", lines(24)[181:198])
generateAluFunction("processInp12", lines(24)[199:216])
generateAluFunction("processInp13", lines(24)[217:234])
generateAluFunction("processInp14", lines(24)[235:end])

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

#const ARG_RANGES = sort(abs, [-20:20])
const ARG_RANGES = [0]
const Z_RANGES = sort!(abs, [-100000:10000])

function searchForWXYZ(f,targetZ,inputs)
    result = Int[]
    for x in 0:0#-20:20
        for y in 0:0#-20:20
            for w in 0:0#-20:20
                for z in -100000:100000
                    if f(inputs, w=w,x=x,y=y,z=z)[4] == targetZ
                        push!(result, z)
                    end
                end
            end
        end
    end
    return result
end

function searchForZ(f,targetZ,otherInputs=Int[])
    result = Tuple{Int,Int}[]
    for input = 9:-1:1
        inputs=Int[[input];otherInputs]
        for z in searchForWXYZ(f, targetZ, inputs)
            push!(result, (input,z))
        end
    end
    @show f, targetZ, result
    return result
end

@show searchForZ(processInp14, 0)
@show searchForZ(processInp13, 11)

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

@show searchForZ(processInp[14], 0)

function searchForInputs(targetZ=0, digit=14, inputs=Int[])
    @show :searchForInputs, targetZ, digit, inputs

    if digit==0
        return n
    end

    for (input,z) in searchForZ(processInp[digit], 0)
        result = searchForInputs(z,digit-1, Int[[input];inputs])
        if !isnothing(result)
            return result
        end
    end
    return nothing
end

result = searchForInputs()
@show result
@test result != nothing && validate([parse(Int, c) for c in result])[4] == 0