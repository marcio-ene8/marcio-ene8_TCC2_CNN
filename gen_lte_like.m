function x = gen_lte_like()
% GEN_LTE_LIKE  Gera um sinal sintético "tipo LTE (4G)".
%
%   x = gen_lte_like();
%
% O sinal usa estrutura OFDM típica:
%   - FFT de 512 pontos (banda moderada)
%   - CP de 128 amostras
%   - 80 símbolos OFDM no tempo
%   - Modulação 16-QAM
%
% As subportadoras ativas ocupam ~50% da banda total.

    Nfft = 512;
    Ncp = 128;
    numSymbols = 80;
    M = 16;
    half = round(0.25*Nfft);
    activeBins = -half:half;

    % chama o gerador genérico
    x = gen_ofdm_like(Nfft, Ncp, numSymbols, M, activeBins);
end
