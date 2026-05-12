function make_dataset_classification_test(nPerClass)
% make_dataset_classification_test
% Gera dataset de TESTE com 5 classes:
%   test_data_LTE
%   test_data_NR
%   test_data_WLAN
%   test_data_Noise
%   test_data_Unknown

    if nargin < 1 || isempty(nPerClass)
        nPerClass = 400;
    end

    rng(123);
    fs = 20e6;

    folders = {'test_data_LTE','test_data_NR','test_data_WLAN','test_data_Noise','test_data_Unknown'};

    for i = 1:numel(folders)
        if isfolder(folders{i})
            rmdir(folders{i}, 's');
        end
        mkdir(folders{i});
    end

    fprintf('Gerando dataset de TESTE com %d amostras por classe...\n', nPerClass);

    for k = 1:nPerClass
        % LTE
        y = gen_lte_like();
        y = impair_chan_basic(y, fs, 'mode', 'test');
        im = spectrogram_image(y, fs);
        imwrite(im, fullfile('test_data_LTE', sprintf('lte_%05d.png', k)));

        % NR
        y = gen_nr_like();
        y = impair_chan_basic(y, fs, 'mode', 'test');
        im = spectrogram_image(y, fs);
        imwrite(im, fullfile('test_data_NR', sprintf('nr_%05d.png', k)));

        % WLAN
        y = gen_wlan_like();
        y = impair_chan_basic(y, fs, 'mode', 'test');
        im = spectrogram_image(y, fs);
        imwrite(im, fullfile('test_data_WLAN', sprintf('wlan_%05d.png', k)));

        % Noise
        if rand < 0.55
            y = generate_noise_signal(32768, fs, 'test');
        else
            % caso ainda mais ambíguo no teste
            if rand < 0.5
                s = gen_lte_like();
            else
                s = gen_nr_like();
            end
            s = s(:);
            if length(s) < 32768
                s = repmat(s, ceil(32768/length(s)), 1);
            end
            s = s(1:32768);
            s = impair_chan_basic(s, fs, 'mode', 'test');

            w = (randn(32768,1) + 1j*randn(32768,1))/sqrt(2);
            y = 0.08*s + w;
            y = y / max(sqrt(mean(abs(y).^2)), eps);
        end
        im = spectrogram_image(y, fs);
        imwrite(im, fullfile('test_data_Noise', sprintf('noise_%05d.png', k)));

        % Unknown
        y = generate_unknown_signal(fs, 'test');
        im = spectrogram_image(y, fs);
        imwrite(im, fullfile('test_data_Unknown', sprintf('unknown_%05d.png', k)));

        if mod(k,100) == 0
            fprintf('  TESTE: %d / %d\n', k, nPerClass);
        end
    end

    fprintf('Dataset de TESTE concluído.\n');
end