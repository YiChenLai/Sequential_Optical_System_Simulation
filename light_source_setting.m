function [s_x, s_y, s_z, L, M, N] = light_source_setting(aperture,distance,cross_diameter_num,ang_x,ang_y)
if mod(cross_diameter_num,2)==0
    cross_diameter_num = cross_diameter_num+1;
end

x = linspace(-aperture/2,aperture/2,cross_diameter_num);
y = linspace(-aperture/2,aperture/2,cross_diameter_num);

[s_x,s_y] = meshgrid(x,y);
r = sqrt(s_x.^2+s_y.^2);

s_x(r>aperture/2) = nan; s_y(r>aperture/2) = nan;
% s_x = reshape(s_x,1,numel(s_x)); s_y = reshape(s_y,1,numel(s_y));
% s_x(isnan(s_x))=[]; s_y(isnan(s_y))=[]; 
s_z = zeros(size(s_x,1),size(s_x,2));
L = ones(size(s_x,1),size(s_x,2))*sind(ang_x); M = ones(size(s_x,1),size(s_x,2))*sind(ang_y); N = sqrt(1-((L.^2)+(M.^2)));



if ang_x ~= 0 || ang_y ~= 0
    s_x = s_x+(L./N).*(-distance(1));
    s_y = s_y+(M./N).*(-distance(1));
end