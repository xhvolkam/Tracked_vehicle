function u_cmd = computeTestControlV1(data)

    PWM_ZERO = 1150;
    PWM_MIN  = 1090;
    PWM_MAX  = 1700;

    d = data.DIST_FILT;

    % jednoduchá testovacia logika
    if d > 120
        u_cmd = PWM_ZERO + 60;
    elseif d > 80
        u_cmd = PWM_ZERO + 30;
    else
        u_cmd = PWM_ZERO;
    end

    u_cmd = min(max(round(u_cmd), PWM_MIN), PWM_MAX);
end