function make_dataset_classification(nPerClass)
% make_dataset_classification
% Gera dataset de espectrogramas para:
%   data_LTE, data_NR, data_WLAN, data_Noise, data_Unknown
%
% Uso:
%   make_dataset_classification(1500)

    if nargin < 1 || isempty(nPerClass)
        nPerClass = 1500;
    end

    rng(42);

    fs = 20e6;

    classFolders = {'data_LTE','data_NR','data_WLAN','data_Noise','data_Unknown'};

    % recria pastas
    for i = 1:numel(classFolders)
        if isfolder(classFolders{i})
            rmdir(classFolders{i}, 's');
        end
        mkdir(classFolders{i});
    end

    fprintf('Gerando dataset com %d amostras por classe...\n', nPerClass);

    for k = 1:nPerClass
        % ------------------------
        % LTE
        % ------------------------
        y = gen_lte_like();
        y = impair_chan_basic(y, fs);
        im = spectrogram_image(y, fs);
        imwrite(im, fullfile('data_LTE', sprintf('lte_%05d.png', k)));

        % ------------------------
        % NR
        % ------------------------
        y = gen_nr_like();
        y = impair_chan_basic(y, fs);
        im = spectrogram_image(y, fs);
        imwrite(im, fullfile('data_NR', sprintf('nr_%05d.png', k)));

        % ------------------------
        % WLAN
        % ------------------------
        y = gen_wlan_like();
        y = impair_chan_basic(y, fs);
        im = spectrogram_image(y, fs);
        imwrite(im, fullfile('data_WLAN', sprintf('wlan_%05d.png', k)));

        % ------------------------
        % Noise
        % ------------------------
        y = (randn(32768,1) + 1j*randn(32768,1))/sqrt(2);
        y = impair_chan_basic(y, fs, 'noiseOnly', true);
        im = spectrogram_image(y, fs);
        imwrite(im, fullfile('data_Noise', sprintf('noise_%05d.png', k)));

        % ------------------------
        % Unknown (estruturado)
        % ------------------------
        y = generate_unknown_signal(fs);
        im = spectrogram_image(y, fs);
        imwrite(im, fullfile('data_Unknown', sprintf('unknown_%05d.png', k)));

        if mod(k,100) == 0
            fprintf('  %d / %d\n', k, nPerClass);
        end
    end

    fprintf('Dataset concluído.\n');
end


function y = generate_unknown_signal(fs)
% Classe Unknown recriada de forma estruturada:
% mistura/interferência/ocupação parcial/truncamento

    mode = randi(5);

    switch mode
        case 1
            % NR + WLAN
            a = gen_nr_like();
            b = gen_wlan_like();
            N = min(length(a), length(b));
            y = a(1:N) + 0.8*b(1:N);

        case 2
            % LTE + WLAN
            a = gen_lte_like();
            b = gen_wlan_like();
            N = min(length(a), length(b));
            y = a(1:N) + 0.7*b(1:N);

        case 3
            % NR + LTE
            a = gen_nr_like();
            b = gen_lte_like();
            N = min(length(a), length(b));
            y = a(1:N) + 0.6*b(1:N);

        case 4
            % LTE truncado + noise forte
            a = gen_lte_like();
            L = length(a);
            cut1 = randi([1 round(0.2*L)]);
            cut2 = randi([round(0.6*L) L]);
            mask = zeros(size(a));
            mask(cut1:cut2) = 1;
            a = a .* mask;
            n = (randn(size(a)) + 1j*randn(size(a)))/sqrt(2);
            y = a + 0.8*n;

        case 5
            % WLAN deslocado em frequência + noise
            a = gen_wlan_like();
            n = (0:length(a)-1).';
            fshift = (rand()*2 - 1) * 1.5e6; % ±1.5 MHz
            a = a .* exp(1j*2*pi*fshift*n/fs);
            n0 = (randn(size(a)) + 1j*randn(size(a)))/sqrt(2);
            y = a + 0.5*n0;
    end

    y = impair_chan_basic(y, fs);
end