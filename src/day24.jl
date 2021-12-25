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

@test execute(lines(24), [string(c) for c in "13579246899999"]).vars['z'] == 3144333912
@test execute(lines(24), [string(c) for c in "54765856433456"]).vars['z'] != 0

abstract type Expression end

struct InpExpression <: Expression
    n::Int
    first::Int
    stride::Int
    last::Int
end
inpExpression(n, first, stride, last) = InpExpression(n,first,stride,last)
inpExpression(n, first, last) = inpExpression(n,first,1,last)

struct AddExpression <: Expression
    l::Expression
    r::Expression
end

function addExpression(l::Expression,r::Expression)
    if fixedValue(l) == 0
        @show :simplifiedAdd,r
        return r
    elseif fixedValue(r) == 0
        @show :simplifiedAdd,l
        return l
    elseif hasFixedValue(l) && hasFixedValue(r)
        return @show valueExpression(fixedValue(l)+fixedValue(r))
    end
    return simplify(AddExpression(l,r))
end

struct MulExpression <: Expression
    l::Expression
    r::Expression
    factors::Set{Int}
end
MulExpression(l,r,factors::Union{Nothing,Int}...) = MulExpression(l,r,Set{Int}(filter(x->!isnothing(x), factors)))

function mulExpression(l::Expression,r::Expression)
    if fixedValue(l) == 0 || fixedValue(r) == 0
        @show :simplifiedMul, 0
        return valueExpression(0)
    elseif fixedValue(l) == 1
        @show :simplifiedMul, r
        return r
    elseif fixedValue(r) == 1
        @show :simplifiedMul, l
        return l
    end
    return simplify(MulExpression(l,r,fixedValue(l),fixedValue(r)))
end

struct DivExpression <: Expression
    l::Expression
    r::Expression
end

function divExpression(l::Expression,r::Expression)
    if fixedValue(r) == 1
        @show :simplifiedDiv, l
        return l
    elseif fixedValue(l) == 0
        @show :simplifiedDiv, 0
        return valueExpression(0)
    end
    return simplify(DivExpression(l,r))
end

struct ModExpression <: Expression
    l::Expression
    r::Expression
end

function modExpression(l::Expression,r::Expression)
    if hasFixedValue(l) && hasFixedValue(r)
        return valueExpression(fixedValue(l) % fixedValue(r))
    end
    if hasFixedValue(r)
        if fixedValue(r) ∈ factors(l)
            @show :simplifyModExpression,l,r
            l = valueExpression(0)
        else
            l = simplifyModulo(l, fixedValue(r))
        end

        lv = values(l)
        if !isnothing(lv) && all(v->v>=0 && v<=fixedValue(r), lv)
            @show :noopModulo, l, lv, fixedValue(r)
            return l
        end
    end

    return simplify(ModExpression(l,r))
end

simplifyModulo(e::Expression, divisor) = e
function simplifyModulo(e::MulExpression, divisor)
    if divisor ∈ factors(e)
        return valExpression(0)
    end
    return e
end
function simplifyModulo(e::AddExpression, divisor)
    l = e.l
    if divisor ∈ factors(l)
        l = valueExpression(0)
    end
    r = e.r
    if divisor ∈ factors(r)
        r = valueExpression(0)
    end
    if l !== e.l || r !== e.r
        @show :simplifyModuleAdd, l, r
        return addExpression(l,r)
    end
    return e
end

struct EqlExpression <: Expression
    l::Expression
    r::Expression
end

function eqlExpression(l::Expression,r::Expression)
    return simplify(EqlExpression(l,r))
end

struct ValueExpression <: Expression
    value::Int
end

function valueExpression(value)
    return ValueExpression(value)
end
valueExpression(value::AbstractString) = valueExpression(asInt(value))

mutable struct Decompiler
    inputs::Vector{InpExpression}
    nextInput::Int
    vars::Dict{Char, Expression}
end
Decompiler(inputs) = Decompiler(inputs, 1, Dict('w'=>ValueExpression(0),'x'=>ValueExpression(0),'y'=>ValueExpression(0),'z'=>ValueExpression(0)))

getDecompilerVarOrValue(alu, arg) = get(()->valueExpression(arg), alu.vars, asVar(arg))

Base.show(io::IO, e::ValueExpression) = show(io, e.value)
function Base.show(io::IO, e::InpExpression)
    print(io, '#')
    print(io, e.n)
    #print(io, '[')
    #print(io, e.first)
    #if !hasFixedValue(e.stride) || fixedValue(e.stride) != 1
    #    print(io, ':')
    #    print(io, e.stride)
    #end
    #print(io, ':')
    #print(io, e.last)
    #print(io, ']')
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
iscompound(e::InpExpression) = false

operatorSymbol(::AddExpression) = '+'
operatorSymbol(::MulExpression) = '*'
operatorSymbol(::DivExpression) = '/'
operatorSymbol(::ModExpression) = '%'
operatorSymbol(::EqlExpression) = "=="

operatorFor(::AddExpression) = (+)
operatorFor(::MulExpression) = (*)
operatorFor(::DivExpression) = (÷)
operatorFor(::ModExpression) = (%)
operatorFor(::EqlExpression) = (==)

values(e::ValueExpression) = e.value
values(e::InpExpression) = e.first:e.stride:e.last
values(e::Expression) = values(e, operatorFor(e))
function values(e::Expression, op)
    l = values(e.l)
    r = values(e.r)
    if isnothing(l) || isnothing(r) || length(l) * length(r) > 1000
        return fallbackValues(e)
    end

    return Set([op(l, r) for l in values(e.l), r in values(e.r)])
end

fallbackValues(::Expression) = nothing
fallbackValues(::EqlExpression) = Set([0,1])
fallbackValues(e::ModExpression) = hasFixedValue(e.r) ? Set(0:fixedValue(e.r)-1) : nothing

# known factors
factors(e::MulExpression) = e.factors
factors(e::Expression) = Set{Int}()

function simplify(e::Expression)
    actualValues = values(e)
    if isnothing(actualValues)
        return e
    end
    firstValue = first(actualValues)
    for value in actualValues
        if value != firstValue
            # not all the same
            return e
        end
    end
    # all the same
    @show :simplified,e,firstValue
    return valueExpression(firstValue)
end

fixedValue(::Any) = nothing
fixedValue(v::ValueExpression) = v.value

hasFixedValue(::Any) = false
hasFixedValue(::ValueExpression) = true

Base.first(r::InpExpression) = r.first
Base.stride(r::InpExpression) = r.stride
Base.last(r::InpExpression) = r.last

function decompile(lines, inputs)
    alu = Decompiler(inputs)

    instructions=Dict(
        "inp" => (alu, args) -> begin alu.vars[asVar(args[1])] = alu.inputs[alu.nextInput]; alu.nextInput += 1; end,
        "add" => (alu, args) -> alu.vars[asVar(args[1])] = addExpression(getVar(alu, args[1]), getDecompilerVarOrValue(alu, args[2])),
        "mul" => (alu, args) -> alu.vars[asVar(args[1])] = mulExpression(getVar(alu, args[1]), getDecompilerVarOrValue(alu, args[2])),
        "div" => (alu, args) -> alu.vars[asVar(args[1])] = divExpression(getVar(alu, args[1]), getDecompilerVarOrValue(alu, args[2])),
        "mod" => (alu, args) -> alu.vars[asVar(args[1])] = modExpression(getVar(alu, args[1]), getDecompilerVarOrValue(alu, args[2])),
        "eql" => (alu, args) -> alu.vars[asVar(args[1])] = eqlExpression(getVar(alu, args[1]), getDecompilerVarOrValue(alu, args[2])),
    )

    println("Decompiling...")
    for line in lines
        @show line
        parts = split(line, ' ')

        op = instructions[parts[1]]

        op(alu, parts[2:end])
    end
    println("...decompilation complete")

    return alu
end



@test string(decompile(["inp x", "mul x -1"],[inpExpression(1,1,9)]).vars['x']) == "#1*-1"
@test string(decompile(["inp x", "mul x 0"],[inpExpression(1,1,9)]).vars['x']) == "0"
@test string(decompile(["inp x", "mul x 2"],[inpExpression(1,1,9)]).vars['x']) == "#1*2"
@test string(decompile(["inp x", "add x 0"],[inpExpression(1,1,9)]).vars['x']) == "#1"
@test string(decompile(["inp x", "add y x"],[inpExpression(1,1,9)]).vars['y']) == "#1"
@test string(decompile(["inp x", "add x 2"],[inpExpression(1,1,9)]).vars['x']) == "#1+2"
@test string(decompile(["inp x", "eql x 2"],[inpExpression(1,1,9)]).vars['x']) == "#1==2"
@test string(decompile(["inp x", "eql x 0"],[inpExpression(1,1,9)]).vars['x']) == "0"
@test string(decompile(["inp x", "eql x 10"],[inpExpression(1,1,9)]).vars['x']) == "0"
@test string(decompile(["inp x", "add x 2", "add x 3"],[inpExpression(1,1,9)]).vars['x']) ∈ ["#1+5","5+#1"]
@test string(decompile(["inp z", "add y 2", "add x y", "add x z", "add x y"],[inpExpression(1,1,9)]).vars['x']) ∈ ["#1+4","4+#1"]

println("Testing complete")

@show decompile(lines(24), [inpExpression(i,1,9) for i in 1:14]).vars['z']