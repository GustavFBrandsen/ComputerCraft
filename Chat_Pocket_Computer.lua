 
local modemSide = "back"
local userName = "New User"

rednet.open (modemSide)

term.setCursorPos(1,1)
term.setTextColor(colors.white)

local function wrapText(text, width) 
    local wrapped = {}
    local line = ""
    for word in text:gmatch("%S+") do 
        local testLine = line .. " " .. word
        if #testLine > width then
            table.insert(wrapped, line)
            line = word
        else
        line = testLine
        end
    end
    table.insert(wrapped, line)
    return wrapped
end
   
local function printToAll(msg)
    local termWidth, termHeight = term.getSize()
    local wrappedLines = wrapText(msg, monitorWidth)
    for _, line in ipairs(wrappedLines) do
        local termx, termy = term.getCursorPos()
        term.setCursorPos(0, termy)
        term.write(line)
        if y < termHeight then
            term.setCursorPos(1, y + 1)
        else
            term.scroll(1)
            term.setCursorPos(1, termHeight)
        end
    end
end

print("Type your message and press Enter to send.")
print("Type 'exit' to quit.")
print("Type 'clear' to clear the screen.")

    
local function recieveMessages()
    while true do
        local senderId, senderName, msg = rednet.receive()
        PrintToAll(senderName .. ": " .. msg)
    end
end

parallel.waitForAny(
    recieveMessages,
    function()
        while true do
            local userMessage = read()
            if userMessage == "exit" then
                break
            elseif userMessage == "clear" then
                term.clear()
                term.setCursorPos(1,1)
            else
                rednet.broadcast(userName, userMessage)
                local x, y = term.getCursorPos()
                term.setCursorPos(1, y - 1)
                printToAll("You: " .. userMessage)
            end
        end
    end
)

rednet.close(modemSide)
print("Program closed")