function f = moody(ed, Re)

f = zeros(size(Re));

% Find the indices for Laminar
LamR = find(0 < Re & Re < 2000);
LamT = find(Re > 4000);
LamTrans = find(2000 < Re & Re < 4000  );

f(LamR) = 64 ./ Re(LamR);

f(LamT) = 1.325 ./ (log(ed ./ 3.7 + 5.74 ./ (Re(LamT) .^ 0.9))).^2;

Y3 = -0.86859 .* log(ed ./ 3.7 + 5.74 ./ (4000 .^ 0.9));
Y2 = ed ./ 3.7 + 5.74 ./ (Re(LamTrans) .^ 0.9);
FA = Y3 .^ (-2);
FB = FA .* (2 - 0.00514215 ./ (Y2 .* Y3));
R = Re(LamTrans) ./ 2000;
X1 = 7 * FA - FB;
X2 = 0.128 - 17 * FA + 2.5 * FB;
X3 = -0.128 + 13 * FA - 2 * FB;
X4 = R .* (0.032 - 3 * FA + 0.5 * FB);
f(LamTrans) = X1 + R.* (X2 + R .* (X3 + X4));


% HP = structure with variables used in calculation
% ed= the relative roughness: epsilon / diameter.
% Re = the Reynolds number

% % if Re<2000 % Laminar flow
% %     f=64/Re;
% % elseif Re>4000
% %     f=1.325./(log(ed/3.7+5.74./(Re.^0.9))).^2;
% % else
% %     Y3=-0.86859.*log(ed/3.7+5.74/(4000^0.9));
% %     Y2=ed/3.7+5.74./(Re.^0.9);
% %     FA=Y3.^(-2);
% %     FB=FA.*(2-0.00514215./(Y2.*Y3));
% %     R=Re/2000;
% %     X1=7*FA-FB;
% %     X2=0.128-17.*FA+2.5.*FB;
% %     X3=-0.128+13.*FA-2.*FB;
% %     X4=R.*(0.032-3.*FA+0.5.*FB);
% %     f=X1+R.*(X2+R.*(X3+X4));
% % end
% % 
% % end
