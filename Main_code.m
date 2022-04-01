clc;clear;close all;

% [surface_num,distance,material,aperture] = Parameter_Setting;
surface_num = 2;
distance = [10,5,30];
material = [1,1.2,1];
y_radius = [30,inf];
aperture = 20;

%%
line_num = 21;

if mod(line_num,2)==0
    line_num = line_num+1;
end

x = linspace(-aperture/2,aperture/2,line_num);
y = linspace(-aperture/2,aperture/2,line_num);

[s_x,s_y] = meshgrid(x,y);
r = sqrt(s_x.^2+s_y.^2);

s_x(r>aperture/2) = nan; s_y(r>aperture/2) = nan;
s_x = reshape(s_x,1,numel(s_x)); s_y = reshape(s_y,1,numel(s_y));
s_x(isnan(s_x))=[]; s_y(isnan(s_y))=[]; s_z = zeros(1,numel(s_x));
delta = s_z;
L = s_z; M = s_z; N = ones(1,numel(s_z));

%%
c = 1./y_radius;
s_x_all = cell(1,numel(distance)); s_y_all = s_x_all; s_z_all = s_x_all;
for i = 1:numel(distance)
    z0 = s_z+distance(i)-N.*delta;
    x0 = s_x+(L./N).*(z0-s_z);
    y0 = s_y+(M./N).*(z0-s_z);
    
    if i==numel(distance)
        x = [s_x;x0];
        y = [s_y;y0];
        z = [s_z;z0];
        s_x_all{i} = x;
        s_y_all{i} = y;
        s_z_all{i} = z;
    else
        F = c(i).*(x0.^2 + y0.^2);
        G = N(1,:) - c(i).*(L(1,:).*x0 + M(1,:).*y0);
        delta = F ./ ( G + (G.^2 - c(i).*F).^(1/2));

        x1 = x0 + L(1,:).* delta ;
        y1 = y0 + M(1,:).* delta ;
        z1 = z0 + N(1,:).* delta ;

        x = [s_x;x1];
        y = [s_y;y1];
        z = [s_z;z1];
        s_x_all{i} = x;
        s_y_all{i} = y;
        s_z_all{i} = z;
        cosI = (G.^2 - c(i).*F).^(1/2) ;
        nprime_cosIprime = ((material(i+1).^2)-((material(i).^2).*(1- cosI.^2))).^(1/2);
        k = c(i) .* (nprime_cosIprime - material(i).* cosI ) ;
        Lprime = (material(i).*L - k.*x1 )./ material(i+1) ;
        Mprime = ( material(i).*M - k.*y1 )./ material(i+1) ;
        Nprime = ( 1- (Lprime.^2 + Mprime.^2) ).^(1/2) ;
        L = Lprime ; M = Mprime ; N = Nprime ;
        s_x = x1 ;
        s_y = y1 ;
        s_z = z1 ;
        
    end
end



%%
index = find(s_x_all{1}(1,:)==0);

figure
for n = 1:numel(distance)
    if material(n)==1
        line_color = 'g';
    else
        line_color = 'r';
    end
    plot(s_z_all{n}(:,index),s_y_all{n}(:,index),'color',line_color,'linewidth',1)
    hold on
end
ylim([-aperture*2,aperture*2])



% for n = 1:numel(distance)
%     if material(n)==1
%         line_color = 'y';
%     else
%         line_color = 'r';
%     end
%     plot3(s_z_all(n:n+1,:),s_x_all(n:n+1,:),s_y_all(n:n+1,:),'color',line_color,'linewidth',1)
%     hold on
% end


