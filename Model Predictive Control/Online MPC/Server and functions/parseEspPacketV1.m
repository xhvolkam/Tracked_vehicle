function data = parseEspPacketV1(line)

    data = struct( ...
        'valid', false, ...
        'K', NaN, ...
        'TIME', NaN, ...
        'TEXP', NaN, ...
        'PWM', NaN, ...
        'DIST_RAW', NaN, ...
        'DIST_FILT', NaN);

    try
        parts = split(line, ',');

        for i = 1:numel(parts)
            token = strtrim(parts{i});
            kv = split(token, '=');

            if numel(kv) ~= 2
                continue;
            end

            key = strtrim(kv{1});
            val = strtrim(kv{2});

            switch key
                case 'K'
                    data.K = str2double(val);

                case 'TIME'
                    data.TIME = str2double(val);

                case 'TEXP'
                    data.TEXP = str2double(val);

                case 'PWM'
                    data.PWM = str2double(val);

                case 'DIST_RAW'
                    data.DIST_RAW = str2double(val);

                case 'DIST_FILT'
                    data.DIST_FILT = str2double(val);
            end
        end

        required = [data.K, data.TIME, data.TEXP, data.PWM, data.DIST_RAW, data.DIST_FILT];
        data.valid = all(~isnan(required));

    catch
        data.valid = false;
    end
end