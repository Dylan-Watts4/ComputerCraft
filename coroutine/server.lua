-- https://raw.githubusercontent.com/Dylan-Watts4/ComputerCraft/main/coroutine/server.lua

-- Open connection
side = "left"
rednet.open(side)

-- Function to close the server
function closeServer()
    rednet.close(side)
    running = false
end

function sendRequest(message)
    rednet.broadcast(message, "request")
    interpretMessage(10)
end

function getStatus()
    sendRequest("status")
end

function getInventory()
    sendRequest("inventory")
end

function interpretMessage(maxCount)
    local count = 0
    while true do
        local id, message, protocol = rednet.receive("response", 1)
        if message == nil then break end
        print(id..":"..message)
        if count >= maxCount then break end
    end
end

-- Main loop
running = true
while running == true do
    
    local choiceTable = {
        ["1"] = getStatus,
        ["2"] = getInventory,
        ["0"] = closeSever,
    }

    print("1. Get status\n2. Get inventory\n0. Close")
    local choice = read(">> ")

    if choiceTable[choice] then
        choiceTable[choice]()
    else
        print("Invalid choice")
    end

    term.clear()
end