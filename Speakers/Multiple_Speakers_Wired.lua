function play_audio(speakers, buffer, vol)
    for i = 1, #speakers do
        speakers[i].playAudio(buffer, vol)
    end
end

function play_music(sound)
    local speakers = {peripheral.find("speaker")}
    local dfpwm = require("cc.audio.dfpwm")
    local decoder = dfpwm.make_decoder()

    print("Num of speakers: ", #speakers)

    for chunk in io.lines(sound, 16 * 1024) do
        local buffer = decoder(chunk)
        play_audio(speakers, buffer, 3.0)
        os.pullEvent("speaker_audio_empty")
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
        print("Unknown command: " .. command)
    end
end

while true do
    print("Enter a command (play, stop, exit)")
    command = read()
    local c = commands(command)
    if c == "exit" then
        break
    end
end
