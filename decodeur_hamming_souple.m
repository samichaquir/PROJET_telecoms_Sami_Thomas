function bits_decodes = decodeur_hamming_souple(symboles)
% DECODEUR_HAMMING_SOUPLE - Décodage souple par distance euclidienne
% symboles : vecteur de symboles reçus (-1/+1 bruités)
% bits_decodes : bits d'information estimés

G = [1 0 0 0 1 0 1;
     0 1 0 0 1 1 1;
     0 0 1 0 1 1 0;
     0 0 0 1 0 1 1];

% Dictionnaire des 2^4 = 16 mots de code possibles
info_bits = de2bi(0:15, 4, 'left-msb');
codebook = mod(info_bits * G, 2);
mapping = 2*codebook - 1;  % BPSK: 0->-1, 1->+1

bits_decodes = [];

for i = 1:7:length(symboles)
    bloc = symboles(i:i+6);
    distances = sum((mapping - bloc).^2, 2);
    [~, idx] = min(distances);
    bits_decodes = [bits_decodes info_bits(idx, :)];
end

bits_decodes = reshape(bits_decodes.', 1, []);
end
