function [ fx , fy , x , AAE, Cem, Ct] = DE_hpp ( DE , HP , Q)
% This function uses Differential Evolution to find those values for the
% diameter (m) and the design flow of the first and second turbine (m^3/s)
% that maximize profit of the hydropower plant


% Initialize DE variables
[fx, fy, AAE, Cem, Ct, fx_z, fy_z, AAE_z, Cem_z, Ct_z] =  deal (NaN(DE.N,1));

% Create the initial population
DE.min = repmat(DE.min,DE.N,1); DE.max = repmat(DE.max,DE.N,1);

% Now create parents (starting values)
x = DE.min + rand ( DE.N , DE.d ) .* ( DE.max - DE.min );

nt = round(x(:,end-1)); % define turbine types

On = round(x(:,end)); % define turbine numbers

k(1:DE.N,:) = x;

% Evaluate objective function values of initial population of parents
for i = 1 : DE.N
    
    if On(i) == 1 % 1 turbine
        
        [fx(i,:), fy(i,:),  AAE(i,:)] = calc_hpp1 ( x( i , 1 : DE.d ) , HP , Q , nt(i), 1 );
    else
         [fx(i,:), fy(i,:),  AAE(i,:)] = Vopt_calc_hpp ( x ( i , 1 : DE.d ), HP , Q, nt(i), On(i) );
    end
    
end

%
h = waitbar(0,'HYPER is running, please wait... :)'); %%%%%
% Now do T generations
for t = 2 : DE.T
    
    % Randomly permute [1,...,N-1] N times
    [~,draw] = sort ( rand ( DE.N - 1 , DE.N ) );
    
    % Initialize jump vector to contain zeros only
    z = zeros ( DE.N , DE.d );
    
    % Now create offspring - calculate difference vector (aka jump in MCMC language)
    
    for i = 1:DE.N
        
        % Extract r1 and r2
        r1 = DE.R(i,draw(1,i)); r2 = DE.R(i,draw(2,i)); r3 = DE.R(i,draw(3,i));
        
        % First set offspring equal to current parent
        z(i,1:DE.d) = x(i,1:DE.d);
        
        % Derive subset A with dimensions to sample
        A = find ( rand ( 1 , DE.d ) < DE.CR );
        
        % Now calculate jump for dimensions of A
        %J(i,A) = DE.F(1) * ( x ( r1 , A ) - x ( r2 , A ) );
        z(i,A) = x ( r1 , A ) + DE.F(t) * ( x ( r2 , A ) - x ( r3 , A ) );
        
    end
    
    % Make sure that parameters are in their prior ranges ( otherwise reflection is used )
    [ z ] = check_bounds ( z , DE );
    
    nt = round(z(:, end-1)); % define turbine types
    On = round(z(:, end)); % define turbine numbers
    
    % Evaluate objective function values of children
    for i = 1 : DE.N
        
        if On(i) == 1 % 1 turbine
            
            [fx_z(i,:), fy_z(i,:),  AAE_z(i,:)] = calc_hpp1    ( z ( i , 1 : DE.d ), HP, Q, nt(i), 1);
        else
           [fx_z(i,:), fy_z(i,:),  AAE_z(i,:)] = Vopt_calc_hpp ( z ( i , 1 : DE.d ), HP, Q, nt(i), On(i) );
        end
        
    end
    % Now compare parents with children - if child better then accept, if not keep parent
    idx = find ( fx_z > fx );
    
    % Replace parent with respective child
    x(idx,1:DE.d) = z(idx,1:DE.d);
    
    k((t-1)*DE.N+1:t*DE.N,:) = x;
    
    % And replace profit of parent with that of child
    fx(idx,1) = fx_z(idx,1);
    
    % And other variables as well
    fy(idx,:) = fy_z(idx,:);
    AAE(idx,:) = AAE_z(idx,:);
%     Cem(idx,:) = Cem_z(idx,:);
%     Ct(idx,:) = Ct_z(idx,:);
    
    % Update waitbar
    waitbar(t/DE.T,h);
    
end

close(h);
