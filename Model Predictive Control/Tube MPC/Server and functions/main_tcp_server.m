clc;
clear;
close all;
yalmip('clear');

%% Settings
port = 8080;
PWM_ZERO = 1150;

fprintf('\n MATLAB TCP SERVER START (ONLINE TUBE MPC) \n');
fprintf('Listening on port %d...\n', port);

% CSV file
timestamp_str = datestr(now, 'yyyymmdd_HHMMSS');
csv_filename = sprintf('esp32_tube_mpc_log_%s.csv', timestamp_str);

fid = fopen(csv_filename, 'w');
fprintf(fid, 'PC_TIME,K,TIME,TEXP,PWM_RX,DIST_RAW,DIST_FILT,V_RAW,V_FILT,U_SHIFT,U_CMD_PWM,LOOP_TIME_MS\n');
fclose(fid);

fprintf('Logging to CSV: %s\n', csv_filename);

%% Build Tube MPC before connection
fprintf('Building Tube MPC controller...\n');
iMPC = buildTubeMPC_simple();
fprintf('Tube MPC controller built.\n');

% Dummy warm-up
fprintf('Warm-up evaluate...\n');
z_dummy = [200 - 50; 0];
u_prev_dummy = 0;

try
    [u_dummy, feasible_dummy] = iMPC.evaluate(z_dummy, 'u.previous', u_prev_dummy); %#ok<NASGU,ASGLU>
    fprintf('Warm-up done.\n');
catch ME
    fprintf('[WARN] Warm-up failed: %s\n', ME.message);
end

% States
mpcState = [];
u_prev = 0;

%% Server
server = tcpserver("10.85.168.12", port);
configureTerminator(server, "LF");

fprintf('Waiting for ESP32 connection...\n');
waitForClient(server);
fprintf('[CONNECT] ESP32 connected.\n\n');

% Logging
logStruct = struct([]);
idx = 0;
lastK = [];

%% Loop
while true
    if server.NumBytesAvailable > 0
        tLoop = tic;
        line = readline(server);
        line = strtrim(line);

        if ~isempty(line)
            pc_now = now;
            timeStr = datestr(pc_now, 'HH:MM:SS.FFF');
            fprintf('[%s] RX -> %s\n', timeStr, line);

            data = parseEspPacketV1(line);

            if data.valid
                if isempty(lastK)
                    lastK = data.K;
                else
                    if data.K ~= lastK + 1
                        fprintf('[WARN] Packet jump detected: %d -> %d\n', lastK, data.K);
                    end
                    lastK = data.K;
                end

                d = data.DIST_FILT;

                [u_shift, u_cmd_pwm, v_raw, v_f, mpcState] = ...
                    computeMPC2_tube_simple(iMPC, d, u_prev, PWM_ZERO, mpcState);

                u_prev = data.PWM - PWM_ZERO;

                sendReplyV1(server, u_cmd_pwm);

                loop_time_ms = toc(tLoop) * 1000;

                fprintf('[INFO] d = %.2f cm, v_raw = %.2f cm/s, v_f = %.2f cm/s\n', d, v_raw, v_f);
                fprintf('[INFO] u_shift = %.2f, PWM_cmd = %d\n', u_shift, u_cmd_pwm);
                fprintf('[INFO] loop time = %.2f ms\n\n', loop_time_ms);

                idx = idx + 1;
                logStruct(idx).PC_TIME = pc_now; %#ok<SAGROW>
                logStruct(idx).K = data.K;
                logStruct(idx).TIME = data.TIME;
                logStruct(idx).TEXP = data.TEXP;
                logStruct(idx).PWM_RX = data.PWM;
                logStruct(idx).DIST_RAW = data.DIST_RAW;
                logStruct(idx).DIST_FILT = data.DIST_FILT;
                logStruct(idx).V_RAW = v_raw;
                logStruct(idx).V_FILT = v_f;
                logStruct(idx).U_SHIFT = u_shift;
                logStruct(idx).U_CMD_PWM = u_cmd_pwm;
                logStruct(idx).LOOP_TIME_MS = loop_time_ms;

                fid = fopen(csv_filename, 'a');
                fprintf(fid, '%s,%d,%.0f,%.0f,%d,%.2f,%.2f,%.2f,%.2f,%.2f,%d,%.3f\n', ...
                    datestr(pc_now, 'yyyy-mm-dd HH:MM:SS.FFF'), ...
                    data.K, ...
                    data.TIME, ...
                    data.TEXP, ...
                    data.PWM, ...
                    data.DIST_RAW, ...
                    data.DIST_FILT, ...
                    v_raw, ...
                    v_f, ...
                    u_shift, ...
                    u_cmd_pwm, ...
                    loop_time_ms);
                fclose(fid);

            else
                fprintf('[WARN] Invalid packet.\n\n');
            end
        end
    end

    pause(0.001);
end