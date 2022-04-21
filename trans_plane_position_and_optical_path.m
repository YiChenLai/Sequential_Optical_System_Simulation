function [trans_plane_data] = trans_plane_position_and_optical_path(surface_num, distance, material, Data, L, M, N)
OP = zeros(size(Data.X_2{1,1},1),size(Data.X_2{1,1},2));
for i = 1:surface_num
    OP = OP+sqrt((Data.X_2{2,i}-Data.X_2{1,i}).^2+(Data.Y_2{2,i}-Data.Y_2{1,i}).^2 ...
             +(Data.Z_2{2,i}-Data.Z_2{1,i}).^2)*material(i);
end

x0 = Data.X_2{2,surface_num}; y0 = Data.Y_2{2,surface_num}; z0 = Data.Z_2{2,surface_num};
dz = max(max(z0))-z0;
x1 = x0+(L./N).*dz;
y1 = y0+(M./N).*dz;
z1 = max(max(z0));
OP = OP+sqrt((x1-x0).^2+(y1-y0).^2+(z1-z0).^2)*material(surface_num+1);

trans_plane_data.x = x1;
trans_plane_data.y = y1;
trans_plane_data.z = z1;
trans_plane_data.dz = z1-sum(distance(1:surface_num));
trans_plane_data.OP = OP;


