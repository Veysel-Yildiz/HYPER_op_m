
function [OF, power,  AAE] = calc_hpp1( x , HP , O , nt, On)

% Unpack the parameter values
D = x(1); Od = x(2);

% Calculate the relative roughness: epsilon / diameter.
ed = HP.e / D;

% design head ------------------------------------------

% Calculate the Reynolds number for design head
Re_d = 4 * Od / ( pi * D * HP.v );

% Find f, the friction factor [-] for design head
f_d = moody (ed , Re_d );

% Claculate flow velocity in the pipe for design head
V_d = 4 * Od / ( pi * D^2 );

if V_d > 9 || V_d < 2.5
    penalty = -1999999 * V_d;
    OF = penalty ;
    power = penalty;
    AAE = penalty;
    return
end

%%
switch nt
    case 2 % Francis turbine
        kmin = HP.mf;
        var_name_cavitation = HP.nf; % specific speed range
        func_Eff = HP.eff_francis;
    case 3 % Pelton turbine
        kmin = HP.mp;
        var_name_cavitation = HP.np; % specific speed range
        func_Eff = HP.eff_pelton;
    otherwise
        kmin = HP.mk;
        var_name_cavitation = HP.nk; % specific speed range
        func_Eff = HP.eff_kaplan;
end

hf_d = f_d*(HP.L/D)*V_d^2/(2*HP.g)*1.1; % 10% of local losses
%     hl_d = HP.K_sum*V_d^2/(2*HP.g);

HP.hd = HP.hg - hf_d;
power  = HP.hd * HP.g  * Od;
HP.power = power;
HP.qd   = Od;

%%
% Now calculate the cavitation costs , suction heads and speeds of turbines

ss_L = 3000/60 * sqrt(Od)/(HP.g*HP.hd)^0.75;
ss_S = 214/60 * sqrt(Od)/(HP.g*HP.hd )^0.75;

if var_name_cavitation(2) <= ss_S  || ss_L <= var_name_cavitation(1)
    
    penalty = -299999;
    OF = penalty ;
    power = penalty;
    AAE = penalty;
    return
    
end

perc = HP.perc;
L = HP.L;
ve = HP.v;
hg = HP.hg;
ng = HP.ng;

% Calculate q as the minimum of O and Od
q = min(O, Od);

% Interpolate values from func_Eff based on qt/Od ratio
n = interp1(perc, func_Eff, q ./ Od);

% Set qt and nrc to zero where qt is less than kmin * Od
idx = q < kmin * Od;
%     q(idx) = 0;
n(idx) = 0;

Re = 4 * q ./ (pi * D * ve);  % Calculate the Reynolds number
f = moody(ed, Re);            % Find f, the friction factor [-]
V = 4 * q ./ (pi * D^2);      % Claculate flow velocity in the pipe
hnet = hg - f .* (L ./ D) .* V.^2 ./ 19.62.* 1.1; % Calculate the head loss due to friction in the penstock
P = hnet .* q .* 9.81 .* n .* ng;

% Determine the total costs and profit of operation
% costP = cost_hpp ( HP ,D , Od , 0 , 0 , nt, On );
costP = cost_hpp_opt ( HP ,D , nt, On);

% Unpack costs
cost_em = costP(1); cost_pen = costP(2);  cost_ph = costP(4); %tp = costP(3);
cost_cw = HP.cf * (cost_pen + cost_em ); % (in dollars) civil + open channel + Tunnel cost

%%
% Determine total cost (with cavitation)
Cost_other = cost_pen + cost_ph + cost_cw;

T_cost = cost_em * (1+ HP.tf) + Cost_other + HP.fxc;

cost_OP = cost_em * HP.om; % operation and maintenance cost

AAE = mean(P) * HP.hr/10^6; % Calculate average annual energy

AR = AAE* HP.ep*0.96; % AnualRevenue in M dollars 5% will not be sold

AC = HP.CRF * T_cost + cost_OP; % Anual cost in M dollars
% 
% NPV = AR - AC;
% BC = AR/AC;

if HP.Objective == 1
    OF = AR - AC;
    
elseif HP.Objective == 2
    OF = AR / AC;
end

