clc; clear; colordef black; format long; close all

%% Parameter Setting
%------------------%
sk16_schott = 1.62286;
f4_hoya = 1.62058;
surface_num = 6;
distance = [5, 2, 5.26, 1.25, 4.69, 2.25, 2];
material = [1, sk16_schott, 1, f4_hoya, 1, sk16_schott, 1];
y_radius = [21.48138, -124.1, -19.1, 22, 328.9, -16.7];
aperture = 10;
%------------------%

%% Source Setting
%------------------%
ang_x = 0;
ang_y = 0;
cross_diameter_num = 51;
%------------------%
[s_x, s_y, s_z, L, M, N] = light_source_setting(aperture,distance,cross_diameter_num,ang_x,ang_y);

%% Calculate Paraxial Focal Length
%------------------%
Use_Paraxial_Solve = 1; % 0 = No, 1 = Yes
%------------------%
[BFL, EFL] = paraxial_focal_length(surface_num,distance,material,y_radius);
disp(['BFL = ',num2str(BFL),', EFL = ',num2str(EFL)])
if Use_Paraxial_Solve == 1
    distance(end+1) = BFL-distance(end);
    material(end+1) = 1;
    y_radius(end+1) = inf;
end

%% Ray Tracing
c = 1./y_radius;
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
        z0 = s_z+distance(i)-N.*delta;
        x0 = s_x+(L./N).*(z0-s_z);
        y0 = s_y+(M./N).*(z0-s_z);
        
        F = c(i).*(x0.^2+y0.^2);
        G = N-c(i).*(L.*x0+M.*y0);
        delta = F./(G+sqrt(G.^2-c(i).*F));
        Opti_Path_Diff = Opti_Path_Diff+abs(delta);
        
        x1 = x0+L.*delta; y1 = y0+M.*delta; z1 = z0+N.*delta;
        x = [s_x;x1];    y = [s_y;y1];    z = [s_z;z1];
        s_x_all{i} = x;  s_y_all{i} = y;  s_z_all{i} = z;
        
        cosI = sqrt(G.^2-c(i).*F);
        nprime_cosIprime = sqrt((material(i+1).^2)-((material(i).^2).*(1-cosI.^2)));
        k = c(i).*(nprime_cosIprime-material(i).*cosI);
        
        Lprime = (material(i).*L-k.*x1)./material(i+1); L = Lprime;
        Mprime = (material(i).*M-k.*y1)./material(i+1); M = Mprime;
        Nprime = sqrt(1-(Lprime.^2+Mprime.^2));         N = Nprime;
        
        s_x = x1; s_y = y1; s_z = z1;
    end
end

%%
Data = data_reshape(s_x_all,s_y_all,s_z_all,cross_diameter_num);

index = find(Data.X_1{1}(1,:)==0);
figure%('units','normalized','outerposition',[0 0 1 1])
for n = 1:numel(distance)
    if material(n)==1
        line_color = 'g';
        lin_wid = 0.5;
    else
        line_color = 'w';
        lin_wid = 3;
    end
    plot(Data.Z_1{n}(:,index),Data.Y_1{n}(:,index),'color',line_color,'linewidth',lin_wid)
    hold on
end
axis equal
% xlim([-sum(distance(1:surface_num)),distance(end)])
grid on
%%
figure
plot(Data.X_1{end}(2,:),Data.Y_1{end}(2,:),'.')
axis equal

%%
[trans_x, trans_y, trans_z] = trans_position(surface_num,Data,L,M,N);

figure
pcolor(trans_x,trans_y,Opti_Path_Diff)
axis equal; shading flat; colorbar; colormap('jet')