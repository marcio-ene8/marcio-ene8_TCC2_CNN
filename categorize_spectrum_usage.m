function categoria = categorize_spectrum_usage(label, score_anomalia)
% categorize_spectrum_usage
% Converte a classe CNN em categoria operacional de uso do espectro.

    labelStr = string(label);

    if labelStr == "data_Noise"
        categoria = "Faixa livre / ruído";

    elseif labelStr == "data_LTE" || labelStr == "data_NR" || labelStr == "data_WLAN"
        if score_anomalia > 0.40
            categoria = "Uso conhecido com baixa confiança";
        else
            categoria = "Uso conhecido autorizado";
        end

    elseif labelStr == "data_Unknown"
        categoria = "Uso desconhecido / possível anomalia";

    else
        categoria = "Categoria indefinida";
    end
end