function plotRealTimeAKMap(acrobat, lims)

% function plotRealTimeAKMap(acrobat, lims)
%
% This function plots the shiptrack from the GPS and updates the map
% bathymetry if the latitude and longitude limits change.
%
% KIM 07.13

% make figure 1 window if it does not exist
if ~ishghandle(3)
    makeRealTimeAKmap(lims)
end

% find the limits on the current map
currlims = get(3, 'UserData');

% if current limits do not match input limits, replot the map
if lims.lat(1)~= currlims(1) || lims.lat(2)~=currlims(3) || lims.lon(1)~= currlims(2) || lims.lon(2)~=currlims(4)
    disp('replotting bathymetry....')
    makeRealTimeAKmap(lims)
end

set(3, 'UserData', [lims.lat; lims.lon]); 

% plot the ship track
% plotRealTimeShipTrack(acrobat)