#=
day20:
- Julia version: 1.8.3
- Author: Paul.Mealor
- Date: 2022-12-20
=#
using Test
using Base.Iterators
using Memoize
include("AoC.jl")

input = open(readlines, "src/day20-input.txt")
example1 = open(readlines, "src/day20-example-1.txt")

mutable struct Element
    value::Int
    next::Union{Nothing, Element}
    prev::Union{Nothing, Element}
    currentNext::Union{Nothing, Element}
    currentPrev::Union{Nothing, Element}
end
function Element(value)
    e = Element(value,nothing,nothing,nothing,nothing)
    e.next = e
    e.prev = e
    e.currentNext = e
    e.currentPrev = e
    return e
end

parseInput(lines, multiplier = 1) = multiplier * parse.(Int, lines) |> asLinkedList

function asLinkedList(numbers)
    start = nothing
    last = nothing
    zero = nothing
    for number in numbers
        if start == nothing
            start = Element(number)
            last = start
        else
            next = Element(number)

            next.prev = last
            next.next = last.next
            last.next.prev = next
            last.next = next

            next.currentPrev = last
            next.currentNext = last.currentNext
            last.currentNext.currentPrev = next
            last.currentNext = next

            last = next
        end
        if number == 0
            zero = last
        end
    end
    return (start,zero)
end
@test asLinkedList([1,2,0,3])[1].value == 1
@test asLinkedList([1,2,0,3])[1].next.value == 2
@test asLinkedList([1,2,0,3])[1].next.next.value == 0
@test asLinkedList([1,2,0,3])[1].next.next.next.value == 3
@test asLinkedList([1,2,0,3])[1].next.next.next.next.value == 1
@test asLinkedList([1,2,0,3])[1].prev.value == 3
@test asLinkedList([1,2,0,3])[1].prev.prev.value == 0
@test asLinkedList([1,2,0,3])[1].prev.prev.prev.value == 2
@test asLinkedList([1,2,0,3])[1].prev.prev.prev.prev.value == 1

@test asLinkedList([1,2,0,3])[1].value == 1
@test asLinkedList([1,2,0,3])[1].currentNext.value == 2
@test asLinkedList([1,2,0,3])[1].currentNext.currentNext.value == 0
@test asLinkedList([1,2,0,3])[1].currentNext.currentNext.currentNext.value == 3
@test asLinkedList([1,2,0,3])[1].currentNext.currentNext.currentNext.currentNext.value == 1
@test asLinkedList([1,2,0,3])[1].currentPrev.value == 3
@test asLinkedList([1,2,0,3])[1].currentPrev.currentPrev.value == 0
@test asLinkedList([1,2,0,3])[1].currentPrev.currentPrev.currentPrev.value == 2
@test asLinkedList([1,2,0,3])[1].currentPrev.currentPrev.currentPrev.currentPrev.value == 1

@test asLinkedList([1,2,0,3])[2].value == 0

function move!(e, size)

    value = mod(e.value, size - 1)

    if value == 0
        return e
    end

    target = e
    e.currentPrev.currentNext = e.currentNext
    e.currentNext.currentPrev = e.currentPrev


    if value > size ÷ 2
        for i in 0:-1:(value + 1 - size)
            target = target.currentPrev
        end
    else
        for i in 1:value
            target = target.currentNext
        end
    end

    e.currentNext = target.currentNext
    e.currentPrev = target
    target.currentNext.currentPrev = e
    target.currentNext = e

end
function mix!(start, size)
    current = start

    move!(current, size)
    while current.next !== start
        current = current.next
        move!(current, size)
    end
    return start
end

function forwards(current, n)
    for i in 1:n
        current = current.currentNext
    end
    return current
end

function display(start::Element)
    current = start

    print(current.value)
    print(", ")
    while current.currentNext !== start
        current = current.currentNext
        print(current.value)
        print(", ")
    end
    println()
end

function part1(lines)
    (start,zero) = parseInput(lines)

    mix!(start, length(lines))

    @show x = forwards(zero, 1000).value
    @show y = forwards(zero, 2000).value
    @show z = forwards(zero, 3000).value

    return x + y + z
end

function part2(lines)
    (start,zero) = parseInput(lines, 811589153)

    for i = 1:10
        mix!(start, length(lines))
    end

    @show x = forwards(zero, 1000).value
    @show y = forwards(zero, 2000).value
    @show z = forwards(zero, 3000).value

    return x + y + z
end

@time @test part1(example1) == 3
@time @test part2(example1) == 1623178306

println("Calculating...")
@time result = part1(input)
println(result)
@test result > 6266
@test result == 6387
@time println(part2(input))
