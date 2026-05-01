function x = gen_nr_like()
% GEN_NR_LIKE  Gera um sinal sintético "tipo NR (5G)".
%
%   x = gen_nr_like();
%
% O sinal é mais "largo" que o LTE:
%   - FFT de 1024 pontos (banda larga)
%   - CP de 256 amostras
%   - 80 símbolos OFDM
%   - Modulação 16-QAM
%
% As subportadoras ocupam ~60% da banda útil.

    Nfft = 1024;
    Ncp = 256;
    numSymbols = 80;
    M = 16;
    half = round(0.3*Nfft);
    activeBins = -half:half;

    x = gen_ofdm_like(Nfft, Ncp, numSymbols, M, activeBins);
end
