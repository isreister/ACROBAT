function addAcrobatPaths(top_dir, cruise_name)

% function addAcrobatPaths(top_dir, cruise)
%
%  Add the Acrobat folders to Matlab's search path
% KIM 07.13

% define subfolders under .../MatlabScripts/ACROBAT
subfolders ={''...
    'bathymetry' ...
    'cals'...
    'etc'...
    'initialize'...
    'plotting'...
    'postprocessing'...
    'realtime'...
    'seawater'
    };
% loop through filenames and add to path
for ii = 1:length( subfolders )
    addpath(fullfile( top_dir, 'MatlabScripts', 'ACROBAT', subfolders{ii}),  '-end')
end