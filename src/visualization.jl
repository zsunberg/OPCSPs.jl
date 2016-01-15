using Mustache
using DataFrames

function Base.writemime(f::IO, ::MIME"text/html", op::OPCSP)
    scale = 100
    offset = 200
    size = 1.0
    xs = scale*[p[1] for p in op.positions]+offset
    ys = scale*[p[2] for p in op.positions]+offset
    rs = size*sqrt(op.r)
    us = rs+size*sqrt(diag(op.covariance)) 
    nodes=DataFrame(xs=xs, ys=ys, rs=rs, us=us)

    edge_list = []
    for i in 1:length(op)
        for j in i+1:length(op)
            if op.covariance[i,j] > 0.0
                push!(edge_list, (i,j))
            end
        end
    end
    x1s = scale*[op.positions[i][1] for (i,j) in edge_list]+offset
    x2s = scale*[op.positions[j][1] for (i,j) in edge_list]+offset
    y1s = scale*[op.positions[i][2] for (i,j) in edge_list]+offset
    y2s = scale*[op.positions[j][2] for (i,j) in edge_list]+offset
    ws = 2.0*size*sqrt(Float64[abs(float(op.covariance[i,j])) for (i,j) in edge_list])
    edges=DataFrame(x1s=x1s, x2s=x2s, y1s=y1s, y2s=y2s, ws=ws)

    template = readall(joinpath(dirname(@__FILE__()), "op_vis.html"))
    out = render(template,Dict{Any,Any}("nodes"=>nodes,"edges"=>edges))
    println(f,out)
    # open("/tmp/$title.html", "w") do f
    #     write(f, out)
    # end
    # run(`google-chrome /tmp/$title.html`)
end
