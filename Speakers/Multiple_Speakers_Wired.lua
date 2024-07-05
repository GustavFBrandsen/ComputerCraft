function play_audio(speakers, buffer, vol)
    for i = 1, speakers.n do
        speakers[i].playAudio(buffer, vol)
    end
end

function play_music(sound)
    local speakers = table.pack(peripheral.find("speaker"))
    local dfpwm = require("cc.audio.dfpwm")
    local decoder = dfpwm.make_decoder()

    print("Num of speakers: ", speakers.n)

    for chunk in io.lines(sound, 16 x 1024) do
        local buffer = decoder(chunk)
        for i = 1, speakers.n do
            play_audio(speakers, buffer, 3.0)
            os.pullEvent("speaker_audio_empty")
        end
    end
end

function commands(command)
    if command == "play" then
        print("Enter music file name: ")
        filename = read()
        play_music("/music/" .. filename .. ".dfpwm")
    elseif command == "stop" then
    stop_music()
    elseif command == "exit" then
        return "exit"
    else
        print("Unknown command: " command>
    end

    while true do
    print("Enter a command (play, stop, exit)")
    command = read()
    c = commands(command)
    if c == "exit" then
        break
    end
end