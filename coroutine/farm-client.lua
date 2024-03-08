-- Open connection
side = "right"
rednet.open(side)

-- Function to close the client
function closeClient()
    rednet.close(side)
    -- TODO: change variable for main loop
    running = false
    return "Client closed"
end

-- Function to get status
function getStatus()
    if turtle.getFuelLevel() < 100 then
        rednet.broadcast("need fuel", "request")
    end
end

-- Function to get inventory
function getInventory()
    if turtle.getItemCount(16) > 0 then
        rednet.broadcast("inventory full", "request")
    end
end

function hasSeeds()
    for i = 1, 16 do
        if turtle.getItemCount(i) > 0 then
            local item = turtle.getItemDetail(i)
            if item.name == "minecraft:wheat_seeds" then
                broadcast("has seeds", "request")
                return true
            end
        end
    end
    broadcast("no seeds", "request")
end

-- Function to interpret rednet message
function interpretMessage()
    while true do
        local sendMessage = nil
        local id, message, protocol = rednet.receive("request", 1)
        if message == "status" then
            sendMessage = getStatus()
        elseif message == "inventory" then
            sendMessage =  getInventory()
        elseif message == "kill" then
            sendMessage = closeClient()
        end
        if sendMessage ~= nil then
            rednet.broadcast(sendMessage, "response")
        end
    end
end

-- Function to implement pain in the arse movement logic
function move()
    turtle.turnLeft()
end

-- Function to perform turtle action
function turtleAction()
    while true do
        getStatus()
        getInventory()
    end
end

-- Coroutine definitions
local rednetCoroutine = coroutine.create(interpretMessage)
rednetCoroutine.resume(rednetCoroutine)

local turtleCoroutine = coroutine.create(turtleAction)
turtleCoroutine.resume(turtleCoroutine)

-- Main loop
running = true
while running == true do
    
    local event = {os.pullEvent()}

    if event[1] == "rednet_message" then
        coroutine.resume(rednetCoroutine)
    else 
        coroutine.resume(turtleCoroutine)
    end

    os.sleep(1)
end