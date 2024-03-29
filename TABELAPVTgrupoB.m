clearvars;clc; clear;
%% Dados do enunciado
pb=2000;%psi
dg=0.8;
T=80; %farenheit
API=37.9;%grau
n=20;
do=0.9;
pmin=100; %psi
pmax=3200; %psi
p=linspace(pmin,pmax,n)'; %Faixa de pressões

for i=1:n
    if p(i) < pb
        p_sat(i) = p(i);
        P_SAT=[p_sat]'; %Pressões da região saturada para gráficos da fase gás
    end
end
       
%% PROPRIEDADES FASE GÁS

% Peso Molecular do Gás (Mg)
Mar=29;
M_g=Mar*dg; 

% Propriedades Pseudocríticas
if dg<0.75
    Ppc=677+(15.0*dg)-(37.5*(dg^2)); %Ppc em psi
    Tpc=168+(325*dg)-(12.5*(dg^2)); %Tpc em Rankine
else
    Ppc=706-(51.7*dg)-(11.1*(dg^2));
    Tpc=187+(330*dg)-(71.5*(dg^2));
end

% Propriedades Pseudoreduzidas
for i=1:n
    Ppr(i)=p(i)/Ppc;
    PPR=[Ppr]';
end

TPR=(T+459.67)/Tpc;

% Temperatura e Pressão - Standard
Psc=14.7; %psi
Tsc=60; %Fahrenheit

% Constante dos Gases Reais
R=10.73; % T em Rankine

% Correlação de Lee et al (1966) - Viscosidade do Gás
xv=3.448+(986.4/(T+459.67))+(0.01009*M_g);
yv=2.4-(0.2*xv);
kv=(((9.379+0.0160*M_g)*((T+459.67)^1.5))/(209.2+(19.26*M_g)+(T+459.67)));

for i=1:n
    if p(i) < pb
        %Região Saturada 
        
        % 1) Z - Fator de Compressibilidade Isotérmico - Correlação do Papay (1985)
        z(i)=1-((3.53*PPR(i))/(10^(0.9813*TPR)))+((0.274*(PPR(i)^2))/(10^(0.8157*TPR)));
        Z=[z]';
        Z_SAT=[z]';
    
        % 2) Bg - Fator Volume-Formação do Gás
        Bg(i)=(Psc/Tsc)*((Z(i)*T)/p(i));
        BG=[Bg]';
        BG_SAT=[Bg]';
    
        % 3) Pg - Massa Específica do Gás
        Pg(i)=(p(i)*M_g)/(Z(i)*R*(T+459.67));
        PG=[Pg]';
        PG_SAT=[Pg]';
        
        % 4) Mg - Viscosidade do Gás - Correlação de Lee et al (1966)
        Mg(i)=(10^(-4))*kv*exp(xv*((PG(i)/62.4)^yv));
        MG=[Mg]';
        MG_SAT=[Mg]';
    
        % 5) Cg - Compressibilidade do Gás
        Cg(i)=(1/PPR(i))-((1/Z(i))*((-3.53/(10^(0.9813*TPR)))+(0.548*PPR(i)/(10^(0.8157*TPR)))));
        CG=[Cg]';
        CG_SAT=[Cg]';
    else 
        %Região Subsaturada   
        
        z(i)=0;
        Z=[z]';
    
        Bg(i)=0;
        BG=[Bg]';
    
        Pg(i)=0;
        PG=[Pg]';
    
        Mg(i)=0;
        MG=[Mg]';
    
        Cg(i)=0;
        CG=[Cg]';
    end
end

%Gráficos da Fase Gás
% 
% figure (1)
% plot(P_SAT,Z_SAT,'LineWidth',2);
% xlabel('Pressão [psi]');
% ylabel('Fator de Compressibilidade Isotérmico');
% title('Gráfico Pressão versus Z');
% 
% figure (2)
% plot(P_SAT,BG_SAT,'LineWidth',2);
% xlabel('Pressão [psi]');
% ylabel('Fator Volume-Formação do Gás [ft^3/SCF]');
% title('Gráfico Pressão versus Bg');
% 
% figure (3)
% plot(P_SAT,PG_SAT,'LineWidth',2);
% xlabel('Pressão [psi]');
% ylabel('Massa Específica do Gás [lb/ft^3]');
% title('Gráfico Pressão versus Pg');
% 
% figure (4)
% plot(P_SAT,MG_SAT,'LineWidth',2);
% xlabel('Pressão [psi]');
% ylabel('Viscosidade do Gás [cP]');
% title('Gráfico Pressão versus Mg');
% 
% figure (5)
% plot(P_SAT,CG_SAT,'LineWidth',2);
% xlabel('Pressão [psi]');
% ylabel('Compressibilidade do Gás [psi^(-1)]');
% title('Gráfico Pressão versus Cg');
%% PROPRIEDADES FASE ÓLEO
 
% Razão de solubilidade do Óleo - Correlação de Glaso
for i = 1:n
    if p(i) > pb %Rs calculado em P=Pb (após atingir a pb, a RS se mantém constante!)
    a = 2.8869 - (14.1811 - 3.3093 * (log10(pb)))^0.5; %parâmetro p Rs
    Rs(i)= dg * ((((API^0.989)/(T^0.172))*10^a)^1.2255);
    else
    b = 2.8869 - (14.1811 - 3.3093 * (log10(p(i))))^0.5;
    Rs(i)= dg * ((((API^0.989)/(T^0.172))*10^b)^1.2255);
    end
    RS=[Rs]';
end

%Razão Solubilidade na Pressão de Bolha (Rsb)
d = 2.8869 - (14.1811 - 3.3093 * (log10(pb)))^0.5; 
Rsb= dg * ((((API^0.989)/(T^0.172))*10^d)^1.2255);

%Compressibilidade- Subsaturado - Correlação de Petrosky e Farshad
for i = 1:n
    if p(i) >= pb
       Co_sub(i)= 1.705e-7 * (Rsb^0.69357) * (dg^0.1885) * (API^0.3272) * (T^0.6729) * (p(i)^(-0.5906));
    else
       Co_sub(i) = 0;
    end
    CO_SUB=[Co_sub]';
end
 
%Bo Saturado
for i=1:n
    Bob(i) = Rs(i) * ((dg/do)^0.526)+ 0.986*T; %parâmetro para Bo
    if p(i) <= pb
        Bo_sat(i)=  1 + 10^(-6.58511+2.91329*log10(Bob(i))-0.27683*((log10(Bob(i)))^2));
    else
        Bo_sat(i)=0;
    end
    BO_SAT=[Bo_sat]';
end

%Fator volume-formação do Óleo-  Subsaturado - Correlação de Glaso
B = Rsb * ((dg/do)^0.526)+ 0.986*T;
Bo_bolha=  1 + 10^(-6.58511+2.91329*log10(B)-0.27683*((log10(B))^2));
for i=1:n
    if p(i) > pb
        Bo_sub(i)= Bo_bolha*exp(-CO_SUB(i)*(p(i)-pb));
    else
        Bo_sub(i)=0;
    end
    BO_SUB=[Bo_sub]';
end

BO=[BO_SAT + BO_SUB]; %Fator Volume Formação do Óleo
  
%Compressibilidade- Saturado - Correlação de Petrosky e Farshad
for i=1:n
    if p(i) < pb
        dc_dP(i)=(-0.5) * (14.1811 - 3.3093 * ((log10(p(i)))^(-0.5)) * (-3.3093/(p(i)*log(10))));
        c(i) = 2.8869 - ((14.1811 - 3.3093 * (log10(p(i))))^0.5);
        dRs_dP(i) = (1.255*dg * (((API^0.989)/(T^0.172)) *10^c(i))^0.2255) * (dc_dP(i)*(10^c(i))*log(10)*((API^0.989)/(T^0.172)));
        dBob_dP(i)= dRs_dP(i) * ((dg/do)^0.526);
        bob(i)=Rs(i) * ((dg/do)^0.526)+ 0.986*T;
        daa_dP(i) = (dBob_dP(i) * (1/bob(i))*log10(exp(1)))*(2.91329-(0.55366*log10(bob(i))));
        aa(i)=(-6.58511)+(2.91329*(log10(bob(i))))-(0.27683*((log10(bob(i)))^2));
        dBo_dP(i) = daa_dP(i)*10^aa(i)*log(10);
        Co_sat(i)= -((1/BO_SAT(i))*dBo_dP(i)) + (Bg(i)/BO_SAT(i))*dRs_dP(i);
    else
        Co_sat(i)=0;
    end
    CO_SAT=[Co_sat]';
end

CO=[CO_SAT + CO_SUB]; %Compressibilidade do Óleo
  
%Viscosidade - Correlação de Bergman
X = 1*exp(22.33 - 0.194*API + 0.00033 * API^2 - (3.2-0.0185*API)*log(T+310));
mi_od= 1*exp(X) -1; %Viscosidade de Óleo Morto

  for i = 1:n
    if p(i) < pb
      X = exp(22.33 - 0.194*API + 0.00033 * API^2 - (3.2-0.0185*API)*log( T +310));
      miod = exp(X) - 1;
      a = exp(4.768-0.8359*log(Rs(i)+300));
      b = 0.555 + 133.55/(Rs(i) + 300);
      mio(i) = a * miod^(b);
    else
      X = exp(22.33 - 0.194*API + 0.00033 * API^2 - (3.2-0.0185*API)*log(T +310));
      miod = exp(X) - 1;
      a = exp(4.768-0.8359*log(Rsb+300));
      b = 0.555 + 133.55/(Rsb + 300);
      miob = a * miod^(b);
      alpha = 6.5698e-7*log(miob^2)-1.48211e-5*log(miob)+2.27877e-4;
      beta = 2.324623e-2*log(miob) + 0.8973204;
      mio(i) = miob * exp(alpha*(p(i)-pb)^beta);
    end
  end
  
 [Mi_OLEO]= [mio]';
%  
%  %Gráficos da fase óleo
% figure (6)
% plot(p,RS,'LineWidth',2);
% xlabel('Pressão [psi]');
% ylabel('Razão Solubilidade do Óleo [SCF/STB]');
% title('Gráfico Pressão versus Rs');
% 
% figure (7)
% plot(p,BO,'LineWidth',2);
% xlabel('Pressão [psi]');
% ylabel('Fator Volume-Formação do Óleo [bbl/STB]');
% title('Gráfico Pressão versus Bo');
% 
% figure (8)
% plot(p,CO,'LineWidth',2);
% xlabel('Pressão [psi]');
% ylabel('Compressibilidade do Óleo [psia^(-1)');
% title('Gráfico Pressão versus Co');
% 
% figure (9)
% plot(p,Mi_OLEO,'LineWidth',2);
% xlabel('Pressão [psi]');
% ylabel('Viscosidade do Óleo [cP]');
% title('Gráfico Pressão versus Mo');


%Gerador de tabela PVT
x= table(p,RS,BO,CO,Mi_OLEO,BG,Z,MG,PG, CG, 'VariableNames',{'P (psi)','RSo (SCF/STB)','Bo (bbl/STB)','Co (psia⁻¹)','Mi_óleo (cp)','Bg (m³/m³std)','factor Z','Mi_gás (cp)','Massa específica do gás (kg/m³)','Cg (psia⁻¹)'})


