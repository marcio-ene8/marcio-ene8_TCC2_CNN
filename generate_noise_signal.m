function y = generate_noise_signal(N, fs, mode)
% Noise realista, mas não excessivamente parecido com LTE/NR/WLAN.

    if nargin < 1 || isempty(N)
        N = 32768;
    end
    if nargin < 2 || isempty(fs)
        fs = 20e6;
    end
    if nargin < 3 || isempty(mode)
        mode = 'train';
    end

    kind = randi(4);

    switch kind
        case 1
            y = (randn(N,1) + 1j*randn(N,1))/sqrt(2);

        case 2
            w = (randn(N,1) + 1j*randn(N,1))/sqrt(2);
            a = 0.75 + 0.15*rand();
            y = filter(1, [1 -a], w);

        case 3
            w = (randn(N,1) + 1j*randn(N,1))/sqrt(2);
            W = fftshift(fft(w));
            f = linspace(-1,1,N).';
            bw = 0.25 + 0.25*rand();
            fc = (2*rand()-1)*0.15;
            mask = abs(f - fc) < bw;
            W(~mask) = 0;
            y = ifft(ifftshift(W));

        case 4
            y = (randn(N,1) + 1j*randn(N,1))/sqrt(2);
            n = (0:N-1).';
            toneFreq = (2*rand()-1)*1e6;
            tone = exp(1j*2*pi*toneFreq*n/fs);
            y = y + 0.18*tone;
    end

    y = y(:);
    y = y / max(sqrt(mean(abs(y).^2)), eps);

    y = impair_chan_basic(y, fs, 'mode', mode, 'noiseOnly', true);
end