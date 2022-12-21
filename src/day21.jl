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
    findl::Function
    findr::Function
    right::AbstractString
end

name(monkey) = monkey.name

# t = l + r    t = l - r    t = l * r    t = l / r
# l = t - r    l = t + r    l = t / r    l = t * r
# r = t - l    r = l - t    r = t / l    r = l / t
function parseOperator(op)
    if op == "+"
        return (+,-,-)
    elseif op == "-"
        return (-,+,(t,l)->l-t)
    elseif op == "*"
        return (*,÷,(t,l)->t ÷ l)
    elseif op == "/"
        return (÷,*,(t,l)->l ÷ t)
    else
        throw(ArgumentError("Unknown operator $(op)"))
    end
end

function parseLine(line)
    name,value,left,operator,right = match(r"(\w+): (?:(\d+)|(\w+) ([-+*/]) (\w+))", line).captures

    if value !== nothing
        return NumberMonkey(name, parse(Int, value))
    else
        return OperationMonkey(name,left,parseOperator(operator)...,right)
    end
end
parseLines(lines) = parseLine.(lines) |> monkeys -> Dict([name(monkey) => monkey for monkey in monkeys])

function monkeyValue(monkeys,name,exclude=nothing)
    return name==exclude ? nothing : monkeyValue(monkeys, monkeys[name], exclude)
end
monkeyValue(monkeys,monkey::NumberMonkey,exclude) = monkey.value
function monkeyValue(monkeys,monkey::OperationMonkey,exclude)
    left = monkeyValue(monkeys, monkey.left, exclude)
    if left === nothing
        return nothing
    end
    right = monkeyValue(monkeys, monkey.right, exclude)
    if right === nothing
        return nothing
    end
    return monkey.operator(left,right)
end

part1(lines) = parseLines(lines) |> monkeys -> monkeyValue(monkeys, "root")


ensureEqual(monkeys, root::AbstractString, target) = ensureEqual(monkeys, monkeys[root], target)
function ensureEqual(monkeys, root, target)
    value = monkeyValue(monkeys, root.left, target)

    if value !== nothing
        return calculateMonkey(monkeys, root.right, value, target)
    end

    value = monkeyValue(monkeys, root.right, target)

    if value !== nothing
        return calculateMonkey(monkeys, root.left, value, target)
    end

    throw(ArgumentError("Both $(monkey.left) and $(monkey.right) have indeterminate values"))
end

function calculateMonkey(monkeys, name, targetValue, target)
    if name == target
        return targetValue
    end

    monkey = monkeys[name]

    left = monkeyValue(monkeys, monkey.left, target)
    right = monkeyValue(monkeys, monkey.right, target)



    if left === nothing
        rightValue = monkey.findl(targetValue,right)
        return calculateMonkey(monkeys, monkey.left, rightValue, target)
    elseif right === nothing
        leftValue = monkey.findr(targetValue,left)
        return calculateMonkey(monkeys, monkey.right, leftValue, target)
    else
        throw(ArgumentError("Neither $(monkey.left) $(left) or $(monkey.right) $(right) has an indeterminate value"))
    end
end

function part2(lines)
    monkeys = parseLines(lines)

    return ensureEqual(monkeys,"root","humn")
end


@time @test part1(example1) == 152
@time @test part2(example1) == 301

println("Calculating...")
@time result = part1(input)
println(result)
@time result = part2(input)
println(result)
