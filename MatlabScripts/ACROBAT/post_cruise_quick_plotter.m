%%  ACROBAT LOOK AT REALTIME DATA WORKSHEET
% -------------------------------------------------------------------------
% use this worksheet to run the realtime data feed
clear all; close all; pack

%% STEP 1: DEFINE THE DATA DIRECTORY
% -------------------------------------------------------------------------
% the top directory where all cruise data is saved
top_dir = 'C:\Users\stats\Documents\Chukchi\2014';
scripts_dir = 'C:\Users\stats\Documents\Acrobat\TEST';
% input the cruise name
cruise_name = 'Norseman2_Sep_2014';

% CHOOSE THE BATHYMETRY (choices are 'ALASKA' and 'GEBCO')
global bathy
bathy = 'ALASKA';

%% STEP 2:  PREPARE THE COMPUTER TO PLOT DATA
% -------------------------------------------------------------------------
initializeAcrobatPostProcessing(top_dir, cruise_name, scripts_dir);

%%
lims.p = [0, 40];
lims.t = [-1, 4];
lims.c = [2.8, 3.5];
lims.s = [29, 33];
lims.sgth = [17, 25];
lims.chl = [0, 4];
lims.particle = [0,3]*1e5;
lims.cdom = [0, 5];
%lims.time = [0, 10]./60./24; %minutes to yearday

% WINDOW SIZES
lims.time = [0, 2880]./60./24; %minutes to yearday
lims.lat =  [70.5, 72];
lims.lon =  [-162 -155.75]; % 
lims.plot = [datenum(2014,9,21,5,0,0) datenum(2014,9,21,10,0,0)];
%%
localdir = fullfile(top_dir, cruise_name, 'DATA', 'ACROBAT', 'REALTIME');

[acrobat, CTD, ECO] = ProcessAcrobatALL(top_dir, cruise_name);

plotRealTimeFig3(acrobat, CTD, ECO, lims);

plotTransectMap(top_dir, cruise_name, acrobat, lims)


