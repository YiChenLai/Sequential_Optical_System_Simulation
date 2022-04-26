function diffra_limit = diffraction_limit(lambda,aperture,BFL,EFL,focal_plane_position)

z = focal_plane_position+(EFL-BFL);
size = round(2*aperture^2/(lambda*z))*2*10;
if mod(size,2)==0
    size = size+1;
end

y = linspace(-aperture/2,aperture/2,size);
f_number = z/aperture;
cutoff_freq = 1/(lambda*f_number);

theata = atan(aperture/2/z);
theata_all = linspace(-theata,theata,size);
I = (sin((aperture/2)*2*pi*sin(theata_all)./lambda)./((aperture/2)*2*pi*sin(theata_all)./lambda)).^2;
I(isnan(I)) = 1;
diffra_limit.I = I;

LSF = I;
OTF = fftshift(fft(LSF));
MTF = abs(OTF);
MTF = MTF./max(MTF);


a = linspace(-size/2,size/2,size);
f = a*(1/aperture);

diffra_limit.MTF = MTF;
diffra_limit.f = f;
diffra_limit.y = y;
diffra_limit.cutoff_freq = cutoff_freq;

% figure
% plot(y,I,'linewidth',.5,'color','w')
% grid on
% ax = gca;
% ax.GridColor = [0.32 0.32 0.32];
% 
% figure
% plot(f,MTF',':','linewidth',.5,'color','w')
% xlim([0,cutoff_freq])
% xlabel('cycles / mm')
% ylabel('MTF')
% grid on
% ax = gca;
% ax.GridColor = [0.32 0.32 0.32];
