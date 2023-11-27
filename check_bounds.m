function [ z ] = check_bounds ( z , DE )
% Uses reflection to make sure parameters stay within their physical realistic ranges

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%              Written by Veysel Yildiz and Jasper A. Vrugt               %
%                   University of California Irvine                       %
%                           December 2014                                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Now make sure values are within bound
[ii_low] = find(z < DE.min); [ii_up] = find(z > DE.max);

% Now reflect in min and max
z(ii_low)= 2 * DE.min(ii_low) - z(ii_low); z(ii_up)= 2 * DE.max(ii_up) - z(ii_up);

% Double check if still in bound! --> lower bound
[ii_low] = find(z < DE.min); z(ii_low) = DE.min(ii_low) + rand(size(ii_low)).* ( DE.max(ii_low) - DE.min(ii_low) );

% Double check if still in bound! --> upper bound
[ii_up]  = find(z > DE.max); z(ii_up)  = DE.min(ii_up)  + rand(size(ii_up)).*  ( DE.max(ii_up)  - DE.min(ii_up)  );