clear all

% Documentation: Nonlinear least-squares solver:
% https://de.mathworks.com/help/optim/ug/lsqcurvefit.html 
% Kappa als Fitparameter - nicht mehr über isosbestischen Punkt !!
%%          ##----- DATEN EINLESEN -----##
A = readmatrix('FL_Pr_Ohne_UG.txt');

% x-Achse in Wellenzahlen, entnommen der ersten Spalte der txt-Datei
x = A(:,1);
x = rmmissing(x);
x = 10^7./x; % Das hier verwenden, falls in Wellenlänge


% y-Achse in Absorption
y_1 = A(:,2);
y_1 = rmmissing(y_1);


%%          ##----- FITFUNKTIONEN -----##

%           ##----- BATHYS -----##

pabphp_fittype = @(c,x) c(1)*(c(2)*Pfr_PaBphP(x) + (1-c(2))*Pr_PaBphP(x));

agp2d783n_fittype = @(c,x) c(1)*(c(2)*Pfr_Agp2D783N(x) + (1-c(2))*Pr_Agp2D783N(x));

agp2wt_fittype = @(c,x) c(1)*(c(2)*Pfr_Agp2WT(x) + (1-c(2))*Pr_Agp2WT(x));

xccwt_fittype = @(c,x) c(1)*(c(2)*Pfr_XccWT(x) + (1-c(2))*Pr_XccWT(x));

xccpas9_fittype = @(c,x) c(1)*(c(2)*Pfr_XccPAS9(x) + (1-c(2))*Pr_XccPAS9(x));

rtp2_fittype = @(c,x) c(1)*(c(2)*Pfr_RtP2(x) + (1-c(2))*Pr_RtP2(x));

avp2_wt_fittype = @(c,x) c(1)*(c(2)*Pfr_Avp2(x) + (1-c(2))*Pr_Avp2(x));

%           ## KANONISCH -----##

agp1_fittype = @(c,x) c(1)*(c(2)*Pfr_Agp1(x) + (1-c(2))*Pr_Agp1(x));

pstp1_fittype = @(c,x) c(1)*(c(2)*Pfr_PstP1(x) + (1-c(2))*Pr_PstP1(x));

%%          ##----- SKALIERUNGSFAKTOR: Ausgangspunkt für Fitparameter -----##
% Verhältnis aus:
% OD der experimentellen Daten bei dem Schnittpunkt der Reinformen und
% der OD der Reinform-Spektren bei der selben Wellenzahl

%           ##----- BATHY -----##
% PaBphP --> lambda = 718 nm bzw.  nu = 13927.5766 cm^-1
% Agp2 D783N --> lambda = 715.5 nm bzw nu = 13976.2404 cm^-1
% Agp2 WT --> lambda = 714 nm bzw.    nu = 14005.6022 cm^-1
% XccBphP WT --> lambda = 704 nm bzw. nu = 14204.5455 cm^-1
% XccBphP Delta Pas9 --> lambda = 704 nm bzw. nu = 14204.5455 cm^-1
% RtBphP2 --> lambda = 646 nm bzw nu = 15479.8762 cm^-1 ||| 720 = 13888.8889
% AvBphP2 WT --> lambda 717.5/717 nm bzw nu = 13947.0014 cm^-1

kappa_pabphp = y_1(find(x < 13928 & x>13927))./ 0.553428278;
kappa_agp2d783n = y_1(find(x < 13980 & x > 13960))./ 0.754301646;
kappa_agp2wt = y_1(find( x < 14006 & x > 14005))./ 0.84747794;
kappa_xccwt = y_1(find( x < 14205 & x > 14204))./ 0.52763496;
kappa_xccpas9 = y_1(find( x < 14205 & x > 14204))./ 0.522777198;
kappa_rtp2 = y_1(find(x < 15480 & x > 15479 ))./ 0.609945657;
kappa_avp2_wt = y_1(find(x < 13950 & x > 13947 ))./ 0.613858137;

%           ##----- KANONISCH -----##

% Agp1 --> lambda = 721.5 nm bzw.  nu = 13860.0139 cm^-1
%         gerundet: lambda = 722 nm bzw. nu = 13850.4155 cm^-1
%           ^-- nur für ganze Wellenlängen Unterschiede
% PstBphP1 --> lambda = 723 nm bzw. nu = 13831.2586 cm^-1

kappa_agp1 = y_1(find( x < 13860.5 & x > 13850))./ 0.467174941;
kappa_pstp1 = y_1(find( x < 13831.5 & x > 13831))./ 0.458932687;



%% --> FOLGEND ÄNDERUNGEN <-- ###--!!! FITTYPE UND KAPPA !!!--##
%-------------|_phy_|----#
const = kappa_xccpas9;
%---------|_phy_|-------#
fittype = xccpas9_fittype;

[fit_der_daten, resnorm,residuals,exitflag,output,lambda,jacobian] = lsqcurvefit(fittype,[const,0.5],x,y_1,[0,0],[inf,1]);

alpha_wert = fit_der_daten(2);
kappa = fit_der_daten(1);

if exitflag == 1
    disp("Funktion konvergiert auf Lösung")
end

%%                  ### STANDARDABWEICHUNG ###
%ci = nlparci(beta,r,"Covar",CovB) returns the 95% confidence 
% intervals ci for the nonlinear least-squares parameter estimates beta. 
% Documentation: 
% https://de.mathworks.com/help/optim/ug/nonlinear-curve-fitting-with-lsqcurvefit.html
ci = nlparci(fit_der_daten,residuals,'jacobian',jacobian);
conf_ob = ci(2,2);
agustd = (ci(2)-alpha_wert)/alpha_wert *100;

%%                  ### RESIDUUM ###

%plot(x,residuals);
hold on

%fitdata_y = fittype(fit_der_daten,x);

%%          ##----- PLOTTING -----##

plot(x,y_1, 'ok', x, fittype(fit_der_daten,x),'-g');



% Achsen
clear title;
clear xlabel;
clear ylabel;
xlabel('\boldmath$\tilde{\nu} / cm^{-1}$','FontSize',22,'Interpreter','latex');
ylabel('\boldmath$Absorption / OD$','FontSize',22, 'Interpreter','latex'); 
ax = gca;

maximum_y = max(y_1) + 0.05*max(y_1);

set(gca,'XDir','reverse','Xlim',[min(x),max(x)],'Ylim',[-0.005,maximum_y]); %Invertiert die x-Achse, begrenzt x- und y-Achse auf erwünschte Parameter
ax.FontSize = 30; % Schriftgröße der Achsen


% LEGEND UND TITEL
% Titel
title('$\underline{\bf{Phytochrom{\ } xx:{\ }  {\lambda_{Diode} = xxx{\ }nm, t = xx {\ }min}}}$', 'FontSize',26,'FontWeight','bold','FontName','Verdana', 'Interpreter','latex'); 
%'$\underline{\bf{Agp2{\ } D783N:{\ }  {\lambda_{Diode} = 428{\ }nm, t = 20 {\ }min}}}$'

%Ordnet Plots Namen zu (Reihenfolge!) und lokalisiert sie im "Nord-Westen" des Diagramms
legend({'{$\,$}{$\,$}Rohdaten','{$\,$}{$\,$}Fitfunktion'}...
    ,'Location','northwest','FontSize',28,'interpreter','latex'); 
% Fügt Anteil Pfr aus Fit dem Plot hinzu
str = {'{\textbf{\underline{Anteil Pfr:}}}', '{$\alpha$} =' num2str(alpha_wert)}; 
text(min(x)+1500, max(y_1) - 0.1*max(y_1), str, 'FontSize',18, 'interpreter','latex'); % x- und y-Koordinate von Text 1
pbaspect([1.2 1 1])


%%               ##----- FUNCTIONS -----##


% HERE BE DRAGONS - DO NOT MODIFY !!!
%% ##----- PaBphP WT -----##
function pfr_form_pabphp = Pfr_PaBphP(x)
% Gauss Peak 1
    xc_1 = 13164.58981; 
    w_1 = 720.7408;
    A_1 = 375.01478 ; 
    
    %Gauss Peak 2
    xc_2 = 13925.99903; 
    w_2 = 1215.92027;
    A_2 = 594.10984 ; 
    
    %Gauss Peak 3
    xc_3 = 14946.39934; 
    w_3 = 1878.77573;
    A_3 =  498.60822; 
    
    % Kumulativ
    pfr_form_pabphp = A_1* 1/(w_1*sqrt(pi/2)) *exp(-2*((x-xc_1).^2/w_1^2))+...
        A_2* 1/(w_2*sqrt(pi/2)) *exp(-2*((x-xc_2).^2/w_2^2))+...
        A_3* 1/(w_3*sqrt(pi/2)) *exp(-2*((x-xc_3).^2/w_3^2));
end

function pr_form_pabphp = Pr_PaBphP(x)
    % Gauss Peak 4
    xc_4 = 14172.47938;
    w_4 = 503.55919;
    A_4 = 349.27003;
    
    %Gauss Peak 5
    xc_5 = 14571.8087; 
    w_5 = 705.90241;
    A_5 = 392.47525 ; 
    
    %Gauss Peak 6
    xc_6 = 15208.3274; 
    w_6 = 2001.41033;
    A_6 = 687.06453 ;
    
    % Gauss Peak 7
    xc_7 = 15571.547;
    w_7 = 811.86681;
    A_7 = 121.09384;
    
    pr_form_pabphp = A_4* 1/(w_4*sqrt(pi/2)) *exp(-2*(x-xc_4).^2/w_4^2)+...
        A_5* 1/(w_5*sqrt(pi/2)) *exp(-2*(x-xc_5).^2/w_5^2)+...
        A_6* 1/(w_6*sqrt(pi/2)) *exp(-2*(x-xc_6).^2/w_6^2)+...
        A_7 * 1/(w_7*sqrt(pi/2)) * exp(-2*(x-xc_7).^2/w_7^2);
end


%% ##----- AGP2 D783N -----##

function pfr_form_agp2d783n = Pfr_Agp2D783N(x)

    % Gauss Pfr 1
    xc_1 = 12988.25745;
    w_1 = 565.18934;
    A_1 = 203.91208; 
    
    %Gauss PFr Peak 2
    xc_2 = 13296.51492;
    w_2 = 882.80331;
    A_2 = 597.67496 ;
    
    %Gauss Pfr Peak 3
    xc_3 = 14055.69517;
    w_3 =  1410.85467;
    A_3 =  837.16322;
    
    %Gauss Pfr Peak 4
    xc_4 = 15026.63465;
    w_4 =  2155.52339;
    A_4 =  513.2996;
    
    % Kumulativ
    pfr_form_agp2d783n = A_1* 1/(w_1*sqrt(pi/2)) *exp(-2*((x-xc_1).^2/w_1^2))...
        + A_2* 1/(w_2*sqrt(pi/2)) *exp(-2*((x-xc_2).^2/w_2^2))...
        + A_3* 1/(w_3*sqrt(pi/2)) *exp(-2*((x-xc_3).^2/w_3^2))...
        + A_4* 1/(w_4*sqrt(pi/2)) *exp(-2*((x-xc_4).^2/w_4^2));
end   

function pr_form_agp2d783n = Pr_Agp2D783N(x)

    %Gauss Peak 5
    xc_5 = 14163.54477;
    w_5 = 522.74163;
    A_5 = 407.33365;
    
    %Gauss Peak 6
    xc_6 = 17289.09106;
    w_6 = 1237.38907;
    A_6 = 55.67544;
    
    
    % Gauss Peak 7
    xc_7 = 14658.59218;
    w_7 = 481.39646;
    A_7 = 123.77761;
    
    
    % Gauss Peak 8
    xc_8 = 15037.11514;
    w_8 = 1967.56179 ;
    A_8 = 1228.46461 ;
    
    
    % Kumulativ Pr
    pr_form_agp2d783n = A_5* 1/(w_5*sqrt(pi/2)) *exp(-2*(x-xc_5).^2/w_5^2)...
        + A_6* 1/(w_6*sqrt(pi/2)) *exp(-2*(x-xc_6).^2/w_6^2)...
        + A_7 * 1/(w_7*sqrt(pi/2)) * exp(-2*(x-xc_7).^2/w_7^2)...
        +A_8 * 1/(w_8*sqrt(pi/2)) * exp(-2*(x-xc_8).^2/w_8^2);
end


%% ##----- AGP2 WT -----##

function pfr_form_agp2wt = Pfr_Agp2WT(x)
    xc_1 = 12955.50424 ;
    w_1 = 534.40928 ;
    A_1 = 176.77288 ;
    
    %Gauss Peak 2
    xc_2 = 13195.91162 ;
    w_2 = 785.66336 ;
    A_2 = 491.89424;
    
    %Gauss Peak 3
    xc_3 = 13935.7044;
    w_3 = 1388.60316;
    A_3 =  1214.67974;
    
    %Gauss Peak 4
    xc_4 = 15194.78976 ;
    w_4 =  1700.06786;
    A_4 =   528.53699 ;
    
    
    pfr_form_agp2wt =  A_1* 1/(w_1*sqrt(pi/2)) *exp(-2*((x-xc_1).^2/w_1^2))...
        + A_2* 1/(w_2*sqrt(pi/2)) *exp(-2*((x-xc_2).^2/w_2^2))...
        + A_3* 1/(w_3*sqrt(pi/2)) *exp(-2*((x-xc_3).^2/w_3^2))...
        + A_4* 1/(w_4*sqrt(pi/2)) *exp(-2*((x-xc_4).^2/w_4^2));
end

function pr_form_agp2wt = Pr_Agp2WT(x)
    %Gauss Peak 4
    xc_4 = 14059.2178;
    w_4 = 492.13348;
    A_4 = 233.60894;
    
    %Gauss Peak 5
    xc_5 = 14421.49686; 
    w_5 = 605.83151;
    A_5 = 253.63348 ; 
    
    %Gauss Peak 6
    xc_6 = 14859.4275; 
    w_6 = 1825.41627;
    A_6 = 1046.14258 ;
    
    % Gauss Peak 7
    xc_7 = 15770.91527;
    w_7 = 2689.56195;
    A_7 = 428.43656;
    
    pr_form_agp2wt =  A_4* 1/(w_4*sqrt(pi/2)) *exp(-2*(x-xc_4).^2/w_4^2)+...
        A_5* 1/(w_5*sqrt(pi/2)) *exp(-2*(x-xc_5).^2/w_5^2)+...
        A_6* 1/(w_6*sqrt(pi/2)) *exp(-2*(x-xc_6).^2/w_6^2)+...
        A_7 * 1/(w_7*sqrt(pi/2)) * exp(-2*(x-xc_7).^2/w_7^2);
end


%% ##----- XccBphP WT -----##

function pfr_form_xccwt = Pfr_XccWT(x)
    pfr_form_xccwt = 1.00744804100098 * Pfr_XccPAS9(x);
end

function pr_form_xccwt = Pr_XccWT(x)

    % Gauss Pr 1
    xc_1 = 14551.17355;
    w_1 = 642.41245;
    A_1 = 592.42636; 
    
    %Gauss Pr Peak 2
    xc_2 = 15082.37566;
    w_2 = 633.40134;
    A_2 = 232.34213 ;
    
    %Gauss Pr Peak 3
    xc_3 = 15783.05028;
    w_3 =  2492.9992;
    A_3 =  774.11447;
    
    %Gauss Pr Peak 4
    xc_4 = 15783.05028;
    w_4 =  1022.9565;
    A_4 =  289.55749;
    
    
    % Kumulativ
    pr_form_xccwt = A_1* 1/(w_1*sqrt(pi/2)) *exp(-2*((x-xc_1).^2/w_1^2))...
        + A_2* 1/(w_2*sqrt(pi/2)) *exp(-2*((x-xc_2).^2/w_2^2))...
        + A_3* 1/(w_3*sqrt(pi/2)) *exp(-2*((x-xc_3).^2/w_3^2))...
        + A_4* 1/(w_4*sqrt(pi/2)) *exp(-2*((x-xc_4).^2/w_4^2));
end   


%% ##----- XccBphP Delta PAS9-----##

function pfr_form_xccpas9 = Pfr_XccPAS9(x)
    % Gauss Pfr 1
    xc_1 = 13049.43187;
    w_1 = 738.73828;
    A_1 = 484.00847; 
    
    %Gauss PFr Peak 2
    xc_2 = 13615.62267;
    w_2 = 552.82491;
    A_2 = 82.41663 ;
    
    %Gauss Pfr Peak 3
    xc_3 = 14048.91023;
    w_3 =  1419.17955;
    A_3 =  713.08439;
    
    %Gauss Pfr Peak 4
    xc_4 = 15080.12118;
    w_4 =  2160.55058;
    A_4 =  423.6205;
    
    
    % Kumulativ
    pfr_form_xccpas9  = A_1* 1/(w_1*sqrt(pi/2)) *exp(-2*((x-xc_1).^2/w_1^2))...
        + A_2* 1/(w_2*sqrt(pi/2)) *exp(-2*((x-xc_2).^2/w_2^2))...
        + A_3* 1/(w_3*sqrt(pi/2)) *exp(-2*((x-xc_3).^2/w_3^2))...
        + A_4* 1/(w_4*sqrt(pi/2)) *exp(-2*((x-xc_4).^2/w_4^2));
end

function pr_form_xccpas9 = Pr_XccPAS9(x)

    % Gauss Pr 1
    xc_1 = 14573.79812;
    w_1 = 660.45029;
    A_1 = 661.36729; 
    
    %Gauss Pr Peak 2
    xc_2 = 15129.83125;
    w_2 = 539.48058;
    A_2 = 137.404 ;
    
    %Gauss Pr Peak 3
    xc_3 = 15692.31295;
    w_3 =  1123.73531;
    A_3 =  377.88775;
    
    %Gauss Pr Peak 4
    xc_4 = 15897.45741;
    w_4 = 2452.6658;
    A_4 =  689.94648;
    
    % Kumulativ
    pr_form_xccpas9 = A_1* 1/(w_1*sqrt(pi/2)) *exp(-2*((x-xc_1).^2/w_1^2))...
        + A_2* 1/(w_2*sqrt(pi/2)) *exp(-2*((x-xc_2).^2/w_2^2))...
        + A_3* 1/(w_3*sqrt(pi/2)) *exp(-2*((x-xc_3).^2/w_3^2))...
        + A_4* 1/(w_4*sqrt(pi/2)) *exp(-2*((x-xc_4).^2/w_4^2));
end


%% ##----- RtBphP2 WT -----##

function pr_form_rtbphp2 = Pr_RtP2(x)
    %Gauss Pr 1: Beschreibt Pfr-Restschulter --> excluded
        %xc_1 = 13104.36136;
        %w_1 = 307.57571;
        %A_1 = 28.74551;
    %Gauss Pr 2
        xc_2 = 14398.46589;
        w_2 = 971.28231;
        A_2 = 743.76987;
    %Gauss Pr 3: Beschreibt unphysikalische Schulter in Pr-Form --> excluded    
        %xc_3 = 15259.25115;
        %w_3 =  213.11516;
        %A_3 =  14.4709;
    %Gauss Pr 4
        xc_4 = 15498.11034;
        w_4 =  2453.11992;
        A_4 =  1719.95602;
    
    
    pr_form_rtbphp2 = A_2* 1/(w_2*sqrt(pi/2)) *exp(-2*((x-xc_2).^2/w_2^2))...
        + A_4* 1/(w_4*sqrt(pi/2)) *exp(-2*((x-xc_4).^2/w_4^2));

end

function pfr_form_rtbphp2 = Pfr_RtP2(x)
    %Gauss Pfr 1
        xc_1 = 13008.75417;
        w_1 = 537.5159;
        A_1 = 677.34995;
    % Gauss Pfr 2
        xc_2 = 13396.44025;
        w_2 = 889.87543;
        A_2 = 2059.24628; 
    %Gauss Pfr 3
        xc_3 = 14299.92962;
        w_3 = 907.92948;
        A_3 = 734.87712 ;
    % Gauss Pfr 4
        xc_4 = 14676.74641 ;
        w_4 = 1935.99218 ;
        A_4 = 2021.15567 ;
    
    % Kumulativ
    pfr_form_rtbphp2 = A_1* 1/(w_1*sqrt(pi/2)) *exp(-2*((x-xc_1).^2/w_1^2))...
        + A_2* 1/(w_2*sqrt(pi/2)) *exp(-2*((x-xc_2).^2/w_2^2))...
        + A_3* 1/(w_3*sqrt(pi/2)) *exp(-2*((x-xc_3).^2/w_3^2))...
        + A_4* 1/(w_4*sqrt(pi/2)) *exp(-2*((x-xc_4).^2/w_4^2));
end


%% ##----- AvBphP2 WT -----##

function pfr_form_avp2 = Pfr_Avp2(x)
    % Gauss Peak 1
    xc_1 = 13132.63538; 
    w_1 = 755.81244;
    A_1 = 421.32014; 
    
    %Gauss Peak 2
    xc_2 = 14193.87628; 
    w_2 = 1090.30335;
    A_2 = 659.57455; 
    
    %Gauss Peak 3
    xc_3 = 15154.50441 ; 
    w_3 = 1962.98047 ;
    A_3 =  740.86894 ; 
    
    % Kumulativ
    pfr_form_avp2 = A_1* 1/(w_1*sqrt(pi/2)) *exp(-2*((x-xc_1).^2/w_1^2))+...
        A_2* 1/(w_2*sqrt(pi/2)) *exp(-2*((x-xc_2).^2/w_2^2))+...
        A_3* 1/(w_3*sqrt(pi/2)) *exp(-2*((x-xc_3).^2/w_3^2));
end

function pr_form_avp2 = Pr_Avp2(x)
    
    %Gauss Peak 1
    xc_1 = 14139.24174 ;
    w_1 = 486.67749  ;
    A_1 = 244.85137  ;
    
    %Gauss Peak 2
    xc_2 = 14490.26628 ;
    w_2 = 736.55412 ;
    A_2 = 411.14123 ;
    
    %Gauss Peak 3
    xc_3 = 15225.54418 ;
    w_3 = 1872.3756 ;
    A_3 =  1098.27334 ;
       
    % Kumulativ
    pr_form_avp2 = A_1* 1/(w_1*sqrt(pi/2)) *exp(-2*((x-xc_1).^2/w_1^2))+...
        A_2* 1/(w_2*sqrt(pi/2)) *exp(-2*((x-xc_2).^2/w_2^2))+...
        A_3* 1/(w_3*sqrt(pi/2)) *exp(-2*((x-xc_3).^2/w_3^2));

end




%%          ##----- KANONISCH -----##

%% ##----- AGP2 WT -----##

function pfr_form_agp1 = Pfr_Agp1(x)
    pfr_form_agp1 =  0.82164*Pfr_PaBphP(x);

end

function pr_form_agp1 = Pr_Agp1(x)
    %Gauss Peak 4
    xc_4 = 14172.47938;
    w_4 = 503.55919;
    A_4 = 349.27003;

    
    %Gauss Peak 5
    xc_5 = 14571.8087; 
    w_5 = 705.90241;
    A_5 = 392.47525 ; 
    
    %Gauss Peak 6
    xc_6 = 15208.3274; 
    w_6 = 2001.41033;
    A_6 = 687.06453 ;
    
    % Gauss Peak 7
    xc_7 = 15571.547;
    w_7 = 811.86681;
    A_7 = 121.09384;
    
    pr_form_agp1 =  A_4* 1/(w_4*sqrt(pi/2)) *exp(-2*(x-xc_4).^2/w_4^2)+...
        A_5* 1/(w_5*sqrt(pi/2)) *exp(-2*(x-xc_5).^2/w_5^2)+...
        A_6* 1/(w_6*sqrt(pi/2)) *exp(-2*(x-xc_6).^2/w_6^2)+...
        A_7 * 1/(w_7*sqrt(pi/2)) * exp(-2*(x-xc_7).^2/w_7^2);
end

%%  ##----- PstBphP1 -----##

function pfr_form_pstp1 = Pfr_PstP1(x)
    
    %Gauss Pfr 1
        xc_1 = 13212.55228;
        w_1 = 759.23314;
        A_1 = 264.59842;
    % Gauss Pfr 2
        xc_2 = 14155.94732;
        w_2 = 746.08639;
        A_2 = 442.12956; 
    %Gauss Pfr 3
        xc_3 = 14807.10947;
        w_3 = 452.84609;
        A_3 = 31.15871 ;
    % Gauss Pfr 4
        xc_4 = 15078.32415 ;
        w_4 = 1530.43409 ;
        A_4 = 466.23452 ;
    
    % Kumulativ
    pfr_form_pstp1 = A_1* 1/(w_1*sqrt(pi/2)) *exp(-2*((x-xc_1).^2/w_1^2))...
        + A_2* 1/(w_2*sqrt(pi/2)) *exp(-2*((x-xc_2).^2/w_2^2))...
        + A_3* 1/(w_3*sqrt(pi/2)) *exp(-2*((x-xc_3).^2/w_3^2))...
        + A_4* 1/(w_4*sqrt(pi/2)) *exp(-2*((x-xc_4).^2/w_4^2));
end

function pr_form_pstp1 = Pr_PstP1(x)
    
    %Gauss Pfr 1
        xc_1 = 14115.36422;
        w_1 = 506.50787;
        A_1 = 280.86539;
    % Gauss Pfr 2
        xc_2 = 14451.64692;
        w_2 = 842.7909;
        A_2 = 702.48009; 
    %Gauss Pfr 3
        xc_3 = 15477.3026;
        w_3 = 1061.43732;
        A_3 = 464.78392 ;
    % Gauss Pfr 4
        xc_4 =  16585.35602 ;
        w_4 = 1154.92869 ;
        A_4 = 84.37288 ;
    
    % Kumulativ
    pr_form_pstp1 = A_1* 1/(w_1*sqrt(pi/2)) *exp(-2*((x-xc_1).^2/w_1^2))...
        + A_2* 1/(w_2*sqrt(pi/2)) *exp(-2*((x-xc_2).^2/w_2^2))...
        + A_3* 1/(w_3*sqrt(pi/2)) *exp(-2*((x-xc_3).^2/w_3^2))...
        + A_4* 1/(w_4*sqrt(pi/2)) *exp(-2*((x-xc_4).^2/w_4^2));
end

%%               ##----- ERROR PROPAGATION (1: LINEAR) -----##
function alpha_partial_pfr = Dalpha_DPfr(x)

%alpha_partial_pfr = abs((1./((Pfr_PaBphP(x) -Pr_PaBphP(x)).^2)).* (y./j - Pr_PaBphP(x))).* 0.08;
alpha_partial_pfr = (Pr_PaBphP(x)./(Pfr_PaBphP(x) + Pr_PaBphP(x)).^2) *0.08 ;
end

function alpha_partial_pr = Dalpha_DPr(x)
alpha_partial_pr = (-Pfr_PaBphP(x)./(Pfr_PaBphP(x) + Pr_PaBphP(x)).^2) *0.08;
end