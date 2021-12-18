#=
day18:
- Julia version: 1.7.0
- Author: Paul.Mealor
- Date: 2021-12-18
=#

using AoC, Test

mutable struct SfNumber
    n::Union{Nothing, Int}
    left::Union{Nothing,SfNumber}
    right::Union{Nothing,SfNumber}
end
SfNumber(left::Int, right) = SfNumber(SfNumber(left), right)
SfNumber(left::SfNumber, right::Int) = SfNumber(left, SfNumber(right))
SfNumber(left::SfNumber, right::SfNumber) = SfNumber(nothing, left, right)
SfNumber(n::Int) = SfNumber(n, nothing, nothing)
Base.:(==)(l::SfNumber, r::SfNumber) = isnothing(l.n) == isnothing(r.n) && (isnothing(l.n) ? l.left == r.left && l.right == r.right : l.n == r.n)
@test SfNumber(1) == SfNumber(1)
@test SfNumber(1) != SfNumber(2)
@test SfNumber(1,1) == SfNumber(1,1)
@test SfNumber(1,1) != SfNumber(1,2)
function Base.show(io::IO, n::SfNumber)
    if isnothing(n.n)
        print(io, "[",n.left,",",n.right,"]")
    else
        print(io, n.n)
    end
end

function sfparse(line)
    if !isnothing(match(r"^\d+$", line))
        return SfNumber(parse(Int, line))
    end
    depth = 0
    for i in 2:length(line)-1
        c = line[i]
        if c == '['
            depth += 1
        elseif c == ']'
            depth -= 1
        elseif c == ','
            if depth == 0
                return SfNumber(sfparse(line[2:i-1]), sfparse(line[i+1:length(line)-1]))
            end
        end
    end
    throw(ArgumentError(line))
end

@test sfparse("[[1,2],[[3,4],5]]") == SfNumber(SfNumber(1,2),SfNumber(SfNumber(3,4),5))
@test sfparse("[[1,2],[[15,4],5]]") == SfNumber(SfNumber(1,2),SfNumber(SfNumber(15,4),5))

function explode!(n::SfNumber, depth=1)
    if !isnothing(n.n)
        return (false, 0, 0)
    end

    if depth > 4
        n.n = 0
        left = n.left.n
        right = n.right.n
        n.left = nothing
        n.right = nothing
        return (true, left, right)
    end

    (change, leftFragment, rightFragment) = explode!(n.left, depth+1)
    if change
        applyExplodeRight!(n.right, rightFragment)
        return (true, leftFragment, 0)
    end

    (change, leftFragment, rightFragment) = explode!(n.right, depth+1)
    if change
        applyExplodeLeft!(n.left, leftFragment)
        return (true, 0, rightFragment)
    end

    return (false, 0, 0)
end

applyExplodeRight!(n::Int, fragment) = n+fragment
function applyExplodeRight!(n::SfNumber, fragment)
    if !isnothing(n.n)
        n.n += fragment
        return n
    end
    applyExplodeRight!(n.left, fragment)
    return n
end

applyExplodeLeft!(n::Int, fragment) = n+fragment
function applyExplodeLeft!(n::SfNumber, fragment)
    if !isnothing(n.n)
        n.n += fragment
        return n
    end
    applyExplodeLeft!(n.right, fragment)
    return n
end

function testExplode(n::SfNumber)
    explode!(n)
    return n
end
@test testExplode(sfparse("[[[[[9,8],1],2],3],4]")) == sfparse("[[[[0,9],2],3],4]")
@test testExplode(sfparse("[7,[6,[5,[4,[3,2]]]]]")) == sfparse("[7,[6,[5,[7,0]]]]")
@test testExplode(sfparse("[[6,[5,[4,[3,2]]]],1]")) == sfparse("[[6,[5,[7,0]]],3]")
@test testExplode(sfparse("[[3,[2,[1,[7,3]]]],[6,[5,[4,[3,2]]]]]")) == sfparse("[[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]]")
@test testExplode(sfparse("[[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]]")) == sfparse("[[3,[2,[8,0]]],[9,[5,[7,0]]]]")

function split!(n::SfNumber)
    if !isnothing(n.n)
        if n.n > 9
            n.left = SfNumber(n.n ÷ 2)
            n.right = SfNumber((n.n+1) ÷ 2)
            n.n = nothing
            return true
        else
            return false
        end
    end

    change = split!(n.left)
    if change
        return true
    end

    change = split!(n.right)
    if change
        return true
    end

    return false
end

function testSplit(n)
    split!(n)
    return n
end
testSplit(n::Int) = testSplit(SfNumber(n))
@test testSplit(9) == SfNumber(9)
@test testSplit(10) == SfNumber(5,5)
@test testSplit(11) == SfNumber(5,6)
@test testSplit(12) == SfNumber(6,6)

function sfreduce!(n)
    while true
        (change, _,_) = explode!(n)
        if !change
            change = split!(n)
            if !change
                return n
            end
        end
    end
end

@test sfreduce!(sfparse("[[[[[4,3],4],4],[7,[[8,4],9]]],[1,1]]")) == sfparse("[[[[0,7],4],[[7,8],[6,0]]],[8,1]]")

sfsum(l,r) = sfreduce!(SfNumber(l,r))
sfsum(args...) = sfsum(sfsum(args[1], args[2]), args[3:end]...)
@test sfsum(sfparse("[[[0,[4,5]],[0,0]],[[[4,5],[2,6]],[9,5]]]"), sfparse("[7,[[[3,7],[4,3]],[[6,3],[8,8]]]]")) == sfparse("[[[[4,0],[5,4]],[[7,7],[6,0]]],[[8,[7,7]],[[7,9],[5,0]]]]")
@test sfsum(sfparse("[[[[7,7],[7,7]],[[8,7],[8,7]]],[[[7,0],[7,7]],9]]"), sfparse("[[[[4,2],2],6],[8,7]]")) == sfparse("[[[[8,7],[7,7]],[[8,6],[7,7]]],[[[0,7],[6,6]],[8,7]]]")

function magnitude(n::SfNumber)
    if !isnothing(n.n)
        return n.n
    else
        return 3*magnitude(n.left) + 2*magnitude(n.right)
    end
end
@test magnitude(sfparse("[[1,2],[[3,4],5]]")) == 143
@test magnitude(sfparse("[[[[0,7],4],[[7,8],[6,0]]],[8,1]]")) == 1384
@test magnitude(sfparse("[[[[1,1],[2,2]],[3,3]],[4,4]]")) == 445
@test magnitude(sfparse("[[[[3,0],[5,3]],[4,4]],[5,5]]")) == 791
@test magnitude(sfparse("[[[[5,0],[7,4]],[5,5]],[6,6]]")) == 1137
@test magnitude(sfparse("[[[[8,7],[7,7]],[[8,6],[7,7]]],[[[0,7],[6,6]],[8,7]]]")) == 3488

part1(lines) = magnitude(sfsum(sfparse.(lines)...))
@test part1(exampleLines(18,1)) == 4140

function part2(lines)
    lines = sfparse.(lines)
    biggest = 0
    for i in eachindex(lines)
        for j in eachindex(lines)
            if i != j
                value = magnitude(sfsum(deepcopy(lines[i]),deepcopy(lines[j])))
                if value > biggest
                    biggest = value
                end
            end
        end
    end
    return biggest
end

@test part2(exampleLines(18,1)) == 3993

@show lines(18) |> ll -> @time part1(ll)
@show lines(18) |> ll -> @time part1(ll)
@show lines(18) |> ll -> @time part2(ll)
