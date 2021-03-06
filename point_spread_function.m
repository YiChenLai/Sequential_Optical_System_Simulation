function PSF_data = point_spread_function(lambda, aperture, trans_plane_data, propagate_distance, perspective_switch)
%%
k0 = (2*pi/lambda);
amp = trans_plane_data.OP;
amp(~isnan(amp))=1; amp(isnan(amp))=0;

trans_plane_data.x(isnan(trans_plane_data.x)) = 0;
trans_plane_data.y(isnan(trans_plane_data.y)) = 0;
trans_plane_data.OP(isnan(trans_plane_data.OP)) = 0;

if perspective_switch(1) == 1
%     y_bound = [min(min(trans_plate_data.y)),max(max(trans_plate_data.y))];
    y_bound = [-aperture/2,aperture/2];

    Monitor_Boundary = [y_bound(1), y_bound(end), size(trans_plane_data.y,1); ...
        (propagate_distance+propagate_distance*0.3)/200, propagate_distance+propagate_distance*0.3, (propagate_distance+propagate_distance*0.3)/200];   %[Y_Min, Y_Max, Y_Step; Z_Min, Z_Max, Z_Increment]
    Monitor1_y = linspace(Monitor_Boundary(1,1),Monitor_Boundary(1,2),Monitor_Boundary(1,3));
    Monitor1_z = Monitor_Boundary(2,1):Monitor_Boundary(2,3):Monitor_Boundary(2,2);

    %%

    phase = k0*trans_plane_data.OP;
    phase_mask = amp.*exp(1i*phase);

    Monitor = zeros(length(Monitor1_y),length(Monitor1_z));
    tic
    parfor i = 1:length(Monitor1_z)
        Monitor_xy = zeros(length(phase_mask),1);
        for ii = 1:length(Monitor1_y)
            R = sqrt(Monitor1_z(i).^2+(trans_plane_data.y-Monitor1_y(ii)).^2+(trans_plane_data.x).^2);
            Monitor_xy(ii) = sum((phase_mask.*exp(1i*k0*R)),'all');
        end
        Monitor(:,i) = Monitor_xy;
    end
    toc

    [~, index_z] = min(abs(Monitor1_z-trans_plane_data.dz-propagate_distance));

    PSF_data.Monitor1_y = Monitor1_y;
    PSF_data.Monitor_z = Monitor1_z;
    PSF_data.Intensity = abs(Monitor);
    PSF_data.Intensity_normalize = PSF_data.Intensity/max(max(PSF_data.Intensity));
    PSF_data.Power = abs(Monitor).^2;
    PSF_data.Power_normalize = PSF_data.Power/max(max(PSF_data.Power));
    PSF_data.Strehl_ratio = max(max(PSF_data.Power(:,index_z)))/sum(amp,'all').^2;
end


%% XY plane
if perspective_switch(2) == 1
    %-------------------------------------------------------
    x_bound = [-aperture/2,aperture/2];
    y_bound = [-aperture/2,aperture/2];
    
    Monitor2_x = linspace(x_bound(1),x_bound(end),size(trans_plane_data.x,1));
    Monitor2_y = linspace(y_bound(1),y_bound(end),size(trans_plane_data.y,1));
    %-------------------------------------------------------
    phase = k0*trans_plane_data.OP;
    phase_mask = amp.*exp(1i*phase);
    
    Monitor_xy = zeros(length(Monitor2_x),length(Monitor2_y));
    tic
    for i = 1:length(Monitor2_x)
        parfor ii = 1:length(Monitor2_y)
            R = sqrt(propagate_distance^2+(trans_plane_data.y-Monitor2_y(ii)).^2+(trans_plane_data.x-Monitor2_x(i)).^2);
            Monitor_xy(i,ii) = sum((phase_mask.*exp(1i*k0*R)),'all');
        end
    end
    toc
    
    PSF_data.Monitor2_x = Monitor2_x;
    PSF_data.Monitor2_y = Monitor2_y;
    PSF_data.Intensity_xy = abs(Monitor_xy);
    PSF_data.Intensity_normalize_xy = PSF_data.Intensity_xy/max(max(PSF_data.Intensity_xy));
    PSF_data.Power_xy = abs(Monitor_xy).^2;
    PSF_data.Power_normalize_xy = PSF_data.Power_xy/max(max(PSF_data.Power_xy));
    PSF_data.Strehl_ratio_xy = max(max(PSF_data.Power_xy))/sum(amp,'all').^2;
end


