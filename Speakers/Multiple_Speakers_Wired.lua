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

    -- Read and decode the file in chunks
    while true do
        local chunk = file.read(16384)
        if not chunk then break end

        -- Decode the chunk
        local decoded = decoder(chunk)

        -- Play the decoded sound on all speakers
        for _, speaker in ipairs(speakers) do
            speaker.playAudio(decoded)
        end
    end

    -- Close the file
    file.close()
    
    print("Music playback finished.")
end

-- Example usage
playDFPWMMusic("/music/kbh.dfpwm")
