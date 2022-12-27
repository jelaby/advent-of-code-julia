#=
day25:
- Julia version: 1.8.3
- Author: Paul.Mealor
- Date: 2022-12-25
=#
using Test
using Base.Iterators
using Memoize
include("AoC.jl")

input = open(readlines, "src/day25-input.txt")
example1 = open(readlines, "src/day25-example-1.txt")

const DIGITS = ['=','-','0','1','2']

const DIGIT_VALUES = Dict([DIGITS[i] => i-3 for i in eachindex(DIGITS)])
const VALUE_DIGITS = Dict([i-3 => DIGITS[i] for i in eachindex(DIGITS)])

function fromSnafu(s)
    result = 0

    for c in s
        result = result * 5 + DIGIT_VALUES[c]
    end

    return result
end

function toSnafu(n)
    result = ""

    while n > 0
        digit = n % 5
        if digit > 2
            n += 5
            digit -= 5
        end
        result = VALUE_DIGITS[digit] * result
        n = n ÷ 5
    end

    return result
end

@test fromSnafu("1") == 1
@test fromSnafu("2") == 2
@test fromSnafu("1=") == 3
@test fromSnafu("1-") == 4
@test fromSnafu("10") == 5
@test fromSnafu("11") == 6
@test fromSnafu("12") == 7
@test fromSnafu("2=") == 8
@test fromSnafu("2-") == 9
@test fromSnafu("20") == 10
@test fromSnafu("1=0") == 15
@test fromSnafu("1-0") == 20
@test fromSnafu("1=11-2") == 2022
@test fromSnafu("1-0---0") == 12345
@test fromSnafu("1121-1110-1=0") == 314159265

@test toSnafu(1) == "1"
@test toSnafu(2) == "2"
@test toSnafu(3) == "1="
@test toSnafu(4) == "1-"
@test toSnafu(5) == "10"
@test toSnafu(6) == "11"
@test toSnafu(7) == "12"
@test toSnafu(8) == "2="
@test toSnafu(9) == "2-"
@test toSnafu(10) == "20"
@test toSnafu(15) == "1=0"
@test toSnafu(20) == "1-0"
@test toSnafu(2022) == "1=11-2"
@test toSnafu(12345) == "1-0---0"
@test toSnafu(314159265) == "1121-1110-1=0"

part1(lines) = fromSnafu.(lines) |> sum |> toSnafu

@time @test part1(example1) == "2=-1=0"

println("Calculating...")
@time result = part1(input)
println(result)
