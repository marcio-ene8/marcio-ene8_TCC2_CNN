function im = spectrogram_image(y, fs)
% spectrogram_image
% Converte sinal IQ em espectrograma 64x64.
% Versão ajustada:
% - STFT com melhor resolução em frequência
% - normalização por percentis
% - evita recorte fixo de 45 dB

    y = y(:);

    if isempty(y)
        im = uint8(zeros(64,64));
        return;
    end

    % Normalização RMS para reduzir variação de ganho entre amostras
    y = y / max(sqrt(mean(abs(y).^2)), eps);

    % STFT mais informativa
    nfft = 512;
    win  = hamming(256);
    ovlp = 220;

    [S,~,~] = spectrogram(y, win, ovlp, nfft, fs, 'centered');

    SdB = 20*log10(abs(S) + 1e-12);

    % Normalização robusta por percentis
    hi = prctile(SdB(:), 99);
    lo = prctile(SdB(:), 5);

    if hi <= lo
        hi = max(SdB(:));
        lo = min(SdB(:));
    end

    SdB = min(max(SdB, lo), hi);
    SdB = (SdB - lo) / max(hi - lo, eps);

    % Redimensiona para entrada da CNN
    SdB = imresize(SdB, [64 64]);

    im = uint8(255 * SdB);
end