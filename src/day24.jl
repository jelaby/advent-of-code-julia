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
@test execute(lines(24), [string(c) for c in "54765856433456"]).vars['z'] != 0

abstract type Expression end

struct InpExpression <: Expression
    n::Int
    value::Expression
end
inpExpression(n, value::Expression) = InpExpression(n,value)

struct AddExpression <: Expression
    l::Expression
    r::Expression
end

function addExpression(l::Expression,r::Expression)
    if fixedValue(l) == 0
        return r
    elseif fixedValue(r) == 0
        return l
    elseif hasFixedValue(l) && hasFixedValue(r)
        return valueExpression(fixedValue(l)+fixedValue(r))
    elseif l isa Range
        return Range(addExpression(l.min,r), l.stride, addExpression(l.max, r))
    elseif r isa Range
        return Range(addExpression(l,r.min), r.stride, addExpression(l, r.max))
    end
    return AddExpression(l,r)
end

struct MulExpression <: Expression
    l::Expression
    r::Expression
end

function mulExpression(l::Expression,r::Expression)
    if fixedValue(l)==0 || fixedValue(r)==0
        return valueExpression(0)
    elseif hasFixedValue(l) && hasFixedValue(r)
        return valueExpression(fixedValue(l) * fixedValue(r))
    elseif l isa Range
        return Range(mulExpression(l.min,r), mulExpression(l.stride, r), mulExpression(l.max, r))
    elseif r isa Range
        return Range(mulExpression(l,r.min), mulExpression(l, r.stride), mulExpression(l, r.max))
    end
    return MulExpression(l,r)
end

struct DivExpression <: Expression
    l::Expression
    r::Expression
end

function divExpression(l::Expression,r::Expression)
    if fixedValue(r) == 1
        return l
    elseif hasFixedValue(l) && hasFixedValue(r)
        return valueExpression(fixedValue(l) ÷ fixedValue(r))
    end
    return DivExpression(l,r)
end

struct ModExpression <: Expression
    l::Expression
    r::Expression
end

function modExpression(l::Expression,r::Expression)
    if hasFixedValue(l) && hasFixedValue(r)
        return valueExpression(fixedValue(l) % fixedValue(r))
    end
    return ModExpression(l,r)
end

struct EqlExpression <: Expression
    l::Expression
    r::Expression
end

function eqlExpression(l::Expression,r::Expression)
    if hasFixedValue(l) && hasFixedValue(r)
        return valueExpression(fixedValue(l) == fixedValue(r))
    elseif isFixedRange(l) && hasFixedValue(r)
        answers=Set{Bool}()
        for i in asRange(l)
            push!(answers, i == fixedValue(r))
        end
        if length(answers) == 1
            return valueExpression(first(answers))
        end
    elseif isFixedRange(r) && hasFixedValue(l)
        answers=Set{Bool}()
        for i in asRange(r)
            push!(answers, i == fixedValue(l))
        end
        if length(answers) == 1
            return valueExpression(first(answers))
        end
    end
    return EqlExpression(l,r)
end

struct ValueExpression <: Expression
    value::Int
end

function valueExpression(value)
    return ValueExpression(value)
end
valueExpression(value::AbstractString) = valueExpression(asInt(value))

struct Range <: Expression
    min::Expression
    stride::Expression
    max::Expression
end
Range(min::Int,stride::Int,max::Int) = Range(valueExpression(min), valueExpression(stride), valueExpression(max))
Range(min,max) = Range(min,1,max)

mutable struct Decompiler
    inputs::Vector{Range}
    nextInput::Int
    vars::Dict{Char, Expression}
end
Decompiler(inputs) = Decompiler(inputs, 1, Dict('w'=>ValueExpression(0),'x'=>ValueExpression(0),'y'=>ValueExpression(0),'z'=>ValueExpression(0)))

getDecompilerVarOrValue(alu, arg) = get(()->valueExpression(arg), alu.vars, asVar(arg))

Base.show(io::IO, e::ValueExpression) = show(io, e.value)
function Base.show(io::IO, e::Range)
    print(io, '[')
    print(io, e.min)
    if !hasFixedValue(e.stride) || fixedValue(e.stride) != 1
        print(io, ':')
        print(io, e.stride)
    end
    print(io, ':')
    print(io, e.max)
    print(io, ']')
end
function Base.show(io::IO, e::InpExpression)
    print(io, '#')
    print(io, e.n)
end
function Base.show(io::IO, e::Expression)
    iscompound(e.l) && print(io, '(')
    print(io, e.l)
    iscompound(e.l) && print(io, ')')
    print(io, operatorSymbol(e))
    iscompound(e.r) && print(io, '(')
    print(io, e.r)
    iscompound(e.r) && print(io, ')')
end

iscompound(e) = true
iscompound(e::ValueExpression) = false
iscompound(e::Range) = false
iscompound(e::InpExpression) = false

operatorSymbol(::AddExpression) = '+'
operatorSymbol(::MulExpression) = '*'
operatorSymbol(::DivExpression) = '/'
operatorSymbol(::ModExpression) = '%'
operatorSymbol(::EqlExpression) = "=="

fixedValue(::Any) = nothing
fixedValue(v::ValueExpression) = v.value
fixedValue(v::InpExpression) = fixedValue(v.value)

hasFixedValue(::Any) = false
hasFixedValue(::ValueExpression) = true
hasFixedValue(v::InpExpression) = hasFixedValue(v.value)

isRange(::Any) = false
isRange(::Range) = true
isRange(v::InpExpression) = isRange(v.value)

isFixedRange(::Any) = false
isFixedRange(r::Range) = hasFixedValue(r.min) && hasFixedValue(r.stride) && hasFixedValue(r.max)
isFixedRange(v::InpExpression) = isFixedRange(v.value)

asRange(r::Expression) = fixedValue(first(r)):fixedValue(stride(r)):fixedValue(last(r))

Base.first(r::Range) = r.min
Base.stride(r::Range) = r.stride
Base.last(r::Range) = r.max

Base.first(r::InpExpression) = first(r.value)
Base.stride(r::InpExpression) = stride(r.value)
Base.last(r::InpExpression) = last(r.value)

function decompile(lines, inputs)
    alu = Decompiler(inputs)

    instructions=Dict(
        "inp" => (alu, args) -> begin alu.vars[asVar(args[1])] = inpExpression(alu.nextInput, alu.inputs[alu.nextInput]); alu.nextInput += 1; end,
        "add" => (alu, args) -> alu.vars[asVar(args[1])] = addExpression(getVar(alu, args[1]), getDecompilerVarOrValue(alu, args[2])),
        "mul" => (alu, args) -> alu.vars[asVar(args[1])] = mulExpression(getVar(alu, args[1]), getDecompilerVarOrValue(alu, args[2])),
        "div" => (alu, args) -> alu.vars[asVar(args[1])] = divExpression(getVar(alu, args[1]), getDecompilerVarOrValue(alu, args[2])),
        "mod" => (alu, args) -> alu.vars[asVar(args[1])] = modExpression(getVar(alu, args[1]), getDecompilerVarOrValue(alu, args[2])),
        "eql" => (alu, args) -> alu.vars[asVar(args[1])] = eqlExpression(getVar(alu, args[1]), getDecompilerVarOrValue(alu, args[2])),
    )

    for line in lines
        parts = split(line, ' ')

        op = instructions[parts[1]]

        op(alu, parts[2:end])
    end

    return alu
end



@test string(decompile(["inp x", "mul x -1"],[Range(1,9)]).vars['x']) == "#1*-1"
@test string(decompile(["inp x", "mul x 0"],[Range(1,9)]).vars['x']) == "0"
@test string(decompile(["inp x", "mul x 2"],[Range(1,9)]).vars['x']) == "#1*2"
@test string(decompile(["inp x", "add x 0"],[Range(1,9)]).vars['x']) == "#1"
@test string(decompile(["inp x", "add y x"],[Range(1,9)]).vars['y']) == "#1"
@test string(decompile(["inp x", "add x 2"],[Range(1,9)]).vars['x']) == "#1+2"
@test string(decompile(["inp x", "eql x 2"],[Range(1,9)]).vars['x']) == "#1==2"
@test string(decompile(["inp x", "eql x 0"],[Range(1,9)]).vars['x']) == "0"
@test string(decompile(["inp x", "eql x 10"],[Range(1,9)]).vars['x']) == "0"

@show string(decompile(lines(24), fill(Range(1,9),14)))