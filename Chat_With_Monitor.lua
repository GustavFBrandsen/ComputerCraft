if username == nil or modemSide == nil or monitorSide == nil or userColor == nil then
    print("This is a one time setup.")
    print("Enter your username.")
    local username = read()
    print("Where is your wireless modem located? (front, back, left, right, top)")
    local modemSide = read()
    print("Where is your monitor located? (front, back, left, right, top)")
    local monitorSide = read()
    print("What color would you like to have? (blue, white, yellow)")
    local userColor = read()
    while loadstring("return " .. "colors." .. userColor)() == nil do
        print("Color doesn't exist")
        userColor = read()
    end
    
    local programName = shell.getRunningProgram()
    local file = fs.open(programName, "r")
    local lines = {}
    local lineCount = 0
    local line = file.readLine()

    while line do
        lineCount = lineCount + 1
        if lineCount > 45 then
            table.insert(lines, line)
        end
        line = file.readLine()
    end
    file.close()

    file = fs.open(programName, "w")
    
    file.write("local username = '" .. username .. "'\n")
    file.write("local modemSide = '" .. modemSide .. "'\n")
    file.write("local monitorSide = '" .. monitorSide .. "'\n")
    file.write("local userColor = '" .. userColor .. "'\n\n")

    for i = 2, #lines do
        file.writeLine(lines[i])
    end
    file.close()
    monitor.clear()
    term.clear()
    dofile(shell.getRunningProgram())
end

rednet.open(modemSide)

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
   
local function printToAll(user, color, msg)
    color = loadstring("return " .. "colors." .. color)()
    local monitorWidth, monitorHeight = monitor.getSize()
    local termWidth, termHeight = term.getSize()
    local wrappedLines = wrapText(msg, monitorWidth)
    local wrappedTermLines = wrapText(msg, termWidth)
    for _, line in ipairs(wrappedLines) do
        local x, y = monitor.getCursorPos()
        monitor.setTextColor(color)
        monitor.write(user .. ": ")
        monitor.setTextColor(colors.white)
        monitor.write(line)
        if y < monitorHeight then
            monitor.setCursorPos(1, y + 1)
        else
            monitor.scroll(1)
            monitor.setCursorPos(1, monitorHeight)
        end
    end
    for _, line in ipairs(wrappedTermLines) do
        local termx, termy = term.getCursorPos()
        term.setTextColor(color)
        term.write(user .. ": ")
        term.setTextColor(colors.white)
        term.write(line)
        if termy < termHeight then
            term.setCursorPos(1, termy + 1)
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
        senderId, senderName, senderColor, msg = rednet.receive()
        printToAll(senderName, senderColor, msg)
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
                rednet.broadcast(username, userColor, userMessage)
                local x, y = term.getCursorPos()
                term.setCursorPos(1, y - 1)
                printToAll("You", userColor, userMessage)
            end
        end
    end
)

rednet.close(modemSide)
print("Program closed")
