function [ ti, tj ] = select_turbine ( HP )


% Calculate the initial head
hi = HP.hg - HP.ht;

if  hi < 25 % only kaplan turbine apropriate
    ti = 0.51;
    tj = 1.49;
    
elseif hi >= 25 && hi <= 56 % kaplan, and francis turbines apropriate
    
    ti = 0.51;
    tj = 2.49;
    
elseif hi > 56 && hi <= 350 % francis and pelton turbines apropriate
    
    ti = 1.51;
    tj = 3.49;
    
elseif hi > 350  % only pelton turbine apropriate
    
    ti = 2.51;
    tj = 3.49;
    
end

