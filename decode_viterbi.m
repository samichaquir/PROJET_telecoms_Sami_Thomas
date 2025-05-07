% Réalisation du décodage de VITERBI dur selon le graphe du sujet
function bits_decode = decode_viterbi(symboles)
    % entrée : bits = [-1, 1, 1, -1, ...] taille n
    % sortie : bits_decode = [1, 0, ...] taille n/2
    n = size(symboles,2);
    bits_decode = zeros(1,n/2);

    etat = 0;


    for j = 1:2:n
        s1 = symboles(j);
        s2 = symboles(j+1);
        switch etat
            case 0
                trans_0 = (s1-1)^2 + (s2-1)^2;
                trans_1 = (s1+1)^2 + (s2-1)^2;
                if (trans_0 <= trans_1)
                    etat = 0;
                    bits_decode((j+1)/2) = 0;
                else
                    etat = 2;
                    bits_decode((j+1)/2) = 1;
                end
            case 1
                trans_0 = (s1+1)^2 + (s2+1)^2;
                trans_1 = (s1-1)^2 + (s2-1)^2;
                if (trans_0 <= trans_1)
                    etat = 0;
                    bits_decode((j+1)/2) = 0;
                else
                    etat = 2;
                    bits_decode((j+1)/2) = 1;
                end
            case 2
                trans_0 = (s1-1)^2 + (s2+1)^2;
                trans_1 = (s1+1)^2 + (s2-1)^2;
                if (trans_0 <= trans_1)
                    etat = 1;
                    bits_decode((j+1)/2) = 0;
                else
                    etat = 3;
                    bits_decode((j+1)/2) = 1;
                end
            otherwise
                trans_0 = (s1+1)^2 + (s2-1)^2;
                trans_1 = (s1-1)^2 + (s2+1)^2;
                if (trans_0 <= trans_1)
                    etat = 1;
                    bits_decode((j+1)/2) = 0;
                else
                    etat = 3;
                    bits_decode((j+1)/2) = 1;
                end
        end
    end 
end