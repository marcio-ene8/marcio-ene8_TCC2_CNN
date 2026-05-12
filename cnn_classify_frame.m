function [label, scores, maxScore, score_anomalia, status] = cnn_classify_frame(arg1, arg2, arg3)
% cnn_classify_frame
% Classifica um espectrograma e calcula status Normal/Suspeito.
%
% Uso:
%   [label, scores, maxScore, score_anomalia, status] = cnn_classify_frame(im)
%   [label, scores, maxScore, score_anomalia, status] = cnn_classify_frame(cnnModel, im)
%   [label, scores, maxScore, score_anomalia, status] = cnn_classify_frame(cnnModel, im, threshold)

    % -----------------------------
    % Parâmetros ajustados
    % -----------------------------
    defaultThreshold = 0.45;      % antes: 0.60
    marginThreshold  = 0.05;      % antes: 0.08
    limiarAnomalia   = 0.65;      % antes: 0.40

    % -----------------------------
    % Entrada
    % -----------------------------
    if nargin == 1
        im = arg1;
        threshold = defaultThreshold;

        if isfile('cnn_spectrum_model.mat')
            s = load('cnn_spectrum_model.mat');
            cnnModel = s.cnnModel;
        else
            error('Modelo cnn_spectrum_model.mat não encontrado.');
        end

    elseif nargin == 2
        cnnModel = arg1;
        im = arg2;
        threshold = defaultThreshold;

        if isempty(cnnModel)
            if isfile('cnn_spectrum_model.mat')
                s = load('cnn_spectrum_model.mat');
                cnnModel = s.cnnModel;
            else
                error('Modelo cnn_spectrum_model.mat não encontrado.');
            end
        end

    elseif nargin == 3
        cnnModel = arg1;
        im = arg2;
        threshold = arg3;

        if isempty(cnnModel)
            if isfile('cnn_spectrum_model.mat')
                s = load('cnn_spectrum_model.mat');
                cnnModel = s.cnnModel;
            else
                error('Modelo cnn_spectrum_model.mat não encontrado.');
            end
        end

    else
        error('Uso correto: cnn_classify_frame(im), cnn_classify_frame(cnnModel, im) ou cnn_classify_frame(cnnModel, im, threshold).');
    end

    if isempty(im)
        error('Forneça a imagem do espectrograma.');
    end

    % -----------------------------
    % Pré-processamento
    % -----------------------------
    if size(im,3) == 3
        im = rgb2gray(im);
    end

    im = imresize(im, [64 64]);
    im = single(im);

    if ndims(im) == 2
        im = reshape(im, [64 64 1]);
    end

    % -----------------------------
    % Classificação
    % -----------------------------
    [rawLabel, scores] = classify(cnnModel, im);

    [sortedScores, ~] = sort(scores, 'descend');
    maxScore = sortedScores(1);

    if numel(sortedScores) >= 2
        secondScore = sortedScores(2);
    else
        secondScore = 0;
    end

    margin = maxScore - secondScore;

    % -----------------------------
    % Regra Unknown mais equilibrada
    % Agora só força Unknown se confiança baixa E margem baixa.
    % -----------------------------
    if maxScore < threshold && margin < marginThreshold
        label = categorical("data_Unknown");
    else
        label = rawLabel;
    end

    % -----------------------------
    % Índice de anomalia
    % -----------------------------
    score_anomalia = 1 - maxScore;

    if label == categorical("data_Unknown") || score_anomalia > limiarAnomalia
        status = "Suspeito";
    else
        status = "Normal";
    end

    % -----------------------------
    % Modo visual
    % -----------------------------
    if nargout == 0
        figure('Color','w');
        imshow(im(:,:,1), []);
        title(sprintf('Predição: %s | Conf: %.3f | Anomalia: %.3f | %s', ...
            char(label), maxScore, score_anomalia, status));
        clear label scores maxScore score_anomalia status
    end
end