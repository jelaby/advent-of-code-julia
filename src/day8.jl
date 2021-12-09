#=
day8:
- Julia version: 1.7.0
- Author: Paul.Mealor
- Date: 2021-12-08
=#

using AoC, Test
using StructEquality # https://docs.juliahub.com/StructEquality/TwsrV/1.0.0/
using Base.Iterators: flatten
using Memoize

DIGITS = Dict('0'=>"abcefg",'1'=>"cf",'2'=>"acdeg",'3'=>"acdfg",'4'=>"bcdf",'5'=>"abdfg",'6'=>"abdefg",'7'=>"acf",'8'=>"abcdefg",'9'=>"abcdfg")
DIGIT_DECODER = Dict((v=>k) for (k,v) in DIGITS)
LENGTHS = Dict((k=>length(v)) for (k,v) in DIGITS)
UNIQUE_LENGTHS = Dict((v=>k) for (k,v) in filter((pair)->count(l->l==pair[2],values(LENGTHS))==1, LENGTHS))
SEGMENT_NAMES = ['a','b','c','d','e','f','g']

@memoize Dict allpermutations(n::Number) = allpermutations([1:n...])
@memoize Dict allpermutations(n::Vector) = allpermutationssorted(sort(n))
@memoize Dict function allpermutationssorted(n::Vector)
    if length(n) == 1
        return [n]
    end
    result = zeros(Int, length(n),0)
    for i in n
        remainder = setdiff(n, [i])

        for p in eachcol(allpermutations(remainder))
            p = [i;p...]
            result = hcat(result, p)
        end
    end
    return result
end

@test allpermutations(2) == [[1,2] [2,1]]
@test allpermutations(3) == [[1,2,3] [1,3,2] [2,1,3] [2,3,1] [3,1,2] [3,2,1]]
@test size(allpermutations(3),2) == 3*2*1
@test size(allpermutations(4),2) == 4*3*2*1
@test size(allpermutations(5),2) == 5*4*3*2*1

struct Display
    combos :: Vector{String}
    display :: Vector{String}
end
@def_structequal Display

function parseDisplay(line)
    (left,right) = split(line, " | ")
    return Display(split(left," "), split(right, " "))
end

@test parseDisplay("be cfbegad cbdgef fgaecd cgeb fdcge agebfd fecdb fabcd edb | fdgacbe cefdb cefbgd gcbe") ==
    Display(["be","cfbegad","cbdgef","fgaecd","cgeb","fdcge","agebfd","fecdb","fabcd","edb"],["fdgacbe","cefdb","cefbgd","gcbe"])

function evaluateCipher(combos)
    # keys are the displayed segments, values are the actual values
    segmentMappings = Dict(c => Set(SEGMENT_NAMES) for c in SEGMENT_NAMES)
    return Dict(k=>[v...][1] for (k,v) in evaluateCipher(combos, segmentMappings))
end

function evaluateCipherCandidate(displayedCombos, displayedCombo, segmentMappings, expectedCombos)
    if isempty(displayedCombos)
        return segmentMappings
    end

    actualDisplay = [c for c in displayedCombo]
    for expectedDisplay in filter(d -> length(d) == length(displayedCombo), expectedCombos)
        candidateMappingTo = [c for c in expectedDisplay]

        for candidateMappingFrom in eachcol(allpermutations(actualDisplay))
            candidateMappings = copy(segmentMappings)
            okMapping = true
            for c in eachindex(candidateMappingFrom)
                candidateMappings[candidateMappingFrom[c]] = intersect(candidateMappings[candidateMappingFrom[c]], candidateMappingTo[c])
                if isempty(candidateMappings[candidateMappingFrom[c]])
                    okMapping = false
                    break
                end
            end
            if okMapping
                result = evaluateCipher(setdiff(displayedCombos,[displayedCombo]), candidateMappings, setdiff(expectedCombos, [expectedDisplay]))
                if !isnothing(result)
                    return result
                end
            end
        end
    end
    return nothing
end

function evaluateCipher(displayedCombos, segmentMappings, expectedCombos=[values(DIGITS)...])

    if isempty(displayedCombos)
        return segmentMappings
    end

    fixedLengthCombos = filter(c -> length(c) ∈ keys(UNIQUE_LENGTHS), displayedCombos); lt=(x,y)->length(x)<length(y)

    if !isempty(fixedLengthCombos)
        displayedCombo = argmin(c->length(c), fixedLengthCombos)
        return evaluateCipherCandidate(displayedCombos, displayedCombo, segmentMappings, expectedCombos)
    end

    for displayedCombo in displayedCombos
        result = evaluateCipherCandidate(displayedCombos, displayedCombo, segmentMappings, expectedCombos)
        if !isnothing(result)
            return result
        end
    end
    return nothing
end
@test evaluateCipher(["acedgfb","cdfbe","gcdfa","fbcad","dab","cefabd","cdfgeb","eafb","cagedb","ab"]) == Dict('d'=>'a','e'=>'b','a'=>'c','f'=>'d','g'=>'e','b'=>'f','c'=>'g')

decipher(displayedCombos,cipher) = [decipher(d,cipher) for d in displayedCombos]
function decipher(displayedCombo::AbstractString, cipher)
    return String(sort([cipher[c] for c in displayedCombo]))
end
@test decipher("acedgfb", Dict('d'=>'a','e'=>'b','a'=>'c','f'=>'d','g'=>'e','b'=>'f','c'=>'g') ) == "abcdefg"

decode(display) = String([DIGIT_DECODER[d] for d in display])
@test decode(["abdfg"]) == "5"
@test decode(["abdfg","acdfg"]) == "53"

function evaluateDisplay(display::Display)
    cipher = evaluateCipher(display.combos)
    correctedDisplay = decipher(display.display, cipher)
    decode(correctedDisplay)
end

@test evaluateDisplay(Display(["acedgfb","cdfbe","gcdfa","fbcad","dab","cefabd","cdfgeb","eafb","cagedb","ab"],["cdfeb","fcadb","cdfeb","cdbaf"])) == "5353"


part1(lines) = part1([parseDisplay(line) for line in lines])
function part1(displays :: Array{Display})
    allDigits = [flatten(displays .|> d->d.display)...]
    uniqueLengthDigits = filter(allDigits) do digit
        length(digit) ∈ keys(UNIQUE_LENGTHS)
    end
    return length(uniqueLengthDigits)
end

@test part1(exampleLines(8,2)) == 26

part2(lines) = part2([parseDisplay(line) for line in lines])
function part2(displays :: Array{Display})
    displays = [evaluateDisplay(d) for d in displays]
    return sum(parse.(Int, displays))
end

@test part2(exampleLines(8,2)) == 61229

lines(8) |> ll -> @time part1(ll) |> show
exampleLines(8,2) |> ll -> @time part2(ll) |> show
lines(8) |> ll -> @time part2(ll) |> show
