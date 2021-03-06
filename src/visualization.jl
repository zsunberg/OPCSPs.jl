using Mustache
using DataFrames
import Base: writemime

function writemime(f::IO, ::MIME"text/html", op::OPCSP)
    scale = 150
    offset = 150
    size = 0.5
    xs = scale*[p[1] for p in op.positions]+offset
    ys = scale*[p[2] for p in op.positions]+offset
    # rs = size*sqrt(op.r)
    maxsr = maximum(sqrt(op.r))
    opac = sqrt(op.r)./maxsr
    rs = 5.0*ones(length(op))
    us = size*sqrt(diag(op.covariance)) 
    nodes=DataFrame(xs=xs, ys=ys, rs=rs, us=us, opac=opac)

    labels=DataFrame(xs=xs.+10, ys=ys.+15, ls=1:length(op.r))

    edge_list = []
    for i in 1:length(op)
        for j in i+1:length(op)
            if abs(op.covariance[i,j]) > 0.0
                push!(edge_list, (i,j))
            end
        end
    end
    x1s = scale*[op.positions[i][1] for (i,j) in edge_list]+offset
    x2s = scale*[op.positions[j][1] for (i,j) in edge_list]+offset
    y1s = scale*[op.positions[i][2] for (i,j) in edge_list]+offset
    y2s = scale*[op.positions[j][2] for (i,j) in edge_list]+offset
    ws = 2.0*size*sqrt(Float64[abs(op.covariance[i,j]) for (i,j) in edge_list])
    edges=DataFrame(x1s=x1s, x2s=x2s, y1s=y1s, y2s=y2s, ws=ws)

    template = readall(joinpath(dirname(@__FILE__()), "op_vis.html"))
    out = render(template,Dict{Any,Any}("nodes"=>nodes,"edges"=>edges, "labels"=>labels))
    println(f,out)
    # open("/tmp/$title.html", "w") do f
    #     write(f, out)
    # end
    # run(`google-chrome /tmp/$title.html`)
end
