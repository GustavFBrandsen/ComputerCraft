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

    -- Read and decode the file in chunks
    while true do
        local chunk = file.read(16384)
        if not chunk then break end

        -- Decode the chunk
        local decoded = decoder(chunk)

        -- Add the decoded audio to the buffer
        table.insert(buffer, decoded)

        -- Yield to avoid "too long without yielding" error
        os.queueEvent("yield")
        os.pullEvent("yield")
    end

    -- Close the file
    file.close()

    -- Play the decoded audio buffer
    for _, audioChunk in ipairs(buffer) do
        for _, speaker in ipairs(speakers) do
            speaker.playAudio(audioChunk)
        end
        -- Add a short sleep to allow for smooth playback
        sleep(0.05)
    end

    print("Music playback finished.")
end

-- Example usage
playDFPWMMusic("/music/kbh.dfpwm")
