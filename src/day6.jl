#=
day3:
- Julia version: 1.8.3
- Author: Paul.Mealor
- Date: 2022-12-05
=#
using Test

lines = open(readlines, "src/day6-input.txt")


function startOfPacket(signal, markerLength=4)
    for i in markerLength:length(signal)
        marker = Set([c for c in signal[i+1-markerLength:i]])

        if length(marker) == markerLength
            return i
        end
    end
end


@test startOfPacket("mjqjpqmgbljsphdztnvjfqwrcgsmlb") == 7
@test startOfPacket("bvwbjplbgvbhsrlpgdmjqwftvncz") == 5

show(@time startOfPacket(lines))
