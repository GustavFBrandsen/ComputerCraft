-- Load the DFPWM decoder library
local dfpwm = require("cc.audio.dfpwm")

-- Find all connected speakers
local speakers = peripheral.find("speaker") and {peripheral.find("speaker")} or {}

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
        parallel.waitForAll(table.unpack(funcs))
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
            for i = 1, #speakers do
                speakers[i].stop()
            end
            break
        end
    end

    -- Close the file
    file.close()
    _G.musicPlaying = false
end

-- Function to find the side of the disk drive
local function findDiskDriveSide()
    local sides = {"left", "right", "top", "bottom", "front", "back"}
    for _, side in ipairs(sides) do
        if peripheral.getType(side) == "drive" then
            return side
        end
    end
    return nil
end

-- Function to check if a disk is inserted on a specified side
local function checkDiskPresence(side)
    while true do
        if findDiskDriveSide() then
            _G.diskPresent = disk.isPresent(side)
            sleep(3)  -- Check every 3 seconds
        else
            break
        end
    end
end

-- Function to handle user input
local function handleUserInput()
    while true do
        local diskSide = findDiskDriveSide()
        local drive = peripheral.wrap(diskSide)
        local diskPresent = (drive and disk.isPresent(diskSide))

        local command, fileName = "", ""
        if diskPresent and _G.musicPlaying == false then
            local songName = drive.getDiskLabel()
            local folder = "/disk/"
            local filePath = folder .. songName .. ".dfpwm"
            _G.stopMusic = true
            while _G.musicPlaying do
                sleep(0.1)
            end
            _G.stopMusic = false
            _G.musicPlaying = true
            parallel.waitForAny(
                function() playDFPWMMusic(filePath) end,
                handleUserInput
            )
        else
            print("Enter command (stop / exit):")
            local input = read()
            command = input:match("^(%S+)")
        end

        if command == "stop" then
            _G.stopMusic = true
            if diskPresent then
                local drive = peripheral.wrap(diskSide)
                drive.eject()
            end
        elseif command == "exit" then
            _G.stopMusic = true
            break
        else
            print("Invalid command. Use 'stop' or 'exit'.")
        end
    end
end

-- Start disk presence checking in parallel
local diskSide = findDiskDriveSide()
if diskSide then
    parallel.waitForAny(
        function() checkDiskPresence(diskSide) end,
        handleUserInput
    )
else
    print("No disk drive found.")
end