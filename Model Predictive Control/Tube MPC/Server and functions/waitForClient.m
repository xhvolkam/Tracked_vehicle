function waitForClient(server)
    % Block setup until the ESP32 client has opened the TCP connection.
    while ~server.Connected
        pause(0.1);
    end
end
