function y = generate_unknown_signal(fs, mode)
% generate_unknown_signal
% Gera a classe Unknown de forma estruturada e mais realista.
%
% Unknown = sinais estranhos / interferidos / misturados,
% evitando que a classe vire apenas "quase ruído".
%
% Uso:
%   y = generate_unknown_signal(20e6, 'train')
%   y = generate_unknown_signal(20e6, 'test')

    if nargin < 1 || isempty(fs)
        fs = 20e6;
    end
    if nargin < 2 || isempty(mode)
        mode = 'train';
    end

    m = randi(5);

    switch m
        case 1
            % NR + WLAN
            a = gen_nr_like();
            b = gen_wlan_like();
            N = min(length(a), length(b));
            y = a(1:N) + 0.6*b(1:N);

        case 2
            % LTE + WLAN com SIR moderado
            a = gen_lte_like();
            b = gen_wlan_like();
            N = min(length(a), length(b));
            y = a(1:N) + 0.5*b(1:N);

        case 3
            % NR deslocado em frequência
            a = gen_nr_like();
            n = (0:length(a)-1).';
            fshift = (rand()*2 - 1) * 1.2e6;
            y = a .* exp(1j*2*pi*fshift*n/fs);

        case 4
            % LTE truncado + interferência estreita
            a = gen_lte_like();
            L = length(a);

            mask = zeros(L,1);
            i1 = randi([1 round(0.25*L)]);
            i2 = randi([round(0.55*L) L]);
            mask(i1:i2) = 1;
            a = a .* mask;

            n = (0:L-1).';
            tone = exp(1j*2*pi*(0.8e6 + 0.4e6*rand())*n/fs);
            y = a + 0.35*tone;

        case 5
            % WLAN + NR com offset e ocupação parcial
            a = gen_wlan_like();
            b = gen_nr_like();

            Na = length(a);
            Nb = length(b);
            N = min(Na, Nb);

            n = (0:N-1).';
            b = b(1:N) .* exp(1j*2*pi*(rand()*2-1)*1.0e6*n/fs);

            a = a(1:N);
            gate = zeros(N,1);
            j1 = randi([1 round(0.2*N)]);
            j2 = randi([round(0.5*N) N]);
            gate(j1:j2) = 1;
            a = a .* gate;

            y = a + 0.55*b;
    end

    y = impair_chan_basic(y, fs, 'mode', mode);
end