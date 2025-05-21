% Réalisation du décodage de VITERBI souple selon le graphe du sujet
function bits_decode = decode_viterbi(symboles)
    % entrée : bits = [-1, 1, 1, -1, ...] taille n
    % sortie : bits_decode = [1, 0, ...] taille n/2
    n = size(symboles,2);
    bits_decode = zeros(1,n/2);

    % Les 4 chemins des départs de chaque sommet
    chemins = zeros(4, n/2);

    % Les distances cumulées de chaque sommet
    distance_cumulee = zeros(4,(n/2) + 1);
    distance_cumulee(1:4,2:end) = (4*n);
    distance_cumulee(2:4,1) = 4*n;


    for k = 1:2:n
        s1 = symboles(k);
        s2 = symboles(k+1);
        j = round(k/2);
        % etat = 00
        trans_0 = distance_cumulee(1,j) + (s1-1)^2 + (s2-1)^2;
        trans_1 = distance_cumulee(1,j) + (s1+1)^2 + (s2+1)^2;
        if (trans_0 <= distance_cumulee(1,j+1))
            distance_cumulee(1,j+1) = trans_0;
            chemins(1,j) = 0; % On modifie le chemin depuis l'état d'arrivée
        end
            
        
        if (trans_1 <= distance_cumulee(3,j+1))
            distance_cumulee(3,j+1) = trans_1;
            chemins(3,j) = 0;% On modifie le chemin depuis l'état d'arrivée
        end
            
       

        %etat 01
        trans_0 = distance_cumulee(2,j) + (s1+1)^2 + (s2+1)^2;
        trans_1 = distance_cumulee(2,j) + (s1-1)^2 + (s2-1)^2;
        if (trans_0 <= distance_cumulee(1,j+1))
            distance_cumulee(1,j+1) = trans_0;
            chemins(1,j) = 1;% On modifie le chemin depuis l'état d'arrivée
        end
            
        if (trans_1 <= distance_cumulee(3,j+1))
            distance_cumulee(3,j+1) = trans_1;
            chemins(3,j) = 1;% On modifie le chemin depuis l'état d'arrivée
        end
            

        % etat 10
        trans_0 = distance_cumulee(3,j) + (s1-1)^2 + (s2+1)^2;
        trans_1 = distance_cumulee(3,j) + (s1+1)^2 + (s2-1)^2;
        if (trans_0 <= distance_cumulee(2,j+1))
            distance_cumulee(2,j+1) = trans_0;
            chemins(2,j) = 0;% On modifie le chemin depuis l'état d'arrivée
        end  
            
        if (trans_1 <= distance_cumulee(4,j+1))
            distance_cumulee(4,j+1) = trans_1;
            chemins(4,j) = 0;% On modifie le chemin depuis l'état d'arrivée
        end   
        
        %etat 11
        trans_0 = distance_cumulee(4,j) + (s1+1)^2 + (s2-1)^2;
        trans_1 = distance_cumulee(4,j) + (s1-1)^2 + (s2+1)^2;
        if (trans_0 <= distance_cumulee(2,j+1))
            distance_cumulee(2,j+1) = trans_0;
            chemins(2,j) = 1;% On modifie le chemin depuis l'état d'arrivée
        end 
        
        if (trans_1 <= distance_cumulee(4,j+1))
            distance_cumulee(4,j+1) = trans_1;
            chemins(4,j) = 1;% On modifie le chemin depuis l'état d'arrivée
        end   
            
    end 

    % Récupération  de la distance cumulée la plus petite
    distance_cumulee;
    distance_finale = distance_cumulee(1:4,(n/2)+1);
    [~,indice_chemin] = min(distance_finale);
    indice_chemin;
    chemins;
    
    % Reconstitution des bits
    for k = 1:(n/2)
        j = (n/2) - k + 1;
        switch indice_chemin 
            case 1
                if (chemins(indice_chemin,j) == 0)
                    indice_chemin = 1;
                    bits_decode(1,j) = 0;
                else
                    indice_chemin = 2;
                    bits_decode(1,j) = 0;
                end
            case 2
                if (chemins(indice_chemin,j) == 0)
                    indice_chemin = 3;
                    bits_decode(1,j) = 0;
                else
                    indice_chemin = 4;
                    bits_decode(1,j) = 0;
                end
            case 3
                if (chemins(indice_chemin,j) == 0)
                    indice_chemin = 1;
                    bits_decode(1,j) = 1;
                else
                    indice_chemin = 2;
                    bits_decode(1,j) = 1;
                end
            otherwise
                if (chemins(indice_chemin,j) == 0)
                    indice_chemin = 3;
                    bits_decode(1,j) = 1;
                else
                    indice_chemin = 4;
                    bits_decode(1,j) = 1;
                end
        end
    end
end