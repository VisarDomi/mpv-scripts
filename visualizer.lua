local visualizer_on = false
local file_path = nil
local playback_position = 0

mp.add_key_binding("Ctrl+b", "cycle-visualizer", function()
    local width = mp.get_property_native("width")
    local height = mp.get_property_native("height")

    visualizer_on = not visualizer_on

    if visualizer_on then
        file_path = mp.get_property("path")
        playback_position = mp.get_property_number("time-pos")

        local lavfi = "[aid1] asplit [ao][a];" ..
                    "[a] afifo, aformat=channel_layouts=stereo, " ..
                    "firequalizer=gain='if(gte(f,200),10,0)':scale=linlog [a_eq];" ..
                    "[a_eq] showcqt=s=" .. width .. "x" .. height .. ", format=rgba, colorkey=black [v];" ..
                    "[vid1][v] overlay=format=auto [vo]"
        mp.set_property("options/lavfi-complex", lavfi)
    else
        if file_path then
            -- Load the video from the beginning
            mp.commandv("loadfile", file_path, "replace")
            mp.set_property_number("time-pos", playback_position)

            -- Delayed removal of the filter
            mp.add_timeout(0.1, function()
                mp.set_property("options/lavfi-complex", "")
            end)
        end
    end
end)
