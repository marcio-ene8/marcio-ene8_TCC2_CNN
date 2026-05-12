function run_cnn_pipeline()
% run_cnn_pipeline
% Pipeline mestre atualizado para CNN com datasets separados:
% train_data_* e test_data_*

    clc;
    close all;

    fprintf('\n=============================\n');
    fprintf(' PIPELINE CNN - TREINO E TESTE\n');
    fprintf('=============================\n\n');

    % ---------------------------------------------------------
    % 1) PASTAS ATUAIS DO PIPELINE
    % ---------------------------------------------------------
    trainFolders = {'train_data_NR','train_data_LTE','train_data_WLAN', ...
                    'train_data_Noise','train_data_Unknown'};

    testFolders  = {'test_data_NR','test_data_LTE','test_data_WLAN', ...
                    'test_data_Noise','test_data_Unknown'};

    fprintf('Classes de treino:\n');
    disp(trainFolders);

    % ---------------------------------------------------------
    % 2) GERAR DATASETS SE NÃO EXISTIREM
    % ---------------------------------------------------------
    if ~all(cellfun(@isfolder, trainFolders))
        fprintf('\nDataset de treino não encontrado. Gerando...\n');
        make_dataset_classification_train(1500);
    end

    if ~all(cellfun(@isfolder, testFolders))
        fprintf('\nDataset de teste não encontrado. Gerando...\n');
        make_dataset_classification_test(400);
    end

    % ---------------------------------------------------------
    % 3) TREINAR CNN
    % ---------------------------------------------------------
    fprintf('\n[1/4] Treinando CNN...\n');
    cnnModel = train_cnn_spectrogram_classifier(trainFolders, testFolders);

    % ---------------------------------------------------------
    % 4) AVALIAR CNN NO TESTE
    % ---------------------------------------------------------
    fprintf('\n[2/4] Avaliando CNN no conjunto de teste...\n');
    evaluate_cnn_model(cnnModel, testFolders);

    % ---------------------------------------------------------
    % 5) TESTE COM SINAL LTE
    % ---------------------------------------------------------
    fprintf('\n[3/4] Teste com sinal LTE...\n');

    fs = 20e6;

    y_lte = gen_lte_like();
    y_lte = impair_chan_basic(y_lte, fs, 'mode', 'test');
    im_lte = spectrogram_image(y_lte, fs);

    [label_lte, scores_lte, maxScore_lte] = cnn_classify_frame(cnnModel, im_lte, 0.60);

    figure('Color','w');
    imshow(im_lte, []);
    title(sprintf('Teste LTE | Predição: %s | Confiança: %.3f', ...
        char(label_lte), maxScore_lte));

    fprintf('Predição LTE: %s\n', char(label_lte));
    fprintf('Confiança máxima LTE: %.4f\n', maxScore_lte);
    disp(scores_lte);

    % ---------------------------------------------------------
    % 6) TESTE COM UNKNOWN
    % ---------------------------------------------------------
    fprintf('\n[4/4] Teste com sinal Unknown...\n');

    y_unk = generate_unknown_signal(fs, 'test');
    im_unk = spectrogram_image(y_unk, fs);

    [label_unk, scores_unk, maxScore_unk] = cnn_classify_frame(cnnModel, im_unk, 0.60);

    figure('Color','w');
    imshow(im_unk, []);
    title(sprintf('Teste Unknown | Predição: %s | Confiança: %.3f', ...
        char(label_unk), maxScore_unk));

    fprintf('Predição Unknown: %s\n', char(label_unk));
    fprintf('Confiança máxima Unknown: %.4f\n', maxScore_unk);
    disp(scores_unk);

    fprintf('\n=============================\n');
    fprintf(' FIM DO PIPELINE CNN\n');
    fprintf('=============================\n\n');
end