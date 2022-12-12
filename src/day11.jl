#=
day11:
- Julia version: 1.8.3
- Author: Paul.Mealor
- Date: 2022-12-11
=#
using Test

lines = open(readlines, "src/day11-input.txt")
example1 = open(readlines, "src/day11-example-1.txt")

struct Operation
    operator
    getter
end

Operation(operator::AbstractString, getter::AbstractString) =
    Operation(operatorFor(Val(Symbol(operator))), getterFor(getter))

struct ModuloNumber
    number::Dict{Int,Int}
end
ModuloNumber(n::Int) =
    ModuloNumber(Dict([factor => n % factor for factor in [2,3,5,7,11,13,17,19,23,999]]))

Base.:+(x::ModuloNumber, y::Int) = ModuloNumber(Dict([factor => (x.number[factor] + y) % factor for factor in keys(x.number)]))
Base.:*(x::ModuloNumber, y::Int) = ModuloNumber(Dict([factor => (x.number[factor] * y) % factor for factor in keys(x.number)]))
Base.:+(x::ModuloNumber, y::ModuloNumber) = ModuloNumber(Dict([factor => (x.number[factor] + y.number[factor]) % factor for factor in keys(x.number)]))
Base.:*(x::ModuloNumber, y::ModuloNumber) = ModuloNumber(Dict([factor => (x.number[factor] * y.number[factor]) % factor for factor in keys(x.number)]))
Base.:÷(x::ModuloNumber, y::Int) = ModuloNumber(Dict([factor => ((x.number[factor]+factor) ÷ y) % factor for factor in keys(x.number)]))
Base.:%(x::ModuloNumber, y::Int) = x.number[y]
Base.convert(::Type{ModuloNumber}, n::Int) = ModuloNumber(n)

mutable struct Monkey{T}
    const number::Int
    const items::Vector{T}
    const operation::Operation
    const factor::Int
    const trueTarget::Int
    const falseTarget::Int
    inspectionCount::Int
end
Monkey{T}(number, items, operation, factor, trueTarget, falseTarget) where T = Monkey{T}(number, items, operation, factor, trueTarget, falseTarget, 0)

operatorFor(::Val{:*}) = (a,b) -> a * b
operatorFor(::Val{:+}) = (a,b) -> a + b

function getterFor(getter)
    if getter == "old"
        return worry -> worry
    else
        value = parse(Int, getter)
        return worry -> value
    end
end

parseMonkey(::Type{T}, lines) where T =
    Monkey{T}(
        match(r"Monkey (\d+):", lines[1]).captures[1] |> x -> parse(Int, x),
        match(r"Starting items: ((?:\d+)(?:, *\d+)*)", lines[2]).captures[1] |> x -> split(x, r", *") |> x -> parse.(Int, x),
        Operation(match(r"Operation: new = old ([+*]) (\d+|old)", lines[3]).captures...),
        match(r"Test: divisible by (\d+)", lines[4]).captures[1] |> x -> parse(Int, x),
        match(r"If true: throw to monkey (\d+)", lines[5]).captures[1] |> x -> parse(Int, x),
        match(r"If false: throw to monkey (\d+)", lines[6]).captures[1] |> x -> parse(Int, x)
    )

parseMonkeys(::Type{T}, lines) where T = [parseMonkey(T, lines[l:l+5]) for l in 1:7:length(lines)]

function turn(monkey, monkeys, relief = 3)
    for item in monkey.items
        item = monkey.operation.operator(item, monkey.operation.getter(item)) ÷ relief
        monkey.inspectionCount += 1
        if (item % monkey.factor) == 0
            push!(monkeys[monkey.trueTarget+1].items, item)
        else
            push!(monkeys[monkey.falseTarget+1].items, item)
        end
    end
    empty!(monkey.items)
end

function round(monkeys, relief = 3)
    for monkey in monkeys
        turn(monkey, monkeys, relief)
    end
end

function rounds(monkeys, number, relief = 3)
    for i in 1:number
        round(monkeys, relief)
    end
    return monkeys
end

part1(lines) = parseMonkeys(Int, lines) |>
    monkeys -> rounds(monkeys, 20) |>
    monkeys -> sort!(monkeys, by=monkey -> monkey.inspectionCount, rev=true) |>
    monkeys -> monkeys[1].inspectionCount * monkeys[2].inspectionCount

part2(lines) = parseMonkeys(ModuloNumber, lines) |>
    monkeys -> rounds(monkeys, 10000, 1) |>
    monkeys -> sort!(monkeys, by=monkey -> monkey.inspectionCount, rev=true) |>
    monkeys -> monkeys[1].inspectionCount * monkeys[2].inspectionCount

@test part1(example1) == 10605
@test part2(example1) == 2713310158

@time println(part1(lines))
@time println(part2(lines))
