#=
day21:
- Julia version: 1.8.3
- Author: Paul.Mealor
- Date: 2122-12-21
=#
using Test
using Base.Iterators
using Memoize
include("AoC.jl")

input = open(readlines, "src/day21-input.txt")
example1 = open(readlines, "src/day21-example-1.txt")

abstract type Monkey end

struct NumberMonkey
    name::AbstractString
    value::Int
end

struct OperationMonkey
    name::AbstractString
    left::AbstractString
    operator::Function
    right::AbstractString
end

name(monkey) = monkey.name

function parseOperator(op)
    if op == "+"
        return +
    elseif op == "-"
        return -
    elseif op == "*"
        return *
    elseif op == "/"
        return ÷
    else
        throw(ArgumentError("Unknown operator $(op)"))
    end
end

function parseLine(line)
    name,value,left,operator,right = match(r"(\w+): (?:(\d+)|(\w+) ([-+*/]) (\w+))", line).captures

    if value !== nothing
        return NumberMonkey(name, parse(Int, value))
    else
        return OperationMonkey(name,left,parseOperator(operator),right)
    end
end
parseLines(lines) = parseLine.(lines) |> monkeys -> Dict([name(monkey) => monkey for monkey in monkeys])

monkeyValue(monkeys,name) = monkeyValue(monkeys, monkeys[name])
monkeyValue(monkeys,monkey::NumberMonkey) = monkey.value
monkeyValue(monkeys,monkey::OperationMonkey) = monkey.operator(monkeyValue(monkeys, monkey.left),monkeyValue(monkeys, monkey.right))

part1(lines) = parseLines(lines) |> monkeys -> monkeyValue(monkeys, "root")

@time @test part1(example1) == 152

println("Calculating...")
@time result = part1(input)
println(result)
