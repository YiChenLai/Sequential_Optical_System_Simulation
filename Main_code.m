clc;clear;
close all;
% [surface_num,distance,material,aperture] = Parameter_Setting;
sk16 = 1.62041;
f2 = 1.647690;
surface_num = 6;
distance = [10,3.258956,6.007551,0.999746,4.750409,2.952976,42.41507];
material = [1,sk16,1,f2,1,sk16,1];
y_radius = [22.01359,-435.7604,-22.21328,20.29192,79.6836,-18.39533];
aperture = 10;

%%
%%
c = 1./y_radius;

Mtot = [ 1,0;...
         0,1 ];
     
for ii = 1:surface_num-1
    M_r = [ 1 -((material(ii+1)- material(ii)).*c(ii)) ; 0 1 ];
    M_t = [ 1 0 ; distance(ii+1)./material(ii+1) 1 ];
    Mtot = M_t * M_r * Mtot ;
end

ii = surface_num ;
Mtot = [ 1 -(( material(ii+1)- material(ii) ).*c(ii)) ; 0 1 ] * Mtot ;
B = Mtot(1,1) ; A = - Mtot(1,2) ;
D = -Mtot(2,1) ; C = Mtot(2,2) ;
beta = ( B + A .* ( -inf./material(1) ) ).^(-1) ;
paraxial_focal_distance = (material(surface_num+1)./A ).* (C-beta)

distance(end) = paraxial_focal_distance;

%%
line_num = 51;

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
s_x_all = cell(1,numel(distance)); s_y_all = cell(1,numel(distance)); s_z_all = cell(1,numel(distance));

for i = 1:numel(distance)
    z0 = s_z+distance(i)-N.*delta;
    x0 = s_x+(L./N).*(z0-s_z);
    y0 = s_y+(M./N).*(z0-s_z);
    
    if i==numel(distance)
        x = [s_x;x0];    y = [s_y;y0];    z = [s_z;z0];
        s_x_all{i} = x;  s_y_all{i} = y;  s_z_all{i} = z;
    else
        F = c(i).*(x0.^2 + y0.^2);
        G = N - c(i).*(L.*x0 + M.*y0);
        delta = F ./ ( G + (G.^2 - c(i).*F).^(1/2));

        x1 = x0 +L.*delta;
        y1 = y0 +M.*delta;
        z1 = z0 +N.*delta;

        x = [s_x;x1];    y = [s_y;y1];    z = [s_z;z1];
        s_x_all{i} = x;  s_y_all{i} = y;  s_z_all{i} = z;
        
        cosI = (G.^2-c(i).*F).^(1/2);
        nprime_cosIprime = ((material(i+1).^2)-((material(i).^2).*(1-cosI.^2))).^(1/2);
        k = c(i).*(nprime_cosIprime-material(i).*cosI);
        
        Lprime = (material(i).*L-k.*x1)./material(i+1); L = Lprime; 
        Mprime = (material(i).*M-k.*y1)./material(i+1); M = Mprime; 
        Nprime = (1-(Lprime.^2+Mprime.^2)).^(1/2);      N = Nprime;
        
        s_x = x1 ;  s_y = y1 ;s_z = z1 ;
    end
end



%%
index = find(s_x_all{1}(1,:)==0);

figure
for n = 1:numel(distance)
    if material(n)==1
        line_color = 'r';
    else
        line_color = 'g';
    end
    plot(s_z_all{n}(:,index)-sum(distance(1:end-1)),s_y_all{n}(:,index),'color',line_color,'linewidth',1)
    hold on
end
ylim([-aperture*2,aperture*2])
xlim([-sum(distance(1:end-1)),distance(end)])




