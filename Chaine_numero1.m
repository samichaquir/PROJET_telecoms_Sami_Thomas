%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ETUDE MODULATEUR/DEMODULATEUR SUR CANAL AWGN
% CHAQUIR Sami, Avril 2025
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
close all

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%PARAMETRES GENERAUX 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Fe=24000;       %Fréquence d'échantillonnage
Te=1/Fe;        %Période d'échantillonnage
Rb=3000;        %Débit binaire souhaité
N=10000;         %Nombre de bits générés

M=2;                     % Modulation BPSK
Rs=Rb/log2(M);          % Débit symbole
Ns=Fe/Rs;               % Facteur de suréchantillonnage

%tableau des valeurs de SNR par bit souhaité à l'entrée du récepteur en dB
tab_Eb_N0_dB=[0:6]; 
%Passage au SNR en linéaire
tab_Eb_N0=10.^(tab_Eb_N0_dB/10);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BOUCLE SUR LES NIVEAUX DE Eb/N0 A TESTER POUR OBTENTION DU TES ET DU TEB
% SIMULES DE LA CHAINE IMPLANTEE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for indice_bruit=1:length(tab_Eb_N0_dB)

    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % VALEUR DE Eb/N0 TESTEE
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Eb_N0_dB=tab_Eb_N0_dB(indice_bruit);
    Eb_N0=tab_Eb_N0(indice_bruit);

    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % INITIALISATIONS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    nb_erreurs=0;   %Variable permettant de compter le nombre d'erreurs cumulées
    nb_cumul=0;     %Variables permettant de compter le nombre de cumuls réalisés
    TES=0;          %Initialisation du taux d'erreur symbole pour le cumul
    TEB=0;          %Initialisation du taux d'erreur binaire pour le cumul

    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % BOUCLE POUR PRECISION TEB MESURE : COMPTAGE NOMBRE ERREURS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    while(nb_erreurs<10000)

        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %GENERATION DE L'INFORMATION BINAIRE
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        bits=randi([0,1],1,N);
        
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %MAPPING
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        symboles=2*bits-1;
        
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %SURECHANTILLONNAGE
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        somme_Diracs_ponderes=kron(symboles,[1 zeros(1,Ns-1)]);
        
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %FILTRAGE DE MISE EN FORME 
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        h=ones(1,Ns);   
        Signal_emis=filter(h,1,somme_Diracs_ponderes);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %CANAL DE PROPAGATION AWGN
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        P_signal=mean(abs(Signal_emis).^2);
        P_bruit=(P_signal*Ns)/(2*log2(M)*Eb_N0);
        Bruit=sqrt(P_bruit)*randn(1,length(Signal_emis));
        Signal_recu=Signal_emis+Bruit;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %FILTRAGE DE RECEPTION
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        hr=ones(1,Ns);
        Signal_recu_filtre=filter(hr,1,Signal_recu);
        
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %ECHANTILLONNAGE
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        n0=Ns;
        Signal_echantillonne=Signal_recu_filtre(n0:Ns:end);
        
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %DECISIONS SUR LES SYMBOLES
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        symboles_recus=2*(Signal_echantillonne>0)-1;
        
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %CALCUL DU TAUX D'ERREUR SYMBOLE CUMULE
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        TES=TES+sum(symboles_recus~=symboles)/length(symboles);
        
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %DEMAPPING
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        bits_recus=(symboles_recus+1)/2;
        
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %CALCUL DU TAUX D'ERREUR BINAIRE CUMULE
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        TEB=TEB+sum(bits_recus~=bits)/length(bits);
        
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %CUMUL DU NOMBRE D'ERREURS ET NOMBRE DE CUMUL REALISES
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        nb_erreurs=nb_erreurs+sum(bits_recus~=bits);
        nb_cumul=nb_cumul+1;

    end  %fin boucle sur comptage nombre d'erreurs

    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %CALCUL DU TAUX D'ERREUR SYMBOLE ET DU TAUX D'ERREUR BINAIRE POUR LA
    %VALEUR TESTEE DE Eb/N0
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    TES_simule(indice_bruit)=TES/nb_cumul;
    TEB_simule(indice_bruit)=TEB/nb_cumul;

     %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %DIAGRAMME DE L'OEIL EN SORTIE DU FILTRE DE RECEPTION AVEC BRUIT
    %TRACE POUR CHAQUE VALEUR DE Eb/N0
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    oeil=reshape(Signal_recu_filtre(1:Ns*100),Ns,[]);
    figure
    plot(oeil)
    title(['Tracé du diagramme de l"oeil en sortie du filtre de réception pour E_b/N_0 = ' num2str(Eb_N0_dB) ' dB'])

end  %fin boucle sur les valeurs testées de Eb/N0

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%CALCUL DU TES ET DU TEB THEORIQUE DE LA CHAINE IMPLANTEE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
TES_THEO=qfunc(sqrt(2*tab_Eb_N0));
TEB_THEO=TES_THEO;

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%TRACES DES TES ET TEB OBTENUS EN FONCTION DE Eb/N0
%COMPARAISON AVEC LES TES et TEBs THEORIQUES DE LA CHAINE IMPLANTEE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure
semilogy(tab_Eb_N0_dB,TES_THEO,'r-x')
hold on
semilogy(tab_Eb_N0_dB,TES_simule,'b-o')
legend('TES théorique','TES simulé')
xlabel('E_b/N_0 (dB)')
ylabel('TES')
title('TES de la chaine BPSK filtre rectangulaire')

figure
semilogy(tab_Eb_N0_dB,TEB_THEO,'r-x')
hold on
semilogy(tab_Eb_N0_dB,TEB_simule,'b-o')
legend('TEB théorique','TEB simulé')
xlabel('E_b/N_0 (dB)')
ylabel('TEB')
title('TEB de la chaine BPSK filtre rectangulaire')
