include("algorithm.jl")

function parseinput()
    people = split(input("What are the participants' names? (name1, name2, etc)"), r"(,\s*)")
    blocks = parse(Int, input("How many blocks?"))
    blockresults = []
    blocktasks = []
    eventindex = 1
    for i in 1:blocks
        events = parse(Int, input("How many events in block $i?"))
        rawskills = Vector{Int}[]
        for j in 1:events
            rawskill = split(input("What are the skill values for event $j? (1, 2, 3, etc)"), r"(,\s*)")
            push!(rawskills, parse.(Int, rawskill))
        end
        mat = hcat(rawskills...)'
        skills = Vector{Int}[]
        for i in 1:size(mat)[2]
            push!(skills, mat[:,i])
        end
        pairs = makepairs(Person.(skills, people))
        task = Threads.@spawn begin
            push!(blockresults, constructAndRate(pairs, Duo[], events))
        end
        push!(blocktasks, task)
    end
    wait.(blocktasks)
    println("Printing results:")
    for i in 1:length(blockresults)
        println("for event $i, any of the following pair combinations will work: ")
        for res in telescope(blockresults[i][2])
            println(map(x->join(x.names, " & "), res))
        end
        
        println("With a total score of $(blockresults[i][1])")
    end
    #nums = parse.(Int, split(lines[2], " "))

end

function input(xs...)
    println(xs...)
    readline()
end

parseinput()