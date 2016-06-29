#!/usr/bin/julia

# TODO allow specification of log name
# TODO auto log name by date
# TODO how to handle arbitrary julia arguments

using ArgParse

s = ArgParseSettings()
@add_arg_table s begin
    "script"
        help = "the script to be run"
        required = true
    "name"
        help = "name for the simulation"
        required = false
    "-p"
        help = "the -p argument for julia"
        arg_type = Int
        default = 0
    "-i"
        help = "run julia with the -i option"
        action = :store_true
end

args = parse_args(ARGS, s)
name = args["name"] == nothing ? args["script"] : args["name"]
log = "simlog.md" # TODO make arg
datestring = Dates.format(Dates.now(), "u d HH:MM") # TODO make arg
jargs = Any["--color=yes"]
for a in ["i"]
    if args[a]
        push!(jargs, "-$a")
    end
end
if args["p"] > 0
    push!(jargs, "-p")
    push!(jargs, args["p"])
end

jargstring = join(jargs, " ")

tmp = tempname()
script_contents = readall(args["script"])
run(pipeline(`julia $jargs $(args["script"])`, `tee $tmp`)) # TODO make cross platform
# run(pipeline(`julia $jargs $(args["script"])`, `tee $tmp`))

logstring = """
# [$datestring] $name

## Input
```julia
$script_contents
```
## Output
```
$(readall(tmp))
```
"""

open(log, "a") do f
    write(f, logstring)
end
