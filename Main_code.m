clc; clear; colordef black; format long; close all;
%% Parameter Setting
%------------------%
lambda = 546.1; % Unit : nm
sk16_schott = 1.62286;
surface_num = 2;
distance = [0.01, 0.02, 0.16055];   % Unit : mm
material = [1, sk16_schott, 1]; % Unit : mm
y_radius = [0.1, -0.1]; % Unit : mm
aperture = 0.05;   % Unit : mm
%------------------%
%------------------%
ang_x = 0;
ang_y = 0;
cross_diameter_num = 201;
%------------------%

%------------------------ Application Switch ------------------------%
%------------------%
Use_Paraxial_Solve = 1;         % 0 = OFF, 1 = ON
%------------------%
View_Lens = 1;                  % 0 = OFF, 1 = ON
    viewplane = 2;              % 1 = XZ, 2 = YZ, 3 = 3D
    display_line = 11;
Spot_Diagram = 1;               % 0 = OFF, 1 = ON
Transmission_Plane = 1;         % 0 = OFF, 1 = ON
Line_Spread_Function = 1;       % 0 = OFF, 1 = ON
MTF = 1;                        % 0 = OFF, 1 = ON
Point_Spread_Function = [1; 1]; % 0 = OFF, 1 = ON; perspective:[yz, xy]

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

%% Lens data
Lens.lambda = lambda*1e-6;
Lens.surface_num = surface_num;
Lens.distance = distance;
Lens.material = material;
Lens.y_radius = y_radius;
Lens.aperture = aperture;

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
    display_tools.view_lens(Lens, Data, display_line, viewplane)
end

%% Spot Diagram
if Spot_Diagram == 1
    display_tools.spot_diagram(Data)
end

%% Optical Path Difference (OPD) at Transmission Plane
trans_plane_data = trans_plane_position_and_optical_path(surface_num, distance, material, Data, L, M, N);

if Transmission_Plane == 1
    display_tools.transmission_plane(trans_plane_data)
end

%% Paraxial Solve
if Use_Paraxial_Solve == 1
    focal_plane_position = sum(distance(end-1:end));
else
    focal_plane_position = distance(end);
end
diffra_limit = diffraction_limit(lambda,aperture,BFL,EFL,focal_plane_position);

%% Line Spread Function
if Line_Spread_Function == 1
    LSF_data = line_spread_function(lambda, aperture, trans_plane_data, focal_plane_position);
    display_tools.line_spread_function(LSF_data,diffra_limit)
end

%% MTF
if MTF == 1
    if Line_Spread_Function == 0
        LSF_data = line_spread_function(lambda, aperture, trans_plane_data, focal_plane_position);
    end
    display_tools.MTF(Lens,LSF_data,diffra_limit,ang_y)
end

%% Point Spread Function
if sum(Point_Spread_Function) > 0
    PSF_data = point_spread_function(lambda, aperture, trans_plane_data, focal_plane_position, Point_Spread_Function);
    display_tools.point_spread_function(Point_Spread_Function,PSF_data,trans_plane_data,focal_plane_position)
end


