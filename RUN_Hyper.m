
clc;
clear;

% Model inputs, project-based parameters  that change from one another
O = load('input.txt');

HP.MFD = 0.63; % the minimum environmental flow (m3/s)

O = max( O - HP.MFD, 0);% define discharge after MFD

HP.hg = 117.3; % initial storage elevation (m), gross head
HP.ht = 0;  % tail water elevation, depth of outflow to stream (m)
HP.L = 208; % the length of penstock (m)

HP.cf = 0.15; %the so-called site factor, ranges between 0 and 1.5 (used for the cost of the civil works)
HP.om  =  0.01; % ranges between 0.01 and 0.04,(used for maintenance and operation cost)
HP.fxc  =  5; % the expropriation and other costs including transmission line

HP.ep = 0.055; % electricity price in Turkey ($/kWh)
HP.pt = 1500; % steel penstock price per ton ($/kWh)
HP.i = 0.095;% the investment discount rate (or interest rate, %)
HP.N = 49;% life time of the project (years)
EffCurves = xlsread('EffCurves.xlsx');

% % % % % % STRUCTURE OF VARIABLES FOR DIFFERENTIAL EVOLUTION % % % % % % %
DE.N = 100;             % population size
DE.T = 100;             % number of generations
DE.maxD = 5;            %
DE.minD = 0.2;          %
DE.maxQ = 10;           %
DE.minQ = 0.5;          %
HP.maxturbine = 3;
HP.opscheme = 1; % 1 = 1 small + identical, 2 = all identical, 3 = all varied
%% Run the model

tic
HP.Objective = 1; % 1: NPV, 2: BC
output = setup_HYPER ( HP, DE, O, EffCurves);
toc