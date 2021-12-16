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



function lineToStream(line)
    @show charsPerWord = sizeof(UInt) * 2
    @show length(line), length(line) % charsPerWord, line
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

function readPackets!(stream; maxLength=typemax(UInt), maxPackets=typemax(UInt))
    bitsRead = 0
    packetsRead = 0
    packets = AbstractPacket[]
    while bitsRead < maxLength && packetsRead < maxPackets
        (packet, bitsReadThisTime) = readPacket!(stream)
        push!(packets, packet)
        bitsRead += bitsReadThisTime
        packetsRead += 1
    end
    return (packets, bitsRead)
end

function readPacket!(stream)
    version = read!(stream, 3)
    typeId = read!(stream, 3)
    bitsRead = 6

    if typeId == 4
        @show (value, bitsReadThisTime) = readLiteralValue!(stream)
        bitsRead += bitsReadThisTime
        return (ValuePacket(version, value), bitsRead)
    else
        # operator packet
        lengthTypeId = read!(stream, 1)
        if lengthTypeId == 0
            contentLength = read!(stream, 15)
            @show (packets, bitsReadThisTime) = readPackets!(stream; maxLength = contentLength)
            bitsRead += bitsReadThisTime
            return (OperatorPacket(version, packets), bitsRead)
        else
            packetCount = read!(stream, 11)
            @show (packets, bitsReadThisTime) = readPackets!(stream; maxPackets = packetCount)
            bitsRead += bitsReadThisTime
            return (OperatorPacket(version, packets), bitsRead)
        end
    end
end

totalValue(packet::ValuePacket) = packet.value
totalValue(packet::OperatorPacket) = +(totalValue.(packet.packets)...)

totalVersions(packet::ValuePacket) = packet.version
totalVersions(packet::OperatorPacket) = packet.version +(totalVersions.(packet.packets)...)

function part1(line)
    (packet, bitsRead) = readPacket!(lineToStream(line))

    @show packet

    return signed(totalVersions(packet))
end

@test part1("D2FE28") == 6
@test part1("8A004A801A8002F478") == 16
@test part1("620080001611562C8802118E34") == 12
@test part1("C0015000016115A2E0802F182340") == 23
@test part1("A0016C880162017C3686B18A3D4780") == 31

@show lines(16)[1] |> l -> @time part1(l)