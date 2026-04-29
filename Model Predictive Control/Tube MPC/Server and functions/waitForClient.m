function waitForClient(server)
    while ~server.Connected
        pause(0.1);
    end
end