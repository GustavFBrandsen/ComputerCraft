-- Load the DFPWM decoder library
local dfpwm = require("cc.audio.dfpwm")

-- Find all connected speakers
local speakers = table.pack(peripheral.find("speaker"))
if #speakers == 0 then
    print("No speakers connected.")
    return
end

-- Create a decoder
local decoder = dfpwm.make_decoder()

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

-- Open the DFPWM file
local filePath = "/music/kbh.dfpwm"
local file = fs.open(filePath, "rb")
if not file then
    print("File not found: " .. filePath)
    return
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
end

-- Close the file
file.close()

print("Music playback finished.")
