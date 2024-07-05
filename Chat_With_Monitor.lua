
local modemSide = "back"
local monitorSide = "left"

rednet.open (modemSide)

local monitor = peripheral.wrap(monitorSide)

monitor.clear()
monitor.setCursorPos(1,1)
monitor.setTextScale(1)
monitor.setTextColor(colors.white)
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
    local monitorWidth, monitorHeight = monitor.getSize()
    local termWidth, termHeight = term.getSize()
    local wrappedLines = wrapText(msg, monitorWidth)
    for _, line in ipairs(wrappedLines) do
        local x, y = monitor.getCursorPos()
        local termx, termy = term.getCursorPos()
        term.setCursorPos(0, termy)
        term.write(line)
        monitor.write(line)
        if y < monitorHeight then
            monitor.setCursorPos(1, y + 1)
        else
            monitor.scroll(1)
            monitor.setCursorPos(1, monitorHeight)
        end
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
                monitor.clear()
                monitor.setCursorPos(1, 1)
                term.clear()
                term.setCursorPos(1,1)
            else
                rednet.broadcast("Gustav", userMessage)
                local x, y = term.getCursorPos()
                term.setCursorPos(0, y - 1)
                printToAll("You: " .. userMessage)
            end
        end
    end
)

rednet.close(modemSide)
print("Program closed")