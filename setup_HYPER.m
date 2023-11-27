%% main
function [ output ] = setup_HYPER ( HP, DE, Q, EffCurves )


%%
HP.maxT = length(Q(:,1));   % the size of time steps
HP.e = 0.45*10^(-4);        % epsilon (m) ; fiberglass e = 5*10^(-6) (m), concrete e = 1.8*10^(-4) (m)
HP.v = 1.004*10^(-6);       % the kinematics viscosity of water (m2/s)
HP.g = 9.81;                % acceleration of gravity (m/s2)
HP.ng = 0.98;               % generator-system efficiency
HP.hr = 8760;               % total hours in a year
HP.nf = [0.05 0.33];        % specific spped range of francis turbine
HP.nk = [0.19 1.55];        % specific spped range of kaplan turbine
HP.np = [0.005 0.0612];     % specific spped range of pelton turbine
HP.mf = 0.40;               % min francis turbine design flow rate
HP.mk = 0.20;               % min kaplan turbine design flow rate
HP.mp = 0.11;               % min pelton turbine design flow rate

%% Define variables and interpolation function for calculation of turbines efficiencies

HP.perc = EffCurves(:,1);
% Kaplan turbine efficiency
HP.eff_kaplan = EffCurves(:,2);

% Francis turbine efficiency
HP.eff_francis = EffCurves(:,3);

% Pelton turbine efficiency
HP.eff_pelton = EffCurves(:,4);

%%

HP.CRF = HP.i*(1+HP.i)^HP.N/((1+HP.i)^HP.N-1); % capital recovery factor
HP.tf  = 1 / ( 1 + HP.i)^25;

%%%

% % % % % % STRUCTURE OF VARIABLES FOR DIFFERENTIAL EVOLUTION % % % % % % %

DE.d = 3 + HP.maxturbine;                % number of parameteters

[ti, tj] = select_turbine (HP);

min_turbineflow = DE.minQ*ones(1,HP.maxturbine);
max_turbineflow = DE.maxQ*ones(1,HP.maxturbine);

DE.min = [DE.minD min_turbineflow ti 1.501];  % If 'latin', min values
DE.max = [DE.maxD max_turbineflow tj HP.maxturbine + 0.499];   % If 'latin', max values

DE.F = @(x) normrnd(0.7,0.5);% Define reproduction value -> stochastic with mean 0.5 and std of 0.2
DE.CR = 0.7;                 % Define crossover ratio

clear i  ti tj


% Now create for each parent a vector with other parents it can use for reproduction
for i = 1:DE.N, DE.R(i,1:DE.N-1) = setdiff(1:DE.N,i); end

% % % Run script with DE and return the final population (maximizing profit!)
% % [fx , fy , x , AAE, costex, Sspeed] = DE_hpp ( DE , HP , Q, Hel);
[fx , fy , x , AAE, Cem, Ct] = DE_hpp ( DE , HP , Q);

output = [fx fy AAE Cem Ct x];