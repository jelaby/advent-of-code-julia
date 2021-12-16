#=
day16:
- Julia version: 1.7.0
- Author: Paul.Mealor
- Date: 2021-12-16
=#

using AoC, Test

const UINT_BITS = sizeof(UInt) * 8
const UINT_ONES = typemax(UInt)

mutable struct BitStream{T}
    values::Vector{T}
    byteOffset::UInt
    bitOffset::UInt
end
BitStream(values::Vector{T}) where T = BitStream{T}(values,one(UInt),zero(UInt))

function read!(stream::BitStream{T}, n)::UInt where T
    elmask = typemax(unsigned(T))
    elbits = count_ones(elmask)
    stream
    result::UInt = 0
    while n > 0
        if (stream.byteOffset > length(stream.values))
            throw(BoundsError(stream.values, stream.byteOffset))
        end
        remainingBitsInByte = elbits - stream.bitOffset
        bitsToRead = min(remainingBitsInByte, n)

        mask = elmask >> (elbits - bitsToRead)
        bits = (stream.values[stream.byteOffset] >> (remainingBitsInByte - bitsToRead)) & mask

        result = (result << bitsToRead) | bits

        stream.bitOffset += bitsToRead
        n -= bitsToRead
        if stream.bitOffset >= elbits
            stream.bitOffset = 0
            stream.byteOffset += 1
        end
    end

    return result
end
testStream = BitStream([0b10101110_00100000_00000000_00000000])
@test read!(testStream, 3) == 0b101
@test read!(testStream, 3) == 0b011
@test read!(testStream, 5) == 0b10001
testStream = BitStream(UInt8[0b10101110, 0b00100000, 0b00000000, 0b00000000])
@test read!(testStream, 3) == 0b101
@test read!(testStream, 3) == 0b011
@test read!(testStream, 5) == 0b10001


function eof(stream::BitStream)
    return stream.byteOffset > length(stream.values)
end

function lineToStream(line)
    charsPerWord = sizeof(UInt) * 2
    length(line), length(line) % charsPerWord, line
    if length(line) % charsPerWord != 0
        line = rpad(line, length(line) + charsPerWord - (length(line) % charsPerWord), '0')
    end
    return BitStream([line[I:I+charsPerWord-1] for I in 1:charsPerWord:length(line)] |> ll -> parse.(UInt, ll; base=16))
end
@test lineToStream("ABCDEF12").values == UInt[0xabcdef12_00000000]

abstract type AbstractPacket end

struct ValuePacket <: AbstractPacket
    version::UInt
    value::UInt64
end

struct OperatorPacket <: AbstractPacket
    version::UInt
    operator
    packets::Vector{AbstractPacket}
end

function readLiteralValue!(stream)
    bitsRead = 0
    result = 0
    finished = false
    while !finished
        nextValue = read!(stream, 5)
        bitsRead += 5
        result = (result << 4) | (nextValue & 0b1111)
        if nextValue & 0b10000 == 0
            finished = true
        end
    end
    return (result, bitsRead)
end

function readPackets!(stream; maxLength=typemax(Int), maxPackets=typemax(Int))
    bitsRead = 0
    packetsRead = 0
    packets = AbstractPacket[]
    while bitsRead < maxLength && packetsRead < maxPackets && !eof(stream)
        (packet, bitsReadThisTime) = readPacket!(stream)
        push!(packets, packet)
        bitsRead += bitsReadThisTime
        packetsRead += 1
    end
    return (packets, bitsRead)
end

sumOperator(values) = +(0, values...)
productOperator(values) = *(1, values...)
minimumOperator(values) = min(values...)
maximumOperator(values) = max(values...)
greaterThanOperator(values) = values[1] > values[2]
lessThanOperator(values) = values[1] < values[2]
equalToOperator(values) = values[1] == values[2]

function readPacket!(stream)
    version = read!(stream, 3)
    typeId = read!(stream, 3)
    bitsRead = 6

    if typeId == 4
        (value, bitsReadThisTime) = readLiteralValue!(stream)
        bitsRead += bitsReadThisTime
        return (ValuePacket(version, value), bitsRead)
    else
        # operator packet
        lengthTypeId = read!(stream, 1)
        bitsRead += 1
        if lengthTypeId == 0
            contentLength = read!(stream, 15)
            bitsRead += 15
            (packets, bitsReadThisTime) = readPackets!(stream; maxLength = contentLength)
        else
            packetCount = read!(stream, 11)
            bitsRead += 11
            (packets, bitsReadThisTime) = readPackets!(stream; maxPackets = packetCount)
        end
        bitsRead += bitsReadThisTime

        if typeId == 0
            operator = sumOperator
        elseif typeId == 1
            operator = productOperator
        elseif typeId == 2
            operator = minimumOperator
        elseif typeId == 3
            operator = maximumOperator
        elseif typeId == 5
            operator = greaterThanOperator
        elseif typeId == 6
            operator = lessThanOperator
        elseif typeId == 7
            operator = equalToOperator
        end

        return (OperatorPacket(version, operator, packets), bitsRead)
    end
end

totalValue(packet::ValuePacket) = packet.value
totalValue(packet::OperatorPacket) = packet.operator(totalValue.(packet.packets))

totalVersions(packet::ValuePacket) = packet.version
totalVersions(packet::OperatorPacket) = packet.version +(totalVersions.(packet.packets)...)

function part1(line)
    (packet, bitsRead) = readPacket!(lineToStream(line))

    return signed(totalVersions(packet))
end

function part2(line)
    (packet, bitsRead) = readPacket!(lineToStream(line))

    return signed(totalValue(packet))
end

@test part1("D2FE28") == 6
@test part1("8A004A801A8002F478") == 16
@test part1("620080001611562C8802118E34") == 12
@test part1("C0015000016115A2E0802F182340") == 23
@test part1("A0016C880162017C3686B18A3D4780") == 31

@test part2("C200B40A82") == 3
@test part2("04005AC33890") == 54
@test part2("880086C3E88112") == 7
@test part2("CE00C43D881120") == 9
@test part2("D8005AC2A8F0") == 1
@test part2("F600BC2D8F") == 0
@test part2("9C005AC2F8F0") == 0
@test part2("9C0141080250320F1802104A08") == 1

@show lines(16)[1] |> l -> @time part1(l)
@show lines(16)[1] |> l -> @time part2(l)
