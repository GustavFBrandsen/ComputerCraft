-- Load the DFPWM decoder library
local dfpwm = require("cc.audio.dfpwm")

-- Function to play DFPWM music on all connected speakers
function playDFPWMMusic(filePath)
    -- Open the DFPWM file
    local file = fs.open(filePath, "rb")
    if not file then
        print("File not found: " .. filePath)
        return
    end

    -- Find all connected speakers
    local speakers = {peripheral.find("speaker")}
    if #speakers == 0 then
        print("No speakers connected.")
        file.close()
        return
    end

    -- Create a decoder
    local decoder = dfpwm.make_decoder()

    -- Buffer to store decoded audio
    local buffer = {}
    local chunkSize = 16384
    local maxBufferLength = 100  -- Adjust based on available memory and performance

    -- Read and decode the file in chunks
    while true do
        local chunk = file.read(chunkSize)
        if not chunk then break end

        -- Decode the chunk
        local decoded = decoder(chunk)
        table.insert(buffer, decoded)

        -- Yield to avoid "too long without yielding" error
        os.queueEvent("yield")
        os.pullEvent("yield")

        -- Limit buffer length
        if #buffer >= maxBufferLength then
            break
        end
    end

    -- Close the file
    file.close()

    -- Play the decoded audio buffer
    local playSpeed = 0.05  -- Adjust based on audio chunk size and required playback speed
    for _, audioChunk in ipairs(buffer) do
        for _, speaker in ipairs(speakers) do
            speaker.playAudio(audioChunk)
        end
        -- Sleep to maintain proper playback timing
        sleep(playSpeed)
    end

    -- Continue reading and playing the rest of the file
    while true do
        local chunk = file.read(chunkSize)
        if not chunk then break end

        -- Decode the chunk
        local decoded = decoder(chunk)

        -- Play the decoded audio
        for _, speaker in ipairs(speakers) do
            speaker.playAudio(decoded)
        end
        -- Sleep to maintain proper playback timing
        sleep(playSpeed)

        -- Yield to avoid "too long without yielding" error
        os.queueEvent("yield")
        os.pullEvent("yield")
    end

    print("Music playback finished.")
end

-- Example usage
playDFPWMMusic("/music/kbh.dfpwm")
