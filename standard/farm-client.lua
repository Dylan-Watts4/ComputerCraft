-- Side of the client to run on
side = "right"

-- Open modem
rednet.open(side)

-- Function to close the client
function closeClient()
    rednet.close(side)
    -- TODO: change variable for main loop
end

-- Function to send response to server