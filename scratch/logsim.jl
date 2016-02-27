#!/usr/bin/julia

# TODO allow specification of log name
# TODO auto log name by date

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
script_contents = readall(args["script"])
run(pipeline(`julia $(args["script"])`, `tee $tmp`)) # TODO make cross platform

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
