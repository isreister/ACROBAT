%%  ACROBAT REALTIME WORKSHEET
% -------------------------------------------------------------------------
% use this worksheet to run the realtime data feed
clear all; close all; pack

%% STEP 1: DEFINE THE DATA DIRECTORY
% -------------------------------------------------------------------------
% the top directory where all cruise data is saved
top_dir = 'C:\Users\pwinsor';
% input the cruise name
cruise_name = 'Chukchi_2013_N2';

% CHOOSE THE BATHYMETRY (choices are 'ALASKA' and 'GEBCO')
global bathy
bathy = 'ALASKA';

%% STEP 2:  PREPARE THE COMPUTER TO ACQUIRE DATA
% -------------------------------------------------------------------------
initializeAcrobatREALTIME(top_dir, cruise_name);

%%  STEP 3: START THE REALTIME DISPLAY
% -------------------------------------------------------------------------
a = startAcrobatREALTIME(top_dir, cruise_name, lims);

%% STEP 4: DEFINE THE PLOT LIMITS (will update each time plot refreshes)
% -------------------------------------------------------------------------
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
lims.time = [0, 30]./60./24; %minutes to yearday
lims.lat =  [70.5, 72];
lims.lon =  [-162 -155.75]; % 

%%  STEP 5: RUN THIS CELL TO STOP THE REALTIME DISPLAY
% -----------------------------------------[--------------------------------
stopAcrobatREALTIME(a)









