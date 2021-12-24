#=
day24:
- Julia version: 1.7.0
- Author: Paul.Mealor
- Date: 2021-12-24
=#

using AoC, Test



mutable struct ALU
    inputs::Vector{Int}
    vars::Dict{Char, Int}
end
ALU(inputs) = ALU(inputs, Dict{Char, Int}('w'=>0, 'x'=>0, 'y'=>0, 'z'=>0))

asVar(arg) = arg[1]
asInt(arg) = parse(Int, arg)

getVarOrValue(alu, arg) = get(()->asInt(arg), alu.vars, asVar(arg))
getVar(alu, arg) = alu.vars[asVar(arg)]


function execute(lines, inputs)
    alu = ALU(parse.(Int, inputs))

    instructions=Dict(
        "inp" => (alu, args) -> alu.vars[asVar(args[1])] = popfirst!(alu.inputs),
        "add" => (alu, args) -> alu.vars[asVar(args[1])] = getVar(alu, args[1]) + getVarOrValue(alu, args[2]),
        "mul" => (alu, args) -> alu.vars[asVar(args[1])] = getVar(alu, args[1]) * getVarOrValue(alu, args[2]),
        "div" => (alu, args) -> alu.vars[asVar(args[1])] = getVar(alu, args[1]) ÷ getVarOrValue(alu, args[2]),
        "mod" => (alu, args) -> alu.vars[asVar(args[1])] = getVar(alu, args[1]) % getVarOrValue(alu, args[2]),
        "eql" => (alu, args) -> alu.vars[asVar(args[1])] = getVar(alu, args[1]) == getVarOrValue(alu, args[2]),
    )

    for line in lines
        parts = split(line, ' ')

        op = instructions[parts[1]]

        op(alu, parts[2:end])
    end

    return alu
end
@test execute(["inp x", "mul x -1"], ["5"]).vars['x'] == -5
@test execute(exampleLines(24,1), ["1"]).vars == Dict('w'=>0, 'x'=>0, 'y'=>0, 'z'=>1)
@test execute(exampleLines(24,1), ["2"]).vars == Dict('w'=>0, 'x'=>0, 'y'=>1, 'z'=>0)
@test execute(exampleLines(24,1), ["4"]).vars == Dict('w'=>0, 'x'=>1, 'y'=>0, 'z'=>0)
@test execute(exampleLines(24,1), ["8"]).vars == Dict('w'=>1, 'x'=>0, 'y'=>0, 'z'=>0)
@test execute(exampleLines(24,1), ["15"]).vars == Dict('w'=>1, 'x'=>1, 'y'=>1, 'z'=>1)
@test execute(exampleLines(24,1), ["5"]).vars == Dict('w'=>0, 'x'=>1, 'y'=>0, 'z'=>1)

@test execute(lines(24), [string(c) for c in "13579246899999"]).vars['z'] != 0
@test execute(lines(24), [string(c) for c in "54765856433456"]).vars['z'] == 0