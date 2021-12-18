#=
day18:
- Julia version: 1.7.0
- Author: Paul.Mealor
- Date: 2021-12-18
=#

using AoC, Test

struct SfNumber
    left::Union{Int,SfNumber}
    right::Union{Int,SfNumber}
end
Base.show(io::IO, n::SfNumber) = print(io, "[",n.left,",",n.right,"]")

function sfparse(line)
    if !isnothing(match(r"^\d+$", line))
        return parse(Int, line)
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

explode(n::Int, depth=1) = (0,0,n)
function explode(n::SfNumber, depth=1)
    if depth > 4
        return (n.left, n.right, 0)
    end

    (leftFragment, rightFragment, left) = explode(n.left, depth+1)
    if left != n.left
        right = applyExplodeRight(n.right, rightFragment)
        return (leftFragment, 0, SfNumber(left, right))
    end

    (leftFragment, rightFragment, right) = explode(n.right, depth+1)
    if right != n.right
        left = applyExplodeLeft(n.left, leftFragment)
        return (0, rightFragment, SfNumber(left, right))
    end

    return (0,0,n)
end

applyExplodeRight(n::Int, fragment) = n+fragment
applyExplodeRight(n::SfNumber, fragment) = SfNumber(applyExplodeRight(n.left, fragment), n.right)

applyExplodeLeft(n::Int, fragment) = n+fragment
applyExplodeLeft(n::SfNumber, fragment) = SfNumber(n.left, applyExplodeLeft(n.right, fragment))

@test explode(sfparse("[[[[[9,8],1],2],3],4]"))[3] == sfparse("[[[[0,9],2],3],4]")
@test explode(sfparse("[7,[6,[5,[4,[3,2]]]]]"))[3] == sfparse("[7,[6,[5,[7,0]]]]")
@test explode(sfparse("[[6,[5,[4,[3,2]]]],1]"))[3] == sfparse("[[6,[5,[7,0]]],3]")
@test explode(sfparse("[[3,[2,[1,[7,3]]]],[6,[5,[4,[3,2]]]]]"))[3] == sfparse("[[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]]")
@test explode(sfparse("[[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]]"))[3] == sfparse("[[3,[2,[8,0]]],[9,[5,[7,0]]]]")

split(n::Int) = n > 9 ? SfNumber(n ÷ 2, (n+1) ÷ 2) : n
function split(n::SfNumber)
    left = split(n.left)
    if left != n.left
        return SfNumber(left, n.right)
    end

    right = split(n.right)
    if right != n.right
        return SfNumber(n.left, right)
    end

    return n
end

@test split(9) == 9
@test split(10) == SfNumber(5,5)
@test split(11) == SfNumber(5,6)
@test split(12) == SfNumber(6,6)

function sfreduce(n)
    while true
        (_,_,newValue) = explode(n)
        if newValue == n
            newValue = split(n)
            if newValue == n
                return n
            end
        end
        n = newValue
    end
end

@test sfreduce(sfparse("[[[[[4,3],4],4],[7,[[8,4],9]]],[1,1]]")) == sfparse("[[[[0,7],4],[[7,8],[6,0]]],[8,1]]")

sfsum(l,r) = sfreduce(SfNumber(l,r))
sfsum(args...) = sfsum(sfsum(args[1], args[2]), args[3:end]...)
@test sfsum(sfparse("[[[0,[4,5]],[0,0]],[[[4,5],[2,6]],[9,5]]]"), sfparse("[7,[[[3,7],[4,3]],[[6,3],[8,8]]]]")) == sfparse("[[[[4,0],[5,4]],[[7,7],[6,0]]],[[8,[7,7]],[[7,9],[5,0]]]]")
@test sfsum(sfparse("[[[[7,7],[7,7]],[[8,7],[8,7]]],[[[7,0],[7,7]],9]]"), sfparse("[[[[4,2],2],6],[8,7]]")) == sfparse("[[[[8,7],[7,7]],[[8,6],[7,7]]],[[[0,7],[6,6]],[8,7]]]")

magnitude(n::Int) = n
magnitude(n::SfNumber) = 3*magnitude(n.left) + 2*magnitude(n.right)
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
                value = magnitude(sfsum(lines[i],lines[j]))
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
@show lines(18) |> ll -> @time part2(ll)
