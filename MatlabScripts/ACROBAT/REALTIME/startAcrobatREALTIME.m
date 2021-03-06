function a = startAcrobatREALTIME(top_dir, cruise_name, lims)

% function a = startAcrobatREALTIME(top_dir, cruise_name, lims);
% 
% Start the realtime display of data from the Acrobat
%
% KIM 08.12

% DEFINE DATA REFRESH RATE
% -------------------------------------------------------------------------
updaterate = 30; % updates every 60 seconds/1 minute, works with DASYLAB setup

% DEFINE THE LOCATION OF THE REALTIME DATA
% -------------------------------------------------------------------------
localdir = fullfile(top_dir, cruise_name, 'DATA', 'ACROBAT', 'REALTIME');

%  SETUP THE DATA REFRESH TIMER
% -------------------------------------------------------------------------
% define the timer
a = timer; 
% set the timer to execute the function at an interval
set( a, 'executionmode', 'fixedrate')
% set the period (this case 60 seconds = 1min)
set(a, 'period', updaterate)

%  DEFINE FUNCTIONS TIMER WILL RUN
% -------------------------------------------------------------------------
% define the functions the timer will execute (must be a text string)
fncs = [...
    '[acrobat, CTD, ECO] = ProcessAcrobatREALTIME(top_dir, cruise_name, lims.time(2)); ',...
    'plotAcrobatRealtime( top_dir, cruise_name, acrobat, CTD, ECO, lims );'...
    ];
% tell the timer which functions it will execute
set( a, 'TimerFcn', fncs)

%  START THE REALTIME DISPLAY
% -------------------------------------------------------------------------
% start the timer, which executes the functions
start(a)
display( ['REALTIME Acrobat display started ', datestr(now)])











