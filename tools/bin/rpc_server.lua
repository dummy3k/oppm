print("RPC Server v0.1")

while true do
    local _, _, from, port, _, message = event.pull("modem_message")
    print("Got a message from " .. from .. " on port " .. port .. ": " .. tostring(message))
    local f = load(message)
    -- f()
    local status, err = pcall(f)
    print("status", status)
    print("err", err)
    if not status then
        local traceback = debug.traceback()
        -- print(debug.traceback())
        
        local msg = {status=status, err=err, traceback=traceback}
        component.modem.send(from, port, serialization.serialize(msg))
    else
        local msg = {status=status, result=err}
        component.modem.send(from, port, serialization.serialize(msg))
    end

end