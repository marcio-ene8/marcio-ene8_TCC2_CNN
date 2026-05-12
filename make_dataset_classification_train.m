function make_dataset_classification_train(nPerClass)
% make_dataset_classification_train
% Gera dataset de TREINO com 5 classes:
%   train_data_LTE
%   train_data_NR
%   train_data_WLAN
%   train_data_Noise
%   train_data_Unknown

    if nargin < 1 || isempty(nPerClass)
        nPerClass = 1500;
    end

    rng(42);
    fs = 20e6;

    folders = {'train_data_LTE','train_data_NR','train_data_WLAN','train_data_Noise','train_data_Unknown'};

    for i = 1:numel(folders)
        if isfolder(folders{i})
            rmdir(folders{i}, 's');
        end
        mkdir(folders{i});
    end

    fprintf('Gerando dataset de TREINO com %d amostras por classe...\n', nPerClass);

    for k = 1:nPerClass
        % LTE
        y = gen_lte_like();
        y = impair_chan_basic(y, fs, 'mode', 'train');
        im = spectrogram_image(y, fs);
        imwrite(im, fullfile('train_data_LTE', sprintf('lte_%05d.png', k)));

        % NR
        y = gen_nr_like();
        y = impair_chan_basic(y, fs, 'mode', 'train');
        im = spectrogram_image(y, fs);
        imwrite(im, fullfile('train_data_NR', sprintf('nr_%05d.png', k)));

        % WLAN
        y = gen_wlan_like();
        y = impair_chan_basic(y, fs, 'mode', 'train');
        im = spectrogram_image(y, fs);
        imwrite(im, fullfile('train_data_WLAN', sprintf('wlan_%05d.png', k)));

        % Noise
        if rand < 0.50
            y = generate_noise_signal(32768, fs, 'train');
        else
            % caso híbrido "quase ruído"
            s = gen_lte_like();
            s = s(:);
            if length(s) < 32768
                s = repmat(s, ceil(32768/length(s)), 1);
            end
            s = s(1:32768);
            s = impair_chan_basic(s, fs, 'mode', 'train');

            w = (randn(32768,1) + 1j*randn(32768,1))/sqrt(2);
            y = 0.10*s + w;
            y = y / max(sqrt(mean(abs(y).^2)), eps);
        end
        im = spectrogram_image(y, fs);
        imwrite(im, fullfile('train_data_Noise', sprintf('noise_%05d.png', k)));

        % Unknown
        y = generate_unknown_signal(fs, 'train');
        im = spectrogram_image(y, fs);
        imwrite(im, fullfile('train_data_Unknown', sprintf('unknown_%05d.png', k)));

        if mod(k,100) == 0
            fprintf('  TREINO: %d / %d\n', k, nPerClass);
        end
    end

    fprintf('Dataset de TREINO concluído.\n');
end