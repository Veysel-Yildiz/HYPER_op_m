function [ cost ] = cost_hpp_opt( HP ,D , nt, On )


% Thickness of the pipe  [m]
tp  = 8.4/1000*D + 0.002;

% % % tp1 = (1.2 * HP.hd * D / ( 20* 1.1) +2)*0.1; % t = (head + water hammer head (20%))*D / The working stress of the steel * 2
% % % tp2 = (D + 0.8) / 4; % min thickness in cm
% % %
% % % tp = max(tp1, tp2)/100;% min thickness in m

cost_pen = pi * tp * D * HP.L * 7.874 * HP.pt/10^6;

% % Calculate the cost of power house (in M dollars)
cost_ph = 200 * (HP.power/1000)^-0.301  * HP.power/10^6;

% Switch among the different turbine combinations

if nt == 2 % Francis turbine cost
    cost_em = 2.927 * (HP.power/1000)^1.174 *(HP.hd)^-0.4933*1.1 * (1 + (On-1)*(On-2)*0.03) ; % in $
    
elseif nt == 3 % pelton turbine cost
    
    cost_em = 1.984 * (HP.power/1000)^1.427 *(HP.hd)^-0.4808*1.1* (1 + (On-1)*(On-2)*0.03) ; % in $
    
else % Kaplan turbine cost
    
    cost_em = 2.76 * (HP.power/1000)^0.5774 *(HP.hd)^-0.1193*1.1 * (1 + (On-1)*(On-2)*0.03) ; % in $
    
end

cost = [ cost_em , cost_pen, tp, cost_ph ];


