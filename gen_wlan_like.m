function x = gen_wlan_like()
% GEN_WLAN_LIKE  Gera um sinal sintético "tipo WLAN (Wi-Fi)".
%
%   x = gen_wlan_like();
%
% Características:
%   - FFT de 256 pontos (banda estreita)
%   - CP de 64 amostras
%   - 40 símbolos por pacote
%   - Modulação QPSK (M=4)
%
% Simula pacotes curtos (frames) com intervalo de silêncio entre eles.

    Nfft = 256;
    Ncp = 64;
    numSymbols = 40;
    M = 4;
    half = round(0.25*Nfft);
    activeBins = -half:half;

    % Gera um "burst" OFDM
    x_burst = gen_ofdm_like(Nfft, Ncp, numSymbols, M, activeBins);

    % Cria um segundo burst separado por um intervalo de silêncio
    gapLen = 2000;           % duração do silêncio (amostras)
    gap = zeros(gapLen,1);

    % Concatena [burst - silêncio - burst]
    x = [x_burst; gap; x_burst];

    % Normaliza energia
    x = x / rms(x);
end
