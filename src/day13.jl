#=
day13:
- Julia version: 1.8.3
- Author: Paul.Mealor
- Date: 2022-13-13
=#
using Test

lines = open(readlines, "src/day13-input.txt")
example1 = open(readlines, "src/day13-example-1.txt")

parseLine(line) = eval(Meta.parse(line))
@test parseLine("[1,2,[3,4]]") == [1,2,[3,4]]

parseLines(lines) = [parseLine.(lines[i:i+1]) for i in 1:3:length(lines)]

tryFirst(A, default) = isempty(A) ? default : first(A)

compare(a::Int,b::Int) = a < b ? -1 : a > b ? 1 : 0
compare(A::Vector,B::Vector) = tryFirst(filter(e->e!=0, [
    !checkbounds(Bool,A,i) ? -1 : !checkbounds(Bool,B,i) ? 1 : compare(A[i], B[i])
    for i in 1:max(length(A),length(B))]), 0)
compare(A::Vector,b::Int) = compare(A,[b,])
compare(a::Int,B::Vector) = compare([a,],B)
@test compare(1,2) < 0
@test compare(2,2) == 0
@test compare(3,2) > 0
@test compare(1,[1,2]) < 0
@test compare(1,[1]) == 0
@test compare(2,[1]) > 0
@test compare([1],[1]) == 0
@test compare([1,1],[1]) > 0
@test compare([1],[1,1]) < 0

orderedIndices(pairs) = findall(pair -> compare(pair...) <= 0, pairs)

@test orderedIndices(parseLines(example1)) == [1,2,4,6]

part1 = sum ∘ orderedIndices ∘ parseLines

@test part1(example1) == 13

@time println(part1(lines))
