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
        elseif message == "inventory" 
            sendMessage =  getInventory()
        elseif message == "kill" 
            sendMessage = closeClient()
        end
        if sendMessage ~= nil then
            rednet.broadcast(sendMessage, "response")
        end
    end
end

-- Consider the farming area as a recntangle
local farm = {
    ["width"] = 17,
    ["length"] = 18,
}

local relPos = {
    ["x"] = 0,
    ["y"] = 0,
    ["dx"] = 0,
    ["dy"] = 0,
    ["mirror"] = 0,
}

-- Local orientation, 1 = forward, 0 = backward
local orientation = 1

-- Funtion to calculate next position
function nextPos()
    return {["x"] = relPos.x + relPos.dx, ["y"] = relPos.y + relPos.dy}
end

-- Function to update the relative position
function updateRelPos()
    relPos.x = relPos.x + relPos.dx
    relPos.y = relPos.y + relPos.dy
end

-- Function to rotate the turtle
function rotate()
    -- If the turtle is at the top of the farm
    if orientation == 1 then
        turtle.turnLeft()
        turtle.forward()
        turtle.turnLeft()
    -- If the turtle is at the bottom of the farm
    else
        turtle.turnRight()
        turtle.forward()
        turtle.turnRight()
    end
end

-- Function to check wheather the turtle is out of bounds
function outOfBounds()
    local nextPos = nextPos()
    if nextPos.x > farm.width then
        turtle.turnRight()
        turtle.turnRight()
        relPos.dy = 1
        relPos.x = 1
        relPos.y = 0
    end
end

-- Function to move the turtle
function move()
    for x = 1, farm.width do
        for y = 1, farm.length do
            local nextPos = nextPos()
            outOfBounds()
            if nextPos.y >= farm.length then
                orientation = 0
                rotate()
                relPos.dy = -1
                updateRelPos()
            elseif nextPos.y <= 1
                orientation = 1
                rotate()
                relPos.dy = 1
                updateRelPos()
            end
        end
    end
end

-- Function to farm
function farm()
    local success, data = turtle.inspectDown()
    if success then
        if data.name == "minecraft:wheat" 
            turtle.digDown()
            turtle.placeDown()
        elseif data.name == "minecraft:farmland" 
            turtle.placeDown()
        elseif data.name == "minecraft:mud" or data.name == "minecraft:grass" 
            turtle.digDown()
            turtle.placeDown()
        end
    end
end

-- Function to perform turtle action
function turtleAction()
    while true do
        move()
        farm()
    end
end

-- Coroutine definitions
local rednetCoroutine = coroutine.create(interpretMessage)
coroutine.resume(rednetCoroutine)

local turtleCoroutine = coroutine.create(turtleAction)
coroutine.resume(turtleCoroutine)

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