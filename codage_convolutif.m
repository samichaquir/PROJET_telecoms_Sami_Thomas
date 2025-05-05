% Réalisation du codage convolutif selon la figure 3 du sujet
function code = codage_convolutif(bits)
    code = bits;
    % s_n1 = b_n xor b_n-2
    % s_n2 = b_n xor b_n-1 xor b_n-2
    % ...
    % s_ni = sigma(j=0, j < K) {g_i(j)*b_k-j} 

    % gi = sigma(j=0, j < K) {g_i(j)*D^j}  D représente un retard de 1 bit
    % g1 = g_1(0) + g_1(2)*D^2 = 1 + D^2 ( -> s_n1 = g_1(0)*b_n + g_1(2)*b_n-2)
    % g2 = g_2(0) + g_2(1)*D + g_2(2)*D^2 ( -> s_n2)
end