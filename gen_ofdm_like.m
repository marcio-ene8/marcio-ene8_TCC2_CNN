function x = gen_ofdm_like(Nfft, Ncp, numSymbols, M, activeBins)
% GEN_OFDM_LIKE  Gera um sinal OFDM genérico sem precisar de toolboxes.
%
%   x = gen_ofdm_like(Nfft, Ncp, numSymbols, M, activeBins)
%
% Função independente do Communications Toolbox.
%
% Etapas:
%   1) Gera símbolos QAM manualmente (sem qammod)
%   2) Mapeia subportadoras ativas
%   3) Aplica IFFT e prefixo cíclico
%   4) Normaliza energia RMS

    % ---------------- Parâmetros padrão ----------------
    if nargin < 1, Nfft = 512; end
    if nargin < 2, Ncp = 128; end
    if nargin < 3, numSymbols = 64; end
    if nargin < 4, M = 16; end
    if nargin < 5
        half = Nfft/4;
        activeBins = -half:half;
    end

    % ---------------- Mapeamento de índices ----------------
    k = (-Nfft/2:Nfft/2-1);
    [~, loc] = ismember(activeBins, k);
    loc(loc==0) = [];

    numActive = numel(loc);

    % ---------------- Geração de símbolos QAM ----------------
    % Implementação manual compatível com qualquer M (4, 16, 64…)
    %
    % QAM = (2*a + 1 - √M) + j*(2*b + 1 - √M)
    % onde a,b ∈ [0,√M-1]
    % e normalizado para potência unitária.
    %
    dataIdx = randi([0 M-1], numActive*numSymbols, 1);

    mSide = sqrt(M);                      % número de níveis por eixo
    if mod(mSide,1) ~= 0
        error('Ordem de modulação M deve ser quadrada (ex.: 4, 16, 64).');
    end

    % coordenadas em grade QAM
    a = mod(dataIdx, mSide);
    b = floor(dataIdx / mSide);

    % mapeamento Gray-like centrado na origem
    I = 2*a - (mSide - 1);
    Q = 2*b - (mSide - 1);
    const = I + 1j*Q;

    % normalização para potência unitária média
    const = const / rms(const);

    % reestrutura para (subportadora x símbolo)
    const = reshape(const, numActive, numSymbols);

    % ---------------- Monta grade de subportadoras ----------------
    Xk = zeros(Nfft, numSymbols);
    Xk(loc,:) = const;

    % ---------------- Gera símbolos OFDM (IFFT + CP) ----------------
    x = [];
    for n = 1:numSymbols
        x_freq = Xk(:,n);
        x_time = ifft(ifftshift(x_freq));  % domínio do tempo
        x_cp = [x_time(end-Ncp+1:end); x_time];  % adiciona CP
        x = [x; x_cp];
    end

    % ---------------- Normalização final ----------------
    x = x / rms(x);
end
