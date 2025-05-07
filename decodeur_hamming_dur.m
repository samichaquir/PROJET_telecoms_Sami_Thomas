function bits_decodes = decodeur_hamming_dur(bits_recus)
% DECODEUR_HAMMING_DUR - Décodage dur par distance de Hamming
% bits_recus : vecteur binaire de longueur multiple de 7
% bits_decodes : vecteur binaire décodé (4 bits par mot)

H = [1 1 1 0 1 0 0;
     1 1 0 1 0 1 0;
     1 0 1 1 0 0 1];

n_blocs = length(bits_recus)/7;
bits_decodes = [];

for i = 1:n_blocs
    bloc = bits_recus((i-1)*7+1:i*7).';
    syndrome = mod(H * bloc, 2);
    syndrome_dec = bi2de(syndrome.', 'left-msb');
    
    % Correction si erreur détectée
    if syndrome_dec ~= 0
        bloc(syndrome_dec) = mod(bloc(syndrome_dec) + 1, 2);
    end
    
    % On garde les 4 premiers bits
    bits_decodes = [bits_decodes bloc(1:4).'];
end
end
