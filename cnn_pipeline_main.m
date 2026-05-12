function cnn_pipeline_main()
% Pipeline principal com treino em train_* e avaliação em test_*

    clc;
    close all;

    trainFolders = {'train_data_NR','train_data_LTE','train_data_WLAN','train_data_Noise','train_data_Unknown'};
    testFolders  = {'test_data_NR','test_data_LTE','test_data_WLAN','test_data_Noise','test_data_Unknown'};

    fprintf('=====================================\n');
    fprintf(' CNN PIPELINE - TRAIN/TEST SEPARADOS \n');
    fprintf('=====================================\n');

    cnnModel = train_cnn_spectrogram_classifier(trainFolders, testFolders);
    evaluate_cnn_model(cnnModel, testFolders);

    fprintf('\nTeste rápido com LTE degradado:\n');
    fs = 20e6;
    y  = gen_lte_like();
    y  = impair_chan_basic(y, fs, 'mode', 'test');
    im = spectrogram_image(y, fs);

    [label, scores, maxScore] = cnn_classify_frame(cnnModel, im, 0.60);

    figure('Color','w');
    imshow(im, []);
    title(sprintf('Predição: %s | score=%.3f', char(label), maxScore));

    disp(label);
    disp(scores);
end