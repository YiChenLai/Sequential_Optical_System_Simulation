function LSF_data = line_spread_function(lambda, aperture, trans_plane_data, focal_plane_position)
%%
k0 = 2*pi/lambda;
center_index = (size(trans_plane_data.y,2)+1)/2;
trans_plane_data.OP(isnan(trans_plane_data.OP)) = 0;
trans_plane_data.y(isnan(trans_plane_data.y)) = 0;

amp = trans_plane_data.OP(:,center_index); amp(amp~=0) = 1;
phase = k0*trans_plane_data.OP(:,center_index);

phase_Mask = amp.*exp(1i*phase);

%%
y = trans_plane_data.y(:,center_index);
% aperture_radius = max(trans_plane_data.y(:,center_index));
aperture_radius = aperture/2;
Monitor_y = linspace(-aperture_radius,aperture_radius,length(y));
% Monitor_y = linspace(-0.2,0.2,length(y));


%%
Distance= focal_plane_position;

Monitor = zeros(length(Monitor_y),1);
% const = 1/(1i*lambda);
parfor i = 1:length(Monitor_y)
%     R = ((Monitor_y(i)-y).^2)/(2*Distance);
%     Monitor(i) = sum((phase_Mask.*exp(1i*k0*R)+Distance),'all');

    R = sqrt(Distance^2+(Monitor_y(i)-y).^2);
    Monitor(i) = sum((phase_Mask.*exp(1i*k0*R)),'all');
%     Monitor(i) = sum((phase_Mask.*exp(1i*k0*R).*Distance./R.^2),'all');
end

LSF_data.Monitor_y = Monitor_y;
LSF_data.Intensity = abs(Monitor);
LSF_data.Intensity_normalize = LSF_data.Intensity/sum(amp,'all');
LSF_data.Power = abs(Monitor).^2;
LSF_data.Power_normalize = LSF_data.Power/sum(amp,'all')^2;
LSF_data.Strehl_ratio = max(LSF_data.Power/sum(amp,'all').^2);
