function cnnModel = train_cnn_spectrogram_classifier(trainFolders, testFolders)
% train_cnn_spectrogram_classifier
% Treina CNN usando treino e valida em TESTE separado.

    if nargin < 1 || isempty(trainFolders)
        trainFolders = {'train_data_NR','train_data_LTE','train_data_WLAN','train_data_Noise','train_data_Unknown'};
    end

    if nargin < 2 || isempty(testFolders)
        testFolders = {'test_data_NR','test_data_LTE','test_data_WLAN','test_data_Noise','test_data_Unknown'};
    end

    [imdsTrain, classNames] = extract_cnn_data(trainFolders);

    imdsVal = imageDatastore(testFolders, ...
        'IncludeSubfolders', true, ...
        'LabelSource', 'foldernames', ...
        'ReadFcn', @local_read_cnn_image);

    imdsVal.Labels = local_normalize_labels(imdsVal.Labels);

    inputSize = [64 64 1];
    numClasses = numel(classNames);

    augTrain = augmentedImageDatastore(inputSize(1:2), imdsTrain);
    augVal   = augmentedImageDatastore(inputSize(1:2), imdsVal);

    layers = [
        imageInputLayer(inputSize, 'Normalization','zscore', 'Name','input')

        convolution2dLayer(3,16,'Padding','same','Name','conv1')
        batchNormalizationLayer('Name','bn1')
        reluLayer('Name','relu1')
        maxPooling2dLayer(2,'Stride',2,'Name','pool1')

        convolution2dLayer(3,32,'Padding','same','Name','conv2')
        batchNormalizationLayer('Name','bn2')
        reluLayer('Name','relu2')
        maxPooling2dLayer(2,'Stride',2,'Name','pool2')

        convolution2dLayer(3,64,'Padding','same','Name','conv3')
        batchNormalizationLayer('Name','bn3')
        reluLayer('Name','relu3')
        maxPooling2dLayer(2,'Stride',2,'Name','pool3')

        fullyConnectedLayer(96,'Name','fc1')
        reluLayer('Name','relu4')
        dropoutLayer(0.45,'Name','drop1')

        fullyConnectedLayer(numClasses,'Name','fc_out')
        softmaxLayer('Name','softmax')
        classificationLayer('Name','classOut')
    ];

    options = trainingOptions('adam', ...
        'MaxEpochs', 18, ...
        'MiniBatchSize', 32, ...
        'InitialLearnRate', 8e-4, ...
        'L2Regularization', 1e-4, ...
        'Shuffle', 'every-epoch', ...
        'ValidationData', augVal, ...
        'ValidationFrequency', 20, ...
        'Verbose', true, ...
        'Plots', 'training-progress');

    cnnModel = trainNetwork(augTrain, layers, options);

    save('cnn_spectrum_model.mat', 'cnnModel', 'classNames');
    fprintf('Modelo salvo em cnn_spectrum_model.mat\n');
end


function im = local_read_cnn_image(filename)
    im = imread(filename);

    if size(im,3) == 3
        im = rgb2gray(im);
    end

    im = imresize(im, [64 64]);
    im = single(im);

    if ndims(im) == 2
        im = reshape(im, [64 64 1]);
    end
end


function labelsOut = local_normalize_labels(labelsIn)
    strs = string(labelsIn);
    strs = erase(strs, "train_");
    strs = erase(strs, "test_");
    labelsOut = categorical(strs);
end