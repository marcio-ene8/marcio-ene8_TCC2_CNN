function y = impair_chan_basic(x, fs, varargin)
% Canal realista moderado: sem buracos abruptos e sem destruir o sinal.

    p = inputParser;
    addParameter(p, 'mode', 'train', @ischar);
    addParameter(p, 'noiseOnly', false);
    parse(p, varargin{:});

    mode = lower(p.Results.mode);
    noiseOnly = logical(p.Results.noiseOnly);

    y = x(:);
    N = length(y);

    if N == 0
        return;
    end

    % Normalização inicial RMS
    y = y / max(sqrt(mean(abs(y).^2)), eps);

    switch mode
        case 'train'
            snr_db = 10 + 18*rand();     % 10 a 28 dB
            cfoHz  = (2*rand()-1)*3e3;   % +/- 3 kHz
            fadeProb = 0.08;

        case 'test'
            snr_db = 6 + 16*rand();      % 6 a 22 dB
            cfoHz  = (2*rand()-1)*6e3;   % +/- 6 kHz
            fadeProb = 0.12;

        otherwise
            snr_db = 15 + 10*rand();
            cfoHz  = (2*rand()-1)*1e3;
            fadeProb = 0.03;
    end

    if noiseOnly
        snr_db = snr_db - 3;
    end

    % CFO moderado
    n = (0:N-1).';
    y = y .* exp(1j*2*pi*cfoHz*n/fs);

    % Multipercurso leve
    h = [1; 0.25*exp(1j*2*pi*rand); 0.12*exp(1j*2*pi*rand)];
    y = conv(y, h, 'same');

    % Fading suave, sem zerar sinal
    if rand < fadeProb
        dur = randi([round(0.01*N), round(0.03*N)]);
        ini = randi([1, N-dur+1]);

        fade = linspace(1, 0.65, dur).';
        y(ini:ini+dur-1) = y(ini:ini+dur-1).*fade;
    end

    % AWGN
    sigP = mean(abs(y).^2);
    noiseP = sigP / (10^(snr_db/10));
    w = sqrt(noiseP/2)*(randn(N,1) + 1j*randn(N,1));

    y = y + w;

    % Normalização final RMS
    y = y / max(sqrt(mean(abs(y).^2)), eps);
end