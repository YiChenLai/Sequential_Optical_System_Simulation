function PSF_data = point_spread_function(lambda, aperture, trans_plane_data, propagate_distance)
%%
k0 = (2*pi/lambda);
amp = trans_plane_data.OP;
amp(~isnan(amp))=1; amp(isnan(amp))=0;

trans_plane_data.x(isnan(trans_plane_data.x)) = 0;
trans_plane_data.y(isnan(trans_plane_data.y)) = 0;
trans_plane_data.OP(isnan(trans_plane_data.OP)) = 0;


% y_bound = [min(min(trans_plate_data.y)),max(max(trans_plate_data.y))];
y_bound = [-aperture/2,aperture/2];

Monitor_Boundary = [y_bound(1), y_bound(end), size(trans_plane_data.y,1); ...
    (propagate_distance+propagate_distance*0.3)/200, propagate_distance+propagate_distance*0.3, (propagate_distance+propagate_distance*0.3)/200];   %[Y_Min, Y_Max, Y_Step; Z_Min, Z_Max, Z_Increment]
Monitor_y = linspace(Monitor_Boundary(1,1),Monitor_Boundary(1,2),Monitor_Boundary(1,3));
Monitor_z = Monitor_Boundary(2,1):Monitor_Boundary(2,3):Monitor_Boundary(2,2);

%%

phase = k0*trans_plane_data.OP;
phase_mask = amp.*exp(1i*phase);

Monitor = zeros(length(Monitor_y),length(Monitor_z));
tic
parfor i = 1:length(Monitor_z)
    Monitor_xy = zeros(length(phase_mask),1);
    for ii = 1:length(Monitor_y)
        R = sqrt(Monitor_z(i).^2+(trans_plane_data.y-Monitor_y(ii)).^2+(trans_plane_data.x).^2);
        Monitor_xy(ii) = sum((phase_mask.*exp(1i*k0*R)),'all');
    end
    Monitor(:,i) = Monitor_xy;
end
toc

[~, index_z] = min(abs(Monitor_z-trans_plane_data.dz-propagate_distance));

PSF_data.Monitor_y = Monitor_y;
PSF_data.Monitor_z = Monitor_z;
PSF_data.Intensity = abs(Monitor);
PSF_data.Intensity_normalize = PSF_data.Intensity/max(max(PSF_data.Intensity));
PSF_data.Power = abs(Monitor).^2;
PSF_data.Power_normalize = PSF_data.Power/max(max(PSF_data.Power));
PSF_data.Strehl_ratio = max(max(PSF_data.Power(:,index_z)))/sum(amp,'all').^2;

% [index_y, index_z] = find(Monitor_1_Power_Normalize==1);


