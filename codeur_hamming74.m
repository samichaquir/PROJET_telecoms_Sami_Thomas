function code = codeur_hamming74(bits)
% CODEUR_HAMMING74 - Codage Hamming (7,4) systématique
% bits : vecteur binaire d'entrée (doit être multiple de 4)
% code : vecteur binaire codé (sortie)

G = [1 0 0 0 1 0 1;
     0 1 0 0 1 1 1;
     0 0 1 0 1 1 0;
     0 0 0 1 0 1 1];

bits = reshape(bits, 4, []).';  % 4 bits par ligne
code = mod(bits * G, 2);        % Produit matriciel dans F2
code = reshape(code.', 1, []);  % Mise en vecteur ligne

end
