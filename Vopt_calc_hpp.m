 function [OF, power,  AAE] = Vopt_calc_hpp ( x , HP , O , nt, On)
% function [NPV, BC] = Vopt_calc_hpp ( x , HP , O , nt, On )
% Unpack the parameter values
% Unpack the parameter values
D = x(1);

maxturbine = On;

% Handle the opscheme and turbine assignments
opscheme = HP.opscheme; % 1 = 1 small + identical, 2 = all identical, 3 = all varied

% Assign values based on the maximum number of turbines
Qturbine = zeros(On,1);

for i = 1:maxturbine
    if opscheme == 1
        Od = (i == 1) * x(2) + (i > 1) * x(3);
    elseif opscheme == 2
        Od =  x(2);
    else
        Od = x(i + 1);
    end
    
    Qturbine(i) = Od;
end

Od1 = Qturbine(1);
Od2 = Qturbine(2);

Q_design = sum(Qturbine); % find design discharge
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

%%

% Calculate the relative roughness: epsilon / diameter.
ed = HP.e / D;

% Calculate the Reynolds number for design head
Re_d = 4 * (Q_design) / ( pi * D * HP.v );

% Find f, the friction factor [-] for design head
f_d = moody ( ed , Re_d );

% Claculate flow velocity in the pipe for design head
V_d = 4 * (Q_design)  / ( pi * D^2 );


if V_d > 9 || V_d < 2.5
    penalty = -1999999 * V_d;
    OF = penalty ;
    power = penalty;
    AAE = penalty;
    return
end


% head losses
hf_d = f_d*(HP.L/D)*V_d^2/(2*HP.g)*1.1;

HP.hd = HP.hg  - hf_d;
HP.qd = Q_design;

power =  HP.hd * HP.g * Q_design;

HP.power = power;

%%
% Now calculate the cavitation costs , suction heads and speeds of turbines

% Calculate ss_L and ss_S for Od1
ss_L1 = 50 * sqrt(Od1) / (HP.g * HP.hd)^0.75; % 50 = 3000/60
ss_S1 = 3.56667 * sqrt(Od1) / (HP.g * HP.hd)^0.75; % 3.56667  = 214/60

% Calculate ss_L and ss_S for Od2
ss_L2 = 50 * sqrt(Od2) / (HP.g * HP.hd)^0.75;
ss_S2 = 3.56667 * sqrt(Od2) / (HP.g * HP.hd)^0.75;

% Check both conditions using a single if statement
if (var_name_cavitation(2) <= ss_S1 || ss_L1 <= var_name_cavitation(1)) || ...
        (var_name_cavitation(2) <= ss_S2 || ss_L2 <= var_name_cavitation(1))
    
    penalty = -299999;
    OF = penalty ;
    power = penalty;
    AAE = penalty;
    return
end

%
perc = HP.perc;
L = HP.L;
ve = HP.v;
hg = HP.hg;
% ng = HP.ng;

%
nsize = size(O,1);
Ns = 1000;

if nsize <= 500
    
    %     rowCount = nsize;
    %     q_inc = O';
    
%     DP = zeros(Ns,nsize);
    
    nr = rand(Ns, On, nsize); % Generate all random values at once
    
    %     nr = nr(:, :, :) ./ sum(nr(:, :, :), 2);% Normalize so the sum is 1
    nr = bsxfun(@rdivide, nr, sum(nr, 2)); % Normalize so the sum is 1
    
    % Perform the operations on all columns of nr simultaneously
    
    q = zeros(Ns, nsize);
    nP = zeros(Ns, nsize);
    
    for i = 1:On
        [qi, nPi, ~] = Voperation_OPT(nr(:, i, :), Qturbine(i), O', kmin, perc, func_Eff);
%       [qi, nPi, nr(:, i, :)] = Voperation_OPT(nr(:, i, :), Qturbine(i), O', kmin, perc, func_Eff);
        q = qi + q;
        nP = nPi + nP;
    end
    
    Re = 4 * q ./ (pi * D * ve);  % Calculate the Reynolds number
%     f = moody(ed, Re);            % Find f, the friction factor [-]
%     V = 4 * q ./ (pi * D^2);      % Claculate flow velocity in the pipe
%     hnet = hg - f .* (L ./ D) .* V.^2 ./ 21.582; % = 19.62.* 1.1 % Calculate the head loss due to friction in the penstock
%     DP(q > 0) = nP(q > 0) .* hnet(q > 0) .* 9.6138; % = 9.81 .* ng;
%     
    hnet = hg - moody(ed, Re) .* (L ./ D) .* (4 * q ./ (pi * D^2)).^2 ./ 19.62.* 1.1;  % = 19.62.* 1.1 % Calculate the head loss due to friction in the penstock
    DP = nP .* hnet .* 9.6138; % = 9.81 .* ng;
    
    % Calculate the maximum values and AAE
    [~, id] = max(DP);
    %     TablePower = DP(sub2ind(size(DP), id, 1:nsize));
    %     AAE = mean(TablePower) * HP.hr/10^6; % Gwh Calculate average annual energy
    AAE = mean(DP(sub2ind(size(DP), id, 1:nsize))) * 0.008760; % HP.hr / 10^6; % GWh
    
else
    
%     minflow = kmin * Od1;
    minflow = kmin * min(Od1,Od2);

    rowCount = 1000;
    s = linspace (minflow, Q_design, rowCount);
    
    % no = 2^On -1; % number of operational mode
    % Trb_wghs = zeros(Ns,On);
    % DP = zeros(Ns,rowCount);
    
    q_inc = s(1:rowCount);
    
    nr = rand(Ns, On, rowCount); % Generate all random values at once
    nr = bsxfun(@rdivide, nr, sum(nr, 2)); % Normalize so the sum is 1
    
    
    q = zeros(Ns, rowCount);
    nP = zeros(Ns, rowCount);
    
    for i = 1:On
        [qi, nPi, ~] = Voperation_OPT(nr(:, i, :), Qturbine(i), q_inc, kmin, perc, func_Eff);
        q = qi + q;
        nP = nPi + nP;
    end
    
    Re = 4 * q ./ (pi * D * ve);  % Calculate the Reynolds number
%     f = moody(ed, Re);            % Find f, the friction factor [-]
%     V = 4 * q ./ (pi * D^2);      % Claculate flow velocity in the pipe
%     hnet = hg - f .* (L ./ D) .* V.^2 ./ 19.62.* 1.1; % Calculate the head loss due to friction in the penstock
%     DP(q > 0) = nP(q > 0) .* hnet(q > 0) .* 9.81 .* ng;
    
    hnet = hg - moody(ed, Re) .* (L ./ D) .* (4 * q ./ (pi * D^2)).^2 ./ 19.62.* 1.1;  % = 19.62.* 1.1 % Calculate the head loss due to friction in the penstock
    DP = nP .* hnet .* 9.6138; % = 9.81 .* ng;
    
    [~, id] = max(DP);
    %     id = id(1);
    Ptable = [q_inc', DP(sub2ind(size(DP), id, 1:rowCount))'];
    
    %operating_mode = NaN(rowCount,On); % turbine weights
    %         for i = 1:rowCount
    %             operating_mode(i,:) = nr(id(i),:,i);
    %         end
    
    %%
    TableFlow = Ptable(:,1);
    TablePower = Ptable(:,2);
    
    % Pre-allocate output variables
    % [P] =  deal (NaN(HP.maxT,1));
    P = zeros(HP.maxT, 1);
    
    % Calculate sum of Od1 and Od2
    qw = min(O, Q_design);
    
    % Find the indices corresponding to qw < minflow
    % shutDownIndices = find(qw < minflow);
    
    % Find the indices corresponding to qw >= minflow
    activeIndices = find(qw >= minflow);
    
    % Calculate pairwise distances between qw(activeIndices) and TableFlow
    distances = pdist2(qw(activeIndices), TableFlow);
    
    % Find the indices of TableFlow closest to qw for active turbines
    [~, indices] = min(distances, [], 2);
    
    % Assign TablePower values to active turbines based on the indices
    P(activeIndices) = TablePower(indices);
    AAE = mean(P) * HP.hr/10^6; % Gwh Calculate average annual energy
    % end
    
end


% The remaining turbines are shut down (P is already initialized as zeros)

% Update the shut down turbines to 0 (optional)
% P(shutDownIndices) = 0;

% % % % % % % % % % % % % End iterate over time % % % % % % % % % % % % % %
% Determine the total costs and profit of operation
costP = cost_hpp_opt ( HP ,D , nt, On);
% Unpack costs
cost_em = costP(1);
cost_pen = costP(2);
cost_ph = costP(4); %tp = costP(3);

cost_cw = HP.cf * (cost_pen + cost_em ); % (in dollars) civil + open channel + Tunnel cost
%
% Determine total cost (with cavitation)
Cost_other = cost_pen + cost_ph + cost_cw;

T_cost = cost_em * (1+ HP.tf) + Cost_other + HP.fxc;

cost_OP = cost_em * HP.om; % operation and maintenance cost

AR = AAE* HP.ep*0.98; % AnualRevenue in M dollars 5% will not be sold

AC = HP.CRF * T_cost + cost_OP; % Anual cost in M dollars

% NPV = AR - AC;
% 
% BC = AR/AC;

if HP.Objective == 1
    OF = AR - AC;
    
elseif HP.Objective == 2
    OF = AR / AC;
end
