module RegisterPOI

import REPL
using REPL.TerminalMenus, Dates, UUIDs
using JuliaDB, CSV

export main

tosecond(t::T) where {T <: TimePeriod} = t/convert(T, Second(1))

tonanosecond(x) = Nanosecond(round(Int, parse(Float64, x)*1e9))

function parsetime(x)
    xs = split(x, ':')
    n = length(xs)
    if n == 1
        tonanosecond(x)
    elseif n == 2
        Nanosecond(Minute(xs[1])) + tonanosecond(xs[2])
    else
        Nanosecond(Hour(xs[1])) + Nanosecond(Minute(xs[2])) + tonanosecond(xs[3])
    end
end

function goodtime(x)
    try
        return parsetime(x)
    catch
        return nothing
    end
end

function setgetdefault(i::Int, video_menu::RadioMenu)
    if i == 1
        i = findlast(isequal(video_menu.options[1]), video_menu.options)
        i = i - 1
    else
        i = i - 1
        video_menu.options[1] = videofile[i].file_name
    end
    return i
end


done_file = joinpath(homedir(), "RegisterPOI.csv")
if !isfile(done_file)
    open(done_file, "w") do io
        println(io, "interval,video,start,stop,comment")
    end
end

videofile = load(joinpath(@__DIR__, "videofile.jdb"))
video_menu = RadioMenu(["---"; string.(select(videofile, :file_name))])

mutable struct TimeContainer
    x::Nanosecond
end
lasttime = TimeContainer(Nanosecond(0))


function main()
    x0 = CSV.File(done_file)
    tbl = load(joinpath(@__DIR__, "data.jdb"))
    if length(x0) ≠ 0
        x1 = loadtable(done_file) |> dropmissing
        x2 = setcol(x1, :interval => UUID.(select(x1, :interval)))
        tbl = join(tbl, x2, lkey = :interval, rkey = :interval, how = :anti)
    end
    printstyled("POIs left: ", length(tbl), '\n', bold = true, color = :cyan)
    groupby(tbl, :experiment) do g
        t = table(g)
        printstyled("Experiment: ", bold = true, color = :blue)
        println(t[1].experiment_folder)
        groupby(t, :run) do r
            printstyled("Run: ", bold = true, color = :green)
            println(r[1].id)
            printstyled("The calibration video for this run was: ", bold = true, color = :normal)
            println(r[1].file_name)
            for poi in r
                @label start_poi
                printstyled("POI: ", bold = true, color = :yellow)
                println(poi.type)
                i = request("In which video file did this POI start?", video_menu)
                i = setgetdefault(i, video_menu)
                if i == 0
                    printstyled("No default set yet. Try again…\n", bold = true, color = :red)
                    @goto start_poi
                end
                start_video = videofile[i]
                @label start_time
                println("When in this video file did this POI start (press Enter for ", Time(0) + lasttime.x, ")?" )
                __start = strip(readline())
                if !isempty(__start)
                    tmp = goodtime(__start)
                    if tmp ≡ nothing
                        printstyled("Malformed time. Try again…\n", bold = true, color = :red)
                        @goto start_time
                    end
                    if tmp > start_video.duration
                        printstyled("Starting time is longer than the duration of this video file (~$(round(Int, tosecond(start_video.duration))) seconds). Try again…\n", bold = true, color = :red)
                        @goto start_time
                    end
                    lasttime.x = tmp
                end
                _start = lasttime.x
                start = reduce(+, [r.duration for r in videofile if r.video == start_video.video && r.index < start_video.index], init = _start)
                # println("Start time specified: ", Time(0) + start)
                i = request("In which video file did this POI stop?", video_menu)
                i = setgetdefault(i, video_menu)
                stop_video = videofile[i]
                if start_video.video ≠ stop_video.video
                    g1 = filter(isequal(start_video.video), videofile, select = :video)
                    v1 = select(g1, :file_name)
                    g2 = filter(isequal(stop_video.video), videofile, select = :video)
                    v2 = select(g2, :file_name)
                    printstyled("These two videos do not belong to the same group. Videos related to the starting video are:\n", bold = true, color = :red)
                    println.(v1)
                    printstyled("and videos related to the stoping one are:\n", bold = true, color = :red)
                    println.(v2)
                    printstyled("Choose again…\n", bold = true, color = :red)
                    @goto start_poi
                end
                @label stop_time
                println("When in this video file did this POI stop (press Enter for ", Time(0) + lasttime.x, ")?" )
                __stop = strip(readline())
                if !isempty(__stop)
                    tmp = goodtime(__stop)
                    if tmp ≡ nothing
                        printstyled("Malformed time. Try again…\n", bold = true, color = :red)
                        @goto stop_time
                    end
                    if tmp > stop_video.duration
                        printstyled("stoping time is longer than the duration of this video file (~$(round(Int, tosecond(stop_video.duration))) seconds). Try again…\n", bold = true, color = :red)
                        @goto stop_time
                    end
                    lasttime.x = tmp
                end
                _stop = lasttime.x
                stop = reduce(+, [r.duration for r in videofile if r.video == stop_video.video && r.index < stop_video.index], init = _stop)
                if start > stop
                    printstyled("Stoping time comes after starting time. Try again…\n", bold = true, color = :red)
                    @goto stop_time
                end
                # println("Stop time specified: ", Time(0) + stop)
                println("Comments?")
                _comment = strip(readline())
                comment = isempty(_comment) ? missing : _comment
                println("--------------------------------------------------")
                println("Save and continue [enter] or Undo [u] ?")
                _undo = strip(readline())
                if !isempty(_undo)
                    println("----------------Undoing last input!---------------")
                    @goto start_poi
                end
                ((interval = string(poi.interval), video = string(start_video.video), start = Dates.value(start), stop = Dates.value(stop), comment = comment), ) |> CSV.write(done_file, append = true)
                # @assert !haskey(done, poi.interval) "record already exists in the database"
                # done[poi.interval] = (video = start_video.video, start = start, stop = stop, comment = comment)
            end
        end
    end
end

end # module
