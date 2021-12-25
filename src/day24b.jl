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
        "function "*name*"(n)"
        "w::Int=0"
        "x::Int=0"
        "y::Int=0"
        "z::Int=0"
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
