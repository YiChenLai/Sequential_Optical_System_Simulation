clc;clear;close all;

% [surface_num,distance,material,aperture] = Parameter_Setting;
surface_num = 0;
distance = 10;
material = 1;
% y_radius = [];
aperture = 2;

%%
line_num = 21;

if mod(line_num,2)==0
    line_num = line_num+1;
end

x = linspace(-aperture/2,aperture/2,line_num);
y = linspace(-aperture/2,aperture/2,line_num);

[S_x,S_y] = meshgrid(x,y);
r = sqrt(S_x.^2+S_y.^2);

S_x(r>aperture/2) = nan; S_y(r>aperture/2) = nan;
S_x = reshape(S_x,1,numel(S_x)); S_y = reshape(S_y,1,numel(S_y));
S_x(isnan(S_x))=[];S_y(isnan(S_y))=[];S_z = zeros(1,numel(S_x));
delta = S_z;
L = S_z; M = S_z; N = ones(1,numel(S_z));

%%
S_z_all = zeros(length(distance)+1,length(S_z));S_x_all = zeros(length(distance)+1,length(S_x));S_y_all = zeros(length(distance)+1,length(S_y));
S_z_all(1,:) = S_z; S_x_all(1,:) = S_x; S_y_all(1,:) = S_y;

for i = 1:length(distance)
    S_z_all(i+1,:) = S_z+N.*distance(i)+delta;
    S_x_all(i+1,:) = S_x+(L./N).*distance(i);
    S_y_all(i+1,:) = S_y+(M./N).*distance(i);
    
end



