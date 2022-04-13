function [trans_x, trans_y, trans_z] = trans_position(surface_num,Data,L,M,N)
x = Data.X_2{2,surface_num}; y = Data.Y_2{2,surface_num}; z = Data.Z_2{2,surface_num};
dz = max(max(z))-z;
trans_x = x+(L./N).*dz;
trans_y = y+(M./N).*dz;
trans_z = max(max(z));
