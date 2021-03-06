function plotAcrobatCruiseLegs_TS_distance_map(top_dir, cruise_name)

% function plotAcrobatCruiseLegs2(top_dir, cruise_name)
%
%  Make contour plots of each leg.
%
% KIM 08.13
% v2: CBI 09.13


% IDENTIFY THE TARGET
targetdir = fullfile( top_dir, cruise_name, 'DATA', 'ACROBAT','PROCESSED');
if ~isdir( fullfile(targetdir, 'TC_CORRECTED_PLOTS'))
    mkdir( fullfile( top_dir, cruise_name, 'DATA', 'ACROBAT','PROCESSED'), 'TC_CORRECTED_PLOTS')
end


%LOAD THE DATA
load( fullfile( targetdir, 'gridded.mat'));
load( fullfile( targetdir, [cruise_name,'Legs.mat']));
targetdir = fullfile( top_dir, cruise_name, 'DATA', 'ACROBAT','PROCESSED', 'TC_CORRECTED_PLOTS');

load chuk_bath.mat
load AlaskaXYZ.mat
XE = XE - 360;

% set up the plot
scrsz = get(0,'ScreenSize');
figure(1); % 'position', scrsz); clf
set( 1, 'Position', scrsz);
orient portrait;

min_z = 15;
clf
% create three axes
a(4,1) = axes('position', [0.68      0.2988 0.2800  0.4804]);
a(3,1) = axes('position', [0.0600    0.08   0.5500  0.25]);
a(2,1) = axes('position', [0.0600    0.4    0.5500  0.25]);
a(1,1) = axes('position', [0.0600    0.72   0.5500  0.25]);



% define the variables
vars = {'t', 's', 'dens', 'chl', 'particle', 'CDOM'};
lims = {[-2, 8], [25, 33], [21, 27]+1000, [0, 4], [0, 4]*10^5, [0, 5]};
titles = {'temperature', 'salinity', 'density', 'chlorophyll', 'particle concentration', 'CDOM'};
units = {'[\circ C]', '', '[kg m^{-3}]', '[\mug/l]', '[(m sr)^{-1}]', '[ppb]'};
cticks = {[0:4:8], [25:4:33], [21:2:27], [0:2:4], [0:2:4]*10^5, [0:2:5]};

prange = [0, 60];
pint = 0:0.5:60;

% Now to cycle through the legs and make a contour plot
for ll = 1:length(leg)
% for ll = 1:length( leg )
% for ll = 1:1
    
    clf;
    a(4,1) = axes('position', [0.68      0.2988 0.2800  0.4804]);
    a(3,1) = axes('position', [0.0600    0.08   0.5500  0.25]);
    a(2,1) = axes('position', [0.0600    0.4    0.5500  0.25]);
    a(1,1) = axes('position', [0.0600    0.72   0.5500  0.25]);
    
    filestr = [cruise_name, 'Leg',  leg(ll).name];
    cols = find( gridded.mtime >=leg(ll).tlim(1) &  gridded.mtime <=leg(ll).tlim(2));
    % find the gridded distance
    distleg = nancumsum(gridded.dist(cols),2); % distance in km
    depthgrid = interp2(YE,XE,-ZE,gridded.lat(cols),gridded.lon(cols));
    
    % make the sgth grid for contours
    sgthin = gridded.dens(:, cols)-1000;
    % weed out short profiles
    dds = find( sum( ~isnan( sgthin )) > min_z);
    sgthin = sgthin(:,dds );
    % fill in surface gaps less than 15 m
    for cc = 1:size( sgthin, 2 )
        ii = find( ~isnan( sgthin(:,cc)), 1, 'first');
        if ii < 10
            sgthin(1:ii,cc) = sgthin(ii,cc);
        end
    end
    % fill to the bottom on full profiles
    for cc = 2:size( sgthin, 2 )-1
        ii = find( ~isnan( sgthin(:,cc)), 1, 'last');
        i1 = find( ~isnan( sgthin(:,cc-1)), 1, 'last');
        i2 = find( ~isnan( sgthin(:,cc+1)), 1, 'last');
        if mean(abs( [ii-i1, ii-i2])) < 8
            sgthin(ii:end,cc) = sgthin(ii,cc);
        end
    end
    % interpolate the rest horizontally
    for cc = 1:size( sgthin, 1 )
        sgthin(cc,:) = naninterp( sgthin(cc,:));
    end
    % smooth horizontally and cutoff anything greater than the depth
    for cc = 1:size( sgthin, 2 )
        sgthin(:,cc) = boxcarsmooth( sgthin(:,cc), 5)';
        sgthin( gridded.p > depthgrid(dds(cc)), cc) = nan;
    end
    
    % start plotting
    for ss = 1:3
        axes(a(ss,1))
        cla;
        % fill in the gaps
        datin = gridded.(vars{ss})(:, cols);
        
        % weed out short profiles
        dd =  find( sum( ~isnan( datin )) > min_z);
        datin = datin(:,dd );
        % fill in surface gaps less than 15 m
        for cc = 1:size( datin, 2 )
            ii = find( ~isnan( datin(:,cc)), 1, 'first');
            if ii < 15
                datin(1:ii,cc) = datin(ii,cc);
            end
        end
        % fill to the bottom on full profiles
        for cc = 2:size( datin, 2 )-1
            ii = find( ~isnan( datin(:,cc)), 1, 'last');
            i1 = find( ~isnan( datin(:,cc-1)), 1, 'last');
            i2 = find( ~isnan( datin(:,cc+1)), 1, 'last');
            if mean(abs( [ii-i1, ii-i2])) < 8
                datin(ii:end,cc) = datin(ii,cc);
            end
        end
        % interpolate the rest horizontally
        for cc = 1:size( datin, 1 )
            datin(cc,:) = naninterp( datin(cc,:));
        end
        % smooth horizontally and cutoff anything greater than the depth
        for cc = 1:length(dd)
            datin(:,cc) = boxcarsmooth( datin(:,cc), 5)';
            datin( gridded.p > depthgrid(dd(cc)),cc) = nan;
            
        end
        
        % contourf the data
        contourf( naninterp(distleg(dd)), gridded.p, datin, linspace( lims{ss}(1), lims{ss}(2), 31), 'linecolor', 'none');
        hold on
        % make the density contours
        [c, d] = contour( naninterp(distleg(dds)), gridded.p, sgthin , 20:2:30, '-', 'linewidth', 1, 'color', [1, 1, 1]*0);
        clabel( c, d, 'fontsize', 16, 'fontweight', 'bold')
        
        % plot bottom
        k1 = karea( distleg, depthgrid, 'basevalue', 100, 'facecolor', [1, 1, 1]*0.5, 'edgecolor', [1, 1, 1]*0.1);
        
        % adjust the axes limits
        axis tight;  axis ij; caxis( lims{ss})
        ylim( [0, max(gridded.p)])
        %         % label the axes
        h = gca;
        titleout( titles{ss}, h, 'fontsize', 14, 'fontweight', 'bold')
        set( h, 'fontsize', 12)
        % make the colorbar
        cb = colorbar; set( cb, 'fontsize', 18, 'fontweight', 'normal', 'ytick', cticks{ss})
        %         scoot_axes( [0.01, +0.01, -0.005, -0.02], cb)
        ylabel( cb, units{ss}, 'fontsize', 18)
        % adjust the axes
        scoot_axes( [0, 0, -0.025, 0])
        %         if ss==1,
        %             h8 = title( {[cruise_name];...
        %                 [ ' Leg ', leg(ll).name ]}, 'fontsize', 18, 'fontweight', 'bold');
        %         end
        % turn tick labels on or off
        ylh = ylabel( '[db]');
%         tmpp = get(ylh,'position');
%         set(ylh,'position',[tmpp(1,1) tmpp(1,2) tmpp(1,3)]);
        if ss~=3
            set( h, 'xticklabel', [])
            set(gca,'ytick',[0:20:max(gridded.p)],'yticklabel',[0:20:max(gridded.p)]);
        else
            xlh = xlabel( 'distance [km]');
            tmpp = get(xlh,'position');
            set(xlh,'position',[tmpp(1,1) tmpp(1,2)+1.5 tmpp(1,3)]);
            
            set(gca,'ytick',[0:20:max(gridded.p)],'yticklabel',[0:20:max(gridded.p)]);
        end
        
    end
    %  make a map with the legs
    Site1 = [-(163+(3.186/60)) 69+45.481/60]; %pt lay
    Site2 = [-(160+(2+7.81/60)/60) 70+(38+20.48/60)/60]; %wainwright
    Site3 = [-(156+(39+59.38/60)/60) 71+(19+50.60/60)/60]; %barrow
    
    % open the map and define the projection
    %     load chuk_bath.mat
    %     load AlaskaXYZ.mat
    proj = 'lambert';
    lonrng = [-170 -156];
    %     latrng = [70.4 72.25];
    latrng = [69 73];
    
    %     % make the plot
    %     s3 = subplot( 2, 3, 3);
    %     scoot_axes( [0.01, 0, 0, 0], s3)
    
    %     orient portrait;
    %     orient landscape;
    axes(a(4,1));
    m_proj(proj,'lat',latrng,'lon',lonrng);
    %     m_usercoast('Chukchi_coast_moorf.mat','patch',[.7 .7 .7]);
    %m_gshhs_f('save','Chukchi_coastf');
    m_usercoast('Chukchi_coastf.mat','patch',[.7 .7 .7]);
    %     m_gshhs_f('patch',[0.7 0.7 0.7]);
    m_grid('xtick', 3,'ytick', 3, 'fontsize', 10)
    hold on
         [cs,h] = m_contour(blon,blat,zz,[-20 -30 -40  -50 -60  -100  -150 -200 -300 -500 -1000 -2000 -3000],'color',[.6 .6 .6]);
    %     XE = XE - 360;
    %     [cs,h] = m_contour(XE,YE,ZE,[-20 -30 -40  -50 -60  -100  -150 -200 -300 -500 -1000 -2000 -3000],'color',[.6 .6 .6]);
%     [cs,h] = m_contour(XE,YE,ZE,[-20 -40 -50 -75 -100 -200],'color',[.6 .6 .6]);
%     [cs,h] = m_contour(bathy.lon,bathy.lat,bathy.z,[-20 -40 -50 -75 -100 -200],'color',[.6 .6 .6]);
    clabel(cs,h,'fontsize',6,'label',350,'color',[.6 .6 .6]);
    set(h,'linewidth',.7)
    %
    %     h1 = m_plot( gridded.lon, gridded.lat, '-', 'color', 'r', 'linewidth', 3); hold on
    %     h2 = m_plot( gridded.lon(1), gridded.lat(1), 'o', 'color', 'r', 'markersize', 10, 'linewidth', 2, 'markerfacecolor', 'r')
    
    h1 = m_plot( gridded.lon(cols), gridded.lat(cols), '-', 'color', 'r', 'linewidth', 2); hold on
    h2 = m_plot( gridded.lon(cols(1)), gridded.lat(cols(1)), 'o', 'color', 'k', 'markersize', 6, 'linewidth', 2, 'markerfacecolor', 'g');
    
    
    h3 = m_plot(Site2(1),Site2(2),'marker','square','markersize',7,'color','k','markerfacecolor','b','linestyle','none');
    h4 = m_text(Site2(1)-0.1,Site2(2),'WAINWRIGHT','fontsize',7,'fontweight','bold','fontname','verdana', 'horizontalalignment', 'right');
    h5 = m_plot(Site3(1),Site3(2),'marker','square','markersize',7,'color','k','markerfacecolor','b','linestyle','none');
    h6 = m_text(Site3(1)-0.1,Site3(2),'BARROW','fontsize',7,'fontweight','bold','fontname','verdana', 'horizontalalignment', 'right');
    
    m_ruler([0.2 0.8], .9);
    
%     h8 = title( {[cruise_name];...
%         [ ' Leg ', leg(ll).name ]}, 'fontsize', 18, 'fontweight', 'bold');
    h8 = title( {[ ' Leg ', leg(ll).name ]}, 'fontsize', 18, 'fontweight', 'bold');
    set(h8,'position',[ -0.00001    0.059    5.5197]);
    
    flags = '-r300 -painters';
    filename = [cruise_name, 'Leg', leg(ll).name '_T_S_Sigt_map' ];
    print('-dpng','-r300',[targetdir '\' filename]);
    
    clear h1 h2 h3 h4 h5 h6 h7 h8;
    clf
end % ll