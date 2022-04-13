function Data = data_reshape(s_x_all,s_y_all,s_z_all,cross_diameter_num)
for i = 1:numel(s_x_all)
    Data.X_1{i} = reshape(s_x_all{i}(1:cross_diameter_num,:),1,cross_diameter_num^2);
    Data.X_1{i}(2,:) = reshape(s_x_all{i}(cross_diameter_num+1:end,:),1,cross_diameter_num^2);
    Data.Y_1{i} = reshape(s_y_all{i}(1:cross_diameter_num,:),1,cross_diameter_num^2);
    Data.Y_1{i}(2,:) = reshape(s_y_all{i}(cross_diameter_num+1:end,:),1,cross_diameter_num^2);
    Data.Z_1{i} = reshape(s_z_all{i}(1:cross_diameter_num,:),1,cross_diameter_num^2);
    Data.Z_1{i}(2,:) = reshape(s_z_all{i}(cross_diameter_num+1:end,:),1,cross_diameter_num^2);
    
    Data.X_2{1,i} = s_x_all{i}(1:cross_diameter_num,:);
    Data.X_2{2,i} = s_x_all{i}(cross_diameter_num+1:end,:);
    Data.Y_2{1,i} = s_y_all{i}(1:cross_diameter_num,:);
    Data.Y_2{2,i} = s_y_all{i}(cross_diameter_num+1:end,:);
    Data.Z_2{1,i} = s_z_all{i}(1:cross_diameter_num,:);
    Data.Z_2{2,i} = s_z_all{i}(cross_diameter_num+1:end,:);
end