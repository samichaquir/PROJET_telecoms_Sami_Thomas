%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ETUDE MODULATEUR/DEMODULATEUR SUR CANAL AWGN
% CHAQUIR Sami, Avril 2025
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
close all

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%PARAMETRES GENERAUX 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Fe=12000;       %Fréquence d'échantillonnage
Te=1/Fe;        %Période d'échantillonnage
Rb=3000;        %Débit binaire souhaité
N=10000;         %Nombre de bits générés

M=2;                     % Modulation BPSK
Rs=Rb/log2(M);          % Débit symbole
Ns=Fe/Rs;               % Facteur de suréchantillonnage

%tableau des valeurs de SNR par bit souhaité à l'entrée du récepteur en dB
tab_Eb_N0_dB=0:6; 
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
    TES_codage=0;          %Initialisation du taux d'erreur symbole pour le cumul
    TEB_codage=0;          %Initialisation du taux d'erreur binaire pour le cumul

    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % BOUCLE POUR PRECISION TEB MESURE : COMPTAGE NOMBRE ERREURS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    while(nb_erreurs<1000)

        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %GENERATION DE L'INFORMATION BINAIRE
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        bits_init=randi([0,1],1,N);

        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %CODAGE CONVOLUTIF
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        bits_codage = codage_convolutif(bits_init);
        bits = bits_init;

        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %MAPPING
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        symboles=(-2)*bits+1;
        symboles_codage = (-2)*bits_codage+1;
        
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %SURECHANTILLONNAGE
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        somme_Diracs_ponderes=kron(symboles,[1 zeros(1,Ns-1)]);
        somme_Diracs_ponderes_codage=kron(symboles_codage,[1 zeros(1,Ns-1)]);
        
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %FILTRAGE DE MISE EN FORME 
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        alpha=0.5;
        h = ones(1, Ns);
        %h=rcosdesign(alpha,50,Ns);   
        Signal_emis=filter(h,1,somme_Diracs_ponderes);
        Signal_emis_codage=filter(h,1,somme_Diracs_ponderes_codage);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %CANAL DE PROPAGATION AWGN
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        P_signal=mean(abs(Signal_emis).^2);
        P_bruit=(P_signal*Ns)/(2*log2(M)*Eb_N0);
        Bruit=sqrt(P_bruit)*randn(1,length(Signal_emis));
        Bruit_codage=sqrt(P_bruit)*randn(1,length(Signal_emis_codage));
        Signal_recu=Signal_emis+Bruit;
        Signal_recu_codage=Signal_emis_codage+Bruit_codage;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %FILTRAGE DE RECEPTION
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        hr=ones(1,Ns);
        Signal_recu_filtre=filter(hr,1,Signal_recu);
        Signal_recu_filtre_codage=filter(hr,1,Signal_recu_codage);
        
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %ECHANTILLONNAGE
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        n0=Ns;
        Signal_echantillonne=Signal_recu_filtre(n0:Ns:end);
        Signal_echantillonne_codage=Signal_recu_filtre_codage(n0:Ns:end);
        
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %DECISIONS SUR LES SYMBOLES
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        symboles_recus=2*(Signal_echantillonne>0)-1;
        symboles_recus_codage=2*(Signal_echantillonne_codage>0)-1;
        
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %CALCUL DU TAUX D'ERREUR SYMBOLE CUMULE
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        TES=TES+sum(symboles_recus~=symboles)/length(symboles);
        TES_codage=TES_codage+sum(symboles_recus_codage~=symboles_codage)/length(symboles_codage);
        
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %DECODAGE DE VITERBI
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        bits_recus = (1-symboles_recus)/2;
        bits_recus_codage = decode_viterbi(symboles_recus_codage);

        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %CALCUL DU TAUX D'ERREUR BINAIRE CUMULE
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        TEB=TEB+sum(bits_recus~=bits_init)/length(bits_init);
        TEB_codage=TEB_codage+sum(bits_recus_codage~=bits_init)/length(bits_init);
        
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %CUMUL DU NOMBRE D'ERREURS ET NOMBRE DE CUMUL REALISES
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        nb_erreurs=nb_erreurs+sum(bits_recus~=bits_init)
        nb_cumul=nb_cumul+1;

    end  %fin boucle sur comptage nombre d'erreurs

    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %CALCUL DU TAUX D'ERREUR SYMBOLE ET DU TAUX D'ERREUR BINAIRE POUR LA
    %VALEUR TESTEE DE Eb/N0
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    TES_simule(indice_bruit)=TES/nb_cumul;
    TEB_simule(indice_bruit)=TEB/nb_cumul;
    TES_simule_codage(indice_bruit)=TES_codage/nb_cumul;
    TEB_simule_codage(indice_bruit)=TEB_codage/nb_cumul;
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
%TRACES DES TEB OBTENUS EN FONCTION DE Eb/N0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure
semilogy(tab_Eb_N0_dB,TEB_simule,'b-o')
hold on
semilogy(tab_Eb_N0_dB,TEB_simule_codage,'r-o')

legend('TEB simulé','TEB simulé codage')
xlabel('E_b/N_0 (dB)')
ylabel('TEB')
title('TEB de la chaine BPSK filtre rectangulaire')
