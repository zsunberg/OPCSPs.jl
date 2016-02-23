#!/usr/bin/julia

using ArgParse

s = ArgParseSettings()
@add_arg_table s begin
    "script"
        help = "the script to be run"
        required = true
    "name"
        help = "name for the simulation"
        required = false
end

args = parse_args(ARGS, s)
name = args["name"] == nothing ? args["script"] : args["name"]
log = "simlog.md" # TODO make arg
datestring = Dates.format(Dates.now(), "u d HH:MM") # TODO make arg

tmp = tempname()
run(pipeline(`julia $(args["script"])`, `tee $tmp`)) # TODO make cross platform

logstring = """
# [$datestring] $name

## Input
```julia
$(readall(args["script"]))
```
## Output
```
$(readall(tmp))
```
"""

open(log, "a") do f
    write(f, logstring)
end
