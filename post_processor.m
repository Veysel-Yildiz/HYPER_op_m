%% Post Processor to get the output as table

d_pars = output(:,6:end-2);
type = round(output(:,end-1)); conf = round(output(:,end));

PP = [d_pars type conf ];

%
for i = 1:numel(type)
    if PP(i,end-1) ==1
        PP2{i} = 'Kaplan';
    elseif PP(i,end-1) ==2
        PP2{i} = 'Francis';
    elseif PP(i,end-1) ==3
        PP2{i} = 'Pelton';
    end
    
    if PP(i,end) ==1
        PP3{i} = 'Single';
    elseif PP(i,end) ==2
        PP3{i} = 'Dual';
    elseif PP(i,end) ==3
        PP3{i} = 'Triple';
    end
    
end

fx = output(:,1);
idx  = find (fx == max(fx));

TurbineType = PP2(idx(1));
TurbineConfig  = PP3(idx(1));
D_pars = d_pars(idx(1),:);
D = round(D_pars(:,1),2);
OdL = round(D_pars(:,3),2);
OdS = round(D_pars(:,2),2);

OF = round(fx(idx(1)),2);
IC = round(output(idx(1),2)/1000,2);
AAE =  round(output(idx(1),3),2);
Cem =  round(output(idx(1),4),2);
Ct =  round(output(idx(1),5),2);

tbl = table(TurbineType, TurbineConfig, D, OdS, OdL,  IC, AAE, Cem, Ct, OF);

%
fig = uifigure('Position',[100 100 1000 250]);


if HP.Objective == 1
    colNames = {'Turbine Type','Configuration', 'D (m)', 'Ods(m^3/s)', 'OdL (m^3/s)',  'IC (MW)','AAE (GWh)', 'EM cost (M$)', 'Total cost (M$)', 'NPV (M$)' };
elseif HP.Objective == 2
    colNames = {'Turbine Type','Configuration', 'D (m)', 'Ods(m^3/s)', 'OdL (m^3/s)',  'IC (MW)','AAE (GWh)',  'EM cost (M$)', 'Total cost (M$)','BC (-)' };
end

uit = uitable('Parent',fig,'ColumnName',colNames,'Position',[25 50 950 200]);
uit.Data = tbl;