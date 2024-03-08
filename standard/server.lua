-- Side of the computer to run on
side = "left"

-- Open modem
rednet.open(side)

-- Function to close the server
function closeServer()
    rednet.close(side)
    -- TODO: change variable for main loop
end

-- Function to send command to client
function sendCommand(message, protocol)
    rednet.broadcast(message, protocol)
end

-- Perform requested action
function requestAction(action)
    sendCommand(action, "request")
    -- Wait for response
    ids = {}
    messages = {}
    for i = 0, 255 do
        local id, message, protocol = rednet.receive("response", 2)
        if message == nil then
            break
        else
            ids[i] = id
            messages[i] = message
        end
    end
    -- Print response
    for i = 0, 255 do
        if ids[i] == nil then
            break
        else
            print("Client " .. ids[i] .. " responded with: " .. messages[i])
        end
    end
end

-- Request status from client
function requestStatus()
    requestAction("status")
end

-- Request inventory status from client
function requestInventory()
    requestAction("inventory")
end

-- Request kill from client
function requestKill()
    requestAction("kill")
end