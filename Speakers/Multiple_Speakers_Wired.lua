-- Load the DFPWM decoder library
local dfpwm = require("cc.audio.dfpwm")
-- Find all connected speakers
local speakers = table.pack(peripheral.find("speaker"))

-- Global flags to control music playback
_G.stopMusic = false
_G.musicPlaying = false

-- Function to play a DFPWM file on all connected speakers
local function playDFPWMMusic(filePath)
    if #speakers == 0 then
        print("No speakers connected.")
        return
    end

    -- Create a decoder
    local decoder = dfpwm.make_decoder()

    -- Open the DFPWM file
    local file = fs.open(filePath, "rb")
    if not file then
        print("File not found: " .. filePath)
        return
    end

    -- Function to play decoded audio on all speakers
    local function playOnSpeakers(buffer)
        local funcs = {}
        for i = 1, #speakers do
            funcs[i] = function()
                while not speakers[i].playAudio(buffer) do
                    os.pullEvent("speaker_audio_empty")
                end
            end
        end
        parallel.waitForAll(table.unpack(funcs, 1, speakers.n))
    end

    -- Read and decode the file in chunks
    local chunkSize = 16 * 1024
    while true do
        local chunk = file.read(chunkSize)
        if not chunk then break end

        -- Decode the chunk
        local buffer = decoder(chunk)

        -- Play the decoded audio on all speakers
        playOnSpeakers(buffer)

        -- Check if we need to stop
        if _G.stopMusic then
            for i = 1, speakers.n do
                speakers[i].stop()
            end
            break
        end
    end

    -- Close the file
    file.close()
    _G.musicPlaying = false
end

-- Function to handle user input
local function handleUserInput()
    while true do
        local drive = peripheral.find("drive")
        local folder = ""
        local command, fileName = "", ""
        if drive and _G.stopMusic == true and _G.musicPlaying == false then
            local songName = drive.getDiskLabel()
            folder = "/disk/"
            command, fileName = "play", songName
        else
            print("Enter command (play <file> / stop / exit):")
            local input = read()
            folder = "/music/"
            command, fileName = input:match("^(%S+)%s*(%S*)$")
        
        if command == "stop" then
            _G.stopMusic = true
            drive.ejectDrive()
        elseif command = "exit" then
            _G.stopMusic = true
            break
        elseif command == "play" and fileName ~= "" then
            _G.stopMusic = true
            while _G.musicPlaying do
                sleep(0.1)
            end
            _G.stopMusic = false
            _G.musicPlaying = true
            local filePath = folder .. fileName .. ".dfpwm"
            parallel.waitForAny(
                function() playDFPWMMusic(filePath) end,
                handleUserInput
            )
        else
            print("Invalid command. Use 'play <file>' or 'stop'.")
        end
    end
end

-- Start user input handling in a coroutine
parallel.waitForAny(handleUserInput)
