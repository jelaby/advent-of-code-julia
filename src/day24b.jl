#=
day24b:
- Julia version: 1.7.0
- Author: Paul.Mealor
- Date: 2021-12-25
=#

using AoC, Test
using Dates: now


function convertToFunctionGenerator(name,lines)
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

    return Meta.parse(join(body, "\n"))

end

eval(convertToFunctionGenerator("test1", exampleLines(24,1)))
@test test1(1) == (0,0,0,1)
@test test1(2) == (0,0,1,0)
@test test1(4) == (0,1,0,0)
@test test1(8) == (1,0,0,0)
@test test1(15) == (1,1,1,1)
@test test1(5) == (0,1,0,1)

@show gen = convertToFunctionGenerator("validate", lines(24))
eval(gen)

@test validate([parse(Int, c) for c in "13579246899999"])[4] == 3144333912
@test validate([(13579246899999 ÷ (10^d)) % 10 for d in 13:-1:0])[4] == 3144333912

const FOURTEEN_NINES = 99_999_999_999_999

#=for i = 11_111_111_111_111:FOURTEEN_NINES
    println(i, ' ', validate([(i ÷ (10^d)) % 10 for d in 13:-1:0])[4])
end=#

for d in 0:13
    for n in 10^d:10^d:9*10^d
        println(n, ' ', validate([(n ÷ (10^d)) % 10 for d in 13:-1:0])[4])
    end
end


function findBestKey()
    startTime = now()

    n = FOURTEEN_NINES

    while true
        if validate([(n ÷ (10^d)) % 9 for d in 13:-1:0])[4] == 0
            return n
        end
        n -= 1
        if n % 10 == 0
            n -= 1
            divisor = 10
            while (n ÷ divisor) % 10 == 0
                n -= divisor
                divisor *= 10
            end
        end
        if n % 1_000_000 == 111_111
            t = now()
            elapsed = t - startTime
            estimate = t + elapsed * FOURTEEN_NINES ÷ (FOURTEEN_NINES - n)
            percent = (FOURTEEN_NINES - n) ÷ (FOURTEEN_NINES ÷ 100)
            println(string(t), ' ', string(elapsed), ' ', string(estimate), ' ', string(percent), '%')
        end
    end
end

@show @time findBestKey()