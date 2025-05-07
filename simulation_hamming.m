% simulation_hamming.m
% Simulation chaîne BPSK avec codage Hamming (7,4)
clc; clear; close all;

%% Paramètres
Rb = 3000;
Fe = 12000;
Te = 1/Fe;
Ns = Fe/Rb;
N = 4e3;  % multiple de 4 pour Hamming

Eb_N0_dB = 0:1:10;
TEB_sans = zeros(size(Eb_N0_dB));
TEB_dur = zeros(size(Eb_N0_dB));
TEB_souple = zeros(size(Eb_N0_dB));

for i = 1:length(Eb_N0_dB)
    %% Bits aléatoires
    bits = randi([0 1], 1, N);
    
    %% Sans codage
    symbols = 2*bits - 1;
    suite_diracs = kron(symbols, [1 zeros(1,Ns-1)]);
    h = ones(1,Ns);
    x = filter(h, 1, suite_diracs);
    Eb = mean(abs(symbols).^2);
    N0 = Eb / (10^(Eb_N0_dB(i)/10));
    sigma = sqrt(N0 * Fe / 2);
    r = x + sigma*randn(1,length(x));
    z = filter(h,1,r);
    z_ech = z(Ns:Ns:end);
    bits_det = z_ech > 0;
    TEB_sans(i) = mean(bits ~= bits_det);
    
    %% Avec codage Hamming
    code = codeur_hamming74(bits);
    symbols = 2*code - 1;
    suite_diracs = kron(symbols, [1 zeros(1,Ns-1)]);
    x = filter(h, 1, suite_diracs);
    r = x + sigma*randn(1,length(x));
    z = filter(h,1,r);
    z_ech = z(Ns:Ns:end);
    
    % Décodage dur
    decisions_dures = z_ech > 0;
    bits_hard = decodeur_hamming_dur(decisions_dures);
    TEB_dur(i) = mean(bits ~= bits_hard(1:N));
    
    % Décodage souple
    bits_soft = decodeur_hamming_souple(z_ech);
    TEB_souple(i) = mean(bits ~= bits_soft(1:N));
end

%% Affichage
figure;
semilogy(Eb_N0_dB, TEB_sans, 'k-', 'LineWidth', 2);
hold on;
semilogy(Eb_N0_dB, TEB_dur, 'r--', 'LineWidth', 2);
semilogy(Eb_N0_dB, TEB_souple, 'b-.', 'LineWidth', 2);
xlabel('Eb/N0 (dB)');
ylabel('TEB');
legend('Sans codage', 'Hamming dur', 'Hamming souple');
title('Comparaison Dur, Simple - Hamming (7,4)');
grid on;
