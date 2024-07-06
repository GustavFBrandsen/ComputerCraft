-- Function to copy a file from source to destination
local function copyFile(fileName)
    -- Construct the full paths
    local srcPath = "/" .. fileName .. ".dfpwm"
    local destPath = "/disk/" .. fileName .. ".dfpwm"

    -- Open the source file for reading
    local srcFile = fs.open(srcPath, "rb")
    if not srcFile then
        print("Source file not found: " .. srcPath)
        return false
    end

    -- Open the destination file for writing
    local destFile = fs.open(destPath, "wb")
    if not destFile then
        print("Could not open destination file: " .. destPath)
        srcFile.close()
        return false
    end

    -- Read and write the file content
    local buffer
    while true do
        buffer = srcFile.read(16 * 1024) -- Read in chunks
        if not buffer then break end
        destFile.write(buffer)
    end

    -- Close both files
    srcFile.close()
    destFile.close()

    print("File copied from " .. srcPath .. " to " .. destPath)
    return true
end

-- Function to handle user input for the file name
local function handleUserInput()
    print("Enter the name of the file to copy (without .dfpwm extension):")
    local fileName = read()
    copyFile(fileName)
end

-- Run the user input function
handleUserInput()
