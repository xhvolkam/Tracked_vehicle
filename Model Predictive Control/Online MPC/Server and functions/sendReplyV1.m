function sendReplyV1(server, u_cmd_pwm)
    % ESP32 command parser expects a newline-terminated absolute PWM command.
    writeline(server, sprintf('u=%d', u_cmd_pwm));
end
