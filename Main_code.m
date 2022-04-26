clc; clear; colordef black; format long; close all;
%% Parameter Setting
%------------------%
lambda = 546.1; % Unit : nm
sk16_schott = 1.62286;
surface_num = 2;
distance = [0.01, 0.01, 0.112384569991885];   % Unit : mm
material = [1, sk16_schott, 1]; % Unit : mm
y_radius = [inf, -0.07]; % Unit : mm
aperture = 0.05;   % Unit : mm
%------------------%
%------------------%
ang_x = 0;
ang_y = 0;
cross_diameter_num = 501;
%------------------%
%------------------%
Use_Paraxial_Solve = 0;         % 0 = No, 1 = Yes
%------------------%
View_Lens = 1;                  % 0 = No, 1 = Yes
    display_line = 21;
Spot_Diagram = 1;               % 0 = No, 1 = Yes
    display_num_spot_per_diameter = 21;
Transmission_Plane = 1;         % 0 = No, 1 = Yes
Point_Spread_Function = [1, 1];  % 0 = No, 1 = Yes, perspective:[yz, xy]
Line_Spread_Function = 1;       % 0 = No, 1 = Yes


%% Source Setting
lambda = lambda*1e-6;   % nm -> mm
[s_x, s_y, s_z, L, M, N] = light_source_setting(aperture,distance,cross_diameter_num,ang_x,ang_y);

%% Calculate Paraxial Focal Length
[BFL, EFL] = paraxial_focal_length(surface_num,distance,material,y_radius);
disp(['BFL = ',num2str(BFL),', EFL = ',num2str(EFL)])
if Use_Paraxial_Solve == 1
    distance(end+1) = BFL-distance(end);
    material(end+1) = 1;
    y_radius(end+1) = inf;
end

%% Ray Tracing
curvature = 1./y_radius;
s_x_all = cell(1,numel(distance)); s_y_all = cell(1,numel(distance)); s_z_all = cell(1,numel(distance));
delta = zeros(size(s_x,1),size(s_x,2));
Opti_Path_Diff = zeros(size(s_x,1),size(s_x,2));

for i = 1:numel(distance)
    if i == numel(distance)
        z0 = ones(size(z0,1),size(z0,2))*sum(distance);
        x0 = s_x+(L./N).*(z0-s_z);
        y0 = s_y+(M./N).*(z0-s_z);
        
        x = [s_x;x0];    y = [s_y;y0];    z = [s_z;z0];
        s_x_all{i} = x;  s_y_all{i} = y;  s_z_all{i} = z;
    else
        z0 = s_z+distance(i)-delta;
        x0 = s_x+(L./N).*(z0-s_z);
        y0 = s_y+(M./N).*(z0-s_z);
        
        B = N-curvature(i).*(L.*x0+M.*y0);
        C = curvature(i).*(x0.^2+y0.^2);
        delta = C./(B+sqrt(B.^2-curvature(i).*C));
        
        if i <= surface_num
            Opti_Path_Diff = Opti_Path_Diff+abs(delta);
        end
        
        x1 = x0+L.*delta; y1 = y0+M.*delta; z1 = z0+N.*delta;
        x = [s_x;x1];    y = [s_y;y1];    z = [s_z;z1];
        s_x_all{i} = x;  s_y_all{i} = y;  s_z_all{i} = z;
        
        CosInc = sqrt(B.^2-curvature(i).*C);
        nTrans_CosTrans = sqrt((material(i+1).^2)-((material(i).^2).*(1-CosInc.^2)));
        k = curvature(i).*(nTrans_CosTrans-material(i).*CosInc);
        
        L_Trans = (material(i).*L-k.*x1)./material(i+1); L = L_Trans;
        M_Trans = (material(i).*M-k.*y1)./material(i+1); M = M_Trans;
        N_Trans = sqrt(1-(L_Trans.^2+M_Trans.^2));       N = N_Trans;
        
        s_x = x1; s_y = y1; s_z = z1;
    end
end

Data = data_reshape(s_x_all,s_y_all,s_z_all,cross_diameter_num);
%% View Lens
if View_Lens == 1
    index_y_plane = find(Data.X_1{1}(1,:)==0);
    display_line_position = aperture/2*linspace(-1,1,display_line);
    index_display_lines = [];
    for n = 1:display_line
        inx = find(Data.Y_1{1}(1,:)==display_line_position(n));
        index_display_lines = [index_display_lines,inx];
    end
    index = intersect(index_y_plane,index_display_lines);
    
    
    figure('units','normalized','outerposition',[0 0 1 1])
    for n = 1:numel(distance)
        if material(n)==1
            line_color = 'g';
            lin_wid = 0.5;
        else
            line_color = 'w';
            lin_wid = 3;
        end
        plot(Data.Z_1{n}(:,index)-sum(distance(1:surface_num)),Data.Y_1{n}(:,index), ...
            'color',line_color,'linewidth',lin_wid)
        hold on
    end
    axis equal
    xlim([-sum(distance(1:surface_num)),sum(distance(surface_num+1:end))])
    ylim([-aperture*1.2/2,aperture*1.2/2])
    grid on
    xlabel('z (mm)')
    ylabel('y (mm)')
    title('View Lens')
    pause(0.01)
end
%% Spot Diagram
if Spot_Diagram == 1
    figure
    plot(Data.X_1{end}(2,:),Data.Y_1{end}(2,:),'.')
    axis equal
    title('Spot Diagram')
    pause(0.01)
end
%% Optical Path Difference (OPD) at Transmission Plane
trans_plane_data = trans_plane_position_and_optical_path(surface_num, distance, material, Data, L, M, N);

if Transmission_Plane == 1
    figure
    pcolor(trans_plane_data.x,trans_plane_data.y,trans_plane_data.OP)
    axis equal; shading flat; colorbar; colormap('jet')
    pause(0.01)
end

%%
if Use_Paraxial_Solve == 1
    focal_plane_position = sum(distance(end-1:end));
else
    focal_plane_position = distance(end);
end
diffra_limit = diffraction_limit(lambda,aperture,BFL,EFL,focal_plane_position);
%% Line Spread Function
if Line_Spread_Function == 1
    LSF_data = line_spread_function(lambda, aperture, trans_plane_data, focal_plane_position);
    %%
    figure
    plot(LSF_data.Monitor_y,LSF_data.Power_normalize,'linewidth',.5,'color',[0.93,0.69,0.13])
    hold on
    plot(diffra_limit.y,diffra_limit.I,':','linewidth',.5,'color','w')
    title('Line Spread Function',['Strehl Ratio = ',num2str(LSF_data.Strehl_ratio)])
    grid on
    ax = gca;
    ax.GridColor = [0.32 0.32 0.32];
    
end

%% Point Spread Function
if sum(Point_Spread_Function) > 0
    PSF_data = point_spread_function(lambda, aperture, trans_plane_data, focal_plane_position, Point_Spread_Function);
    %%
    if Point_Spread_Function(1)==1
        plot_z = PSF_data.Monitor_z-trans_plane_data.dz;
        [~, index_z_1] = find(PSF_data.Intensity_normalize==1);
        [~, index_z_2] = min(abs(plot_z-focal_plane_position));
        disp(['Best Focus Plane = ',num2str(plot_z(index_z_1)),' mm'])

        figure
        p1 = pcolor(plot_z,PSF_data.Monitor_y,PSF_data.Power_normalize);
        p2 = line([plot_z(index_z_1) plot_z(index_z_1)],[PSF_data.Monitor_y(1) PSF_data.Monitor_y(end)], ...
            'color','w','linewidth',0.5,'linestyle',':');
        p3 = line([plot_z(index_z_2) plot_z(index_z_2)],[PSF_data.Monitor_y(1) PSF_data.Monitor_y(end)], ...
            'color','y','linewidth',0.5,'linestyle','-');
        title('Point Spread Function YZ',['Best Focus Plane = ',num2str(plot_z(index_z_1)),' mm'])
        legend([p2, p3],'Best Focus Plane','Focus Plane','Location','northwest','NumColumns',1)
        colormap('jet') 
        shading interp
        xlabel('z (mm)')
        ylabel('y (mm)')
        colorbar
        pause(0.01)
%         figure
%         plot(PSF_data.Monitor_y,PSF_data.Power_normalize(:,index_z_2),'linewidth',.5,'color',[0.93,0.69,0.13])
%         hold on
%         title(['Strehl Ratio = ',num2str(PSF_data.Strehl_ratio)])
%         grid on
%         ax = gca;
%         ax.GridColor = [0.32 0.32 0.32];
%         pause(0.01)
    end
    %%
    if Point_Spread_Function(2)==1
        figure
        surf(PSF_data.Monitor_x,PSF_data.Monitor_y,PSF_data.Power_normalize_xy)
        title('Point Spread Function XY',['Strehl Ratio = ',num2str(PSF_data.Strehl_ratio_xy)])
        colormap('jet') 
        shading interp
        xlabel('x (mm)')
        ylabel('y (mm)')
        colorbar
        pause(0.01)
    end
end

%% MTF
LSF = LSF_data.Power;
% LSF = PSF_data.Power(:,index_z_2);
OTF = fftshift(fft(LSF));
MTF = abs(OTF);
MTF = MTF./max(MTF);
size = length(MTF);
D = aperture;
a = linspace(-size/2,size/2,size);
f = a*(1/D);

figure
plot(diffra_limit.f,diffra_limit.MTF',':','linewidth',.5,'color','w')
hold on
plot(f,MTF,'linewidth',.5,'color',[0.93,0.69,0.13])
xlim([0,diffra_limit.cutoff_freq])
title('Diffraction MTF')
xlabel('cycles / mm')
ylabel('Modulation')
grid on
legend('Diffraction Limit',['Ang ',num2str(ang_y),' degree'])
ax = gca;
ax.GridColor = [0.32 0.32 0.32];


