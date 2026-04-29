function sendReplyV1(server, u_cmd_pwm)
    writeline(server, sprintf('u=%d', u_cmd_pwm));
end