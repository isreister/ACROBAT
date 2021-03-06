function plotAcrobat_pycnocline_xsec(top_dir, cruise_name)

% function plotAcrobatCruiseLegs2(top_dir, cruise_name)
%
%
%
% HS 02.16


% IDENTIFY THE TARGET
targetdir = fullfile( top_dir, cruise_name, 'DATA', 'ACROBAT','PROCESSED');
if ~isdir( fullfile(targetdir, 'TC_CORRECTED_PLOTS'))
    mkdir( fullfile( top_dir, cruise_name, 'DATA', 'ACROBAT','PROCESSED'), 'TC_CORRECTED_PLOTS')
end


%LOAD THE DATA
load( fullfile( targetdir, 'gridded.mat'));
load( fullfile( targetdir, [cruise_name,'Legs.mat']));
targetdir = 'C:\Users\stats\Documents\Acrobat\Figures';

[M,N] = size(gridded.dens),
for in=1:N,
    dif_dens(:,in) = diff(gridded.dens(:,in));
    if length(find(~isnan(dif_dens(:,in))) > 10),
        py_d(in) = gridded.p(near(dif_dens(:,in), max(dif_dens(:,in)),1));
    else,
        py_d(in) = NaN;
    end
end

load chuk_bath.mat
load AlaskaXYZ.mat
XE = XE - 360;

% set up the plot
scrsz = get(0,'ScreenSize');
figure(1); % 'position', scrsz);
clf
set( 1, 'Position', scrsz);
orient landscape;
% create six axes
% a(6,1) = axes('position', [0.0600    0.0310    0.5500 0.1226]);
% a(5,1) = axes('position', [0.0600    0.1935    0.5500 0.1226]);
% a(4,1) = axes('position', [0.0600    0.3560    0.5500 0.1226]);
% a(3,1) = axes('position', [0.0600    0.5184    0.5500 0.1226]);
% a(2,1) = axes('position', [0.0600    0.6809    0.5500 0.1226]);
% a(1,1) = axes('position', [0.0600    0.8434    0.5500 0.1226]);
% a(7,1) = axes('position', [0.68      0.5250    0.2800 0.4004]);
% a(8,1) = axes('position', [0.68      0.0310    0.2800 0.4004]);

% define the variables
vars = {'t', 's', 'dens', 'chl', 'particle', 'CDOM'};
lims = {[-2, 10], [25, 34], [20, 27]+1000, [0, 5], [0, 5]*10^5, [0, 5]};
titles = {'temperature', 'salinity', 'density', 'chlorophyll', 'particle concentration', 'CDOM'};
units = {'[\circ C]', '', '[kg m^{-3}]', '[\mug/l]', '[(m sr)^{-1}]', '[ppb]'};
cticks = {[-2:2:10], [25:4:34], [20:2:27], [0:2:4], [0:2:4]*10^5, [0:2:4]};

prange = [0, 60];
pint = 0:0.5:60;

% Now to cycle through the legs and make a contour plot
for ll = 1:length(leg)
    % for ll = 1:length( leg )
    % for ll = 1:1
    
    clf;
    % create six axes
    plot_y = 0.080;
    a(5,1) = axes('position', [0.0600    plot_y             0.5500 0.1226]);
    a(4,1) = axes('position', [0.0600    plot_y+0.18      0.5500 0.1226]);
    a(3,1) = axes('position', [0.0600    plot_y+2.*0.18   0.5500 0.1226]);
    a(2,1) = axes('position', [0.0600    plot_y+3.*0.18   0.5500 0.1226]);
    a(1,1) = axes('position', [0.0600    plot_y+4.*0.18   0.5500 0.1226]);
   % a(1,1) = axes('position', [0.0600    0.8434    0.5500 0.1226]);
    %     a(7,1) = axes('position', [0.68      0.3988    0.2800 0.4804]);
    a(6,1) = axes('position', [0.68      0.5250           0.2800 0.4004]);
    a(7,1) = axes('position', [0.68      plot_y           0.2800 0.4004]);
    
    filestr = [cruise_name, 'Leg',  leg(ll).name];
    
    cols = find( gridded.mtime >= leg(ll).tlim(1) &  gridded.mtime <=leg(ll).tlim(2));
    
    % find the gridded distance
    distleg = nancumsum(gridded.dist(cols),2); % distance in km
    %determine if lon is positive or negative
    sgn = mean(gridded.lon(cols));
    if (sgn > 0),
        gridded.lon(cols) = -gridded.lon(cols) ;
    end
    % find the gridded depth
    depthgrid = interp2(YE, XE, -ZE , gridded.lat(cols), gridded.lon(cols));
    
    % make the sgth grid for contours
    sgthin = gridded.dens(:, cols)-1000;
    % weed out short profiles
    dds = find( sum( ~isnan( sgthin )) >10);
    sgthin = sgthin(:,dds );
    % fill in surface gaps less than 10 m
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
    
    ss_inds = [1 2 4 5 6];
    % start plotting
    for in = 1:5,
        %         axes(sb(ss))
        ss = ss_inds(in);
        axes(a(in,1))
        cla;
        % fill in the gaps
        datin = gridded.(vars{ss})(:, cols);
       
        % weed out short profiles
        dd =  find( sum( ~isnan( datin )) >10);
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
            if (length(find(isnan(datin(cc,:)))) > (length(datin(cc,:))-2)),
                datin(cc,:) = ones(length(datin(cc,:)),1).*NaN;
            else
                datin(cc,:) = naninterp( datin(cc,:));
            end
        end
        % smooth horizontally and cutoff anything greater than the depth
        for cc = 1:length(dd)
            datin(:,cc) = boxcarsmooth( datin(:,cc), 5)';
            datin( gridded.p > depthgrid(dd(cc)),cc) = nan;
        end
        py_df = boxcarsmooth( py_d(cols), 5);
        if (ss == 1),
            temp = datin;
        elseif (ss == 2);
            sal = datin;
        end
        % contourf the data
        contourf( naninterp(distleg(dd)), gridded.p, datin, linspace( lims{ss}(1), lims{ss}(2), 31), 'linecolor', 'none');
        hold on
        % make the density contours
        [c, d] = contour( naninterp(distleg(dds)), gridded.p, sgthin , 20:1:30, '-', 'linewidth', 1, 'color', [1, 1, 1]*0);
        clabel( c, d, 'fontweight', 'bold','fontsize',10,'fontname','Times')
        % plot bottom
        k1 = karea( distleg, depthgrid, 'basevalue', 100, 'facecolor', [1, 1, 1]*0.5, 'edgecolor', [1, 1, 1]*0.1);
        plot(distleg, py_df,'w--','linewidth',1)
        % adjust the axes limits
        axis tight;  axis ij; caxis( lims{ss})
        ylim( [0, max(gridded.p)])
        % label the axes
        titleout( titles{ss}, a(in,1), 'fontsize', 14, 'fontweight', 'bold','fontname','Times')
        set( a(in,1), 'fontsize', 12,'fontname','Times')
        % make the colorbar
        cb = colorbar; 
        set( cb, 'fontsize', 12, 'fontweight', 'normal', 'ytick', cticks{ss})
        ylabel( cb, units{ss}, 'fontsize', 12,'fontname','Times')
        % adjust the axes
        scoot_axes( [0, 0, -0.025, 0])
        % turn tick labels on or off
        if in~=5
            set( a(in,1), 'xticklabel', [])
            set(gca,'ytick',[0:20:max(gridded.p)],'yticklabel',[0:20:max(gridded.p)]);
        else
            xlh = xlabel( 'distance [km]');
            tmpp = get(xlh,'position');
            %set(xlh,'position',[tmpp(1,1) tmpp(1,2)+1.5 tmpp(1,3)]);
            set(xlh,'position',[tmpp(1,1) tmpp(1,2)-1.5 tmpp(1,3)]);
            ylh = ylabel( '[db]');
            tmpp = get(ylh,'position');
            set(ylh,'position',[tmpp(1,1)-.5 tmpp(1,2) tmpp(1,3)]);
            set(gca,'ytick',[0:20:max(gridded.p)],'yticklabel',[0:20:max(gridded.p)]);
        end
    end
     %  make a map with the legs
    Site1 = [-(163+(3.186/60)) 69+45.481/60]; %pt lay
    Site2 = [-(160+(2+7.81/60)/60) 70+(38+20.48/60)/60]; %wainwright
    Site3 = [-(156+(39+59.38/60)/60) 71+(19+50.60/60)/60]; %barrow
    
    % open the map and define the projection
    proj = 'lambert';
    if (strcmp(cruise_name, 'ChukchiGliderCruise2012')),
        lonrng = [-165 -153.5];
        latrng = [70 72.5];
    elseif (strcmp(cruise_name, 'ChukchiGliderCruise2013')),
        lonrng = [-169 -156];
        latrng = [70 73];
    else,
        lonrng = [-169 -156];
        latrng = [70 73];
    end
    
orient landscape;
    axes(a(6,1));
    m_proj(proj,'lat',latrng,'lon',lonrng);
    % only call this once to make the coastline file
    %     m_gshhs_f('save','Chukchi_coastfb.mat')
    if (strcmp(cruise_name, 'ChukchiGliderCruise2012')),
        m_usercoast('Chukchi_coast_2012_N2.mat','patch',[0.7 0.7 0.7]);
    elseif (strcmp(cruise_name, 'ChukchiGliderCruise2013')),
        m_usercoast('Chukchi_coast_2013_N2.mat','patch',[0.7 0.7 0.7]);
    else,
        m_usercoast('Chukchi_coast_2013_N2.mat','patch',[0.7 0.7 0.7]);
    end
    
    m_grid('xtick', 3,'ytick', 3, 'fontsize', 12)
    hold on
    [cs,h] = m_contour(blon,blat,zz,[20 30 40 50 60 100 150 200 300 500 1000 2000 3000],'color',[.6 .6 .6]);
    clabel(cs,h,'fontsize',6,'label',350,'color',[.6 .6 .6]);
    set(h,'linewidth',.7)
    
    h1 = m_plot( gridded.lon(cols), gridded.lat(cols), '-', 'color', 'r', 'linewidth', 2); hold on
    h2 = m_plot( gridded.lon(cols(1)), gridded.lat(cols(1)), 'o', 'color', 'k', 'markersize', 4, 'linewidth', 2, 'markerfacecolor', 'g')
    
    %h3 = m_plot(Site2(1),Site2(2),'marker','square','markersize',7,'color','k','markerfacecolor','b','linestyle','none');
    h4 = m_text(Site2(1)-0.1,Site2(2),'WAINWRIGHT','fontsize',6,'fontweight','bold','fontname','verdana', 'horizontalalignment', 'right');
    h5 = m_plot(Site3(1),Site3(2),'marker','square','markersize',7,'color','k','markerfacecolor','b','linestyle','none');
   %h6 = m_text(Site3(1)-0.1,Site3(2),'BARROW','fontsize',6,'fontweight','bold','fontname','verdana', 'horizontalalignment', 'right');
    
    m_ruler([0.2 0.8], .9);
    
    h8 = title( {[cruise_name];...
        [ ' Leg ', leg(ll).name ];...
        ['Start Time: ' datestr(gridded.mtime(cols(1)))]}, 'fontsize', 16, 'fontweight', 'bold');
    %     tmph8 = get(h8,'position');
    %set(h8,'position',[ -0.00001    0.059    4.5197]);
    % Make the TS plot
    axes(a(7,1));
    [M,N] = size(temp);
    ptmp = sw_ptmp(sal,temp,gridded.p,1);
    tt = reshape(ptmp, M.*N,1);
    ss = reshape(sal, M.*N,1);
    
    Sg = lims{2}(1)+[0:30]/30*(lims{2}(2)-lims{2}(1));
    Tg = lims{1}(1)+[0:30]/30*(lims{1}(2)-lims{1}(1));
    SG = sw_dens(Sg,Tg,30)-1000;
    [X,Y] = meshgrid(Sg,Tg);
    dens = sw_dens(X,Y,1)-1000;
    [CS,H]=contour(X,Y,dens,'color','k','linewidth',.5,'linestyle','-');
    clabel(CS,H); %,sigma(1:2:end));
    axis('square');
    freezeT=swfreezetemp([lims{2}(1) lims{2}(2)],1);
    line([lims{2}(1) lims{2}(2)],freezeT,'LineStyle','--','linewidth',1.5);
    hold on;
    plot(ss, tt,'k.')
    xlabel('Salinity','fontsize',12,'fontname','Times');
    ylabel('Pot. Temperature ({\circ}C)','fontsize',12,'fontname','Times');
    grid on
    set(gca,'xlim',[lims{2}(1) lims{2}(2)],'ylim',[lims{1}(1) lims{1}(2)],'fontsize',10,'fontname','Times')
    % Gong and Pickart Defined Limits
    %ACW
    plot([30 lims{2}(2)],[3 3],'k','linewidth',1.5); %horiz. line
    plot([30 30],[-1 lims{1}(2)],'k','linewidth',1.5); %vert. line
    %CSW
    plot([lims{2}(1) lims{2}(2)],[-1 -1],'k','linewidth',1.5); %horiz. line
    %plot([33.6 33.6],[-1 3],'k','linewidth',1.5); %vert. line
    plot([32.8 32.8],[-1 3],'k','linewidth',1.5); %vert. line
    %MW
    plot([31.5 31.5],[-2 -1],'k','linewidth',1.5); %horiz. line
    %PWW
    plot([31.5 lims{2}(2)],[-1.6 -1.6],'k','linewidth',1.5); %horiz. line
    
    flags = '-r300 -painters';
    filename = [cruise_name, 'Leg', leg(ll).name '_pycnocline' ];
    print('-dpng','-r300',[targetdir '/' filename]);
    %    WriteEPS(filename, targetdir, flags)
    %      WritePDF(filename,targetdir,flags);
    clear h1 h2 h3 h4 h5 h6 h7 h8;
%     for ss=1:7
%         axes(a(ss,1));
%         cla;
%     end
end % ll