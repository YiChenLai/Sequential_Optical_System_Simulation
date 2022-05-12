classdef display_tools
    methods (Static)
        function view_lens(Lens, Data, display_line, viewplane)
            if mod(display_line,2) == 0
                display_line = display_line+1;
            end
            
            if display_line > size(Data.X_1{1},2)
                display_line = size(Data.X_1{1},2);
            end
            
            switch viewplane
                case {'3D',3}
                    display_line_position_x = linspace(-Lens.aperture/2,Lens.aperture/2,display_line);
                    display_line_position_y = linspace(-Lens.aperture/2,Lens.aperture/2,display_line);
                    [dlpx, dlpy] = meshgrid(display_line_position_x,display_line_position_y);
                    dlpx = reshape(dlpx,1,numel(dlpx)); dlpy = reshape(dlpy,1,numel(dlpy));
                    index_x = [];                       index_y = [];
                    
                    for i = 1:numel(dlpx)
                        id_x = find(Data.X_1{1}(2,:) == dlpx(i));  id_y = find(Data.Y_1{1}(2,:) == dlpy(i));
                        index_x = [index_x, id_x];                 index_y = [index_y, id_y];
                    end
                    index = intersect(index_x,index_y);
                    
                    figure('units','normalized','outerposition',[0 0 1 1],'color','k')
                    for n = 1:numel(Lens.distance)
                        if Lens.material(n)==1
                            line_color = 'g';        lin_wid = 0.1;
                        else
                            line_color = [.5 .5 .5]; lin_wid = 1;
                        end
                        plot3(Data.Z_1{n}(:,index)-sum(Lens.distance(1:Lens.surface_num)),Data.X_1{n}(:,index),Data.Y_1{n}(:,index), ...
                            'color',line_color,'linewidth',lin_wid)
                        hold on
                    end
                    
                    xlim([-sum(Lens.distance(1:Lens.surface_num)),sum(Lens.distance(Lens.surface_num+1:end))])
                    ylim([-Lens.aperture*1.2/2,Lens.aperture*1.2/2])
                    axis equal; grid on; xlabel('z (mm)'); ylabel('x (mm)'); zlabel('y (mm)'); title('View Lens')
                  %% Lens Drawing
                    x = linspace(-Lens.aperture*1.2/2,Lens.aperture*1.2/2,1001); y = linspace(-Lens.aperture*1.2/2,Lens.aperture*1.2/2,1001);
                    [x, y] = meshgrid(x,y);
                    r = sqrt(x.^2+y.^2);
                    x(r>Lens.aperture*1.2/2) = nan; y(r>Lens.aperture*1.2/2) = nan; r(r>Lens.aperture*1.2/2) = nan;
                    
                    spher_z = @(r,R) r.^2./(R*(1+sqrt(1-(r.^2/R.^2)))); % Spherical surface
                    
                    c(:,:,1) = ones(size(x,1));c(:,:,2) = ones(size(x,1));c(:,:,3) = ones(size(x,1));   % color for surf
                    
                    for i = 1:Lens.surface_num
                        z = spher_z(r,Lens.y_radius(i));
                        surf(z-sum(Lens.distance(1:Lens.surface_num))+sum(Lens.distance(1:i)),x,y,c,...
                            'EdgeColor', 'none', 'FaceLighting','phong', 'FaceColor', 'interp', 'FaceAlpha', 0.5, ...
                            'AmbientStrength', 0., 'SpecularStrength', 1 );
                        hold on
                    end
                    hold off
                    
                case {'xz','XZ',1}
                    off_axis_data = Data.Y_1;
                    on_axis_data = Data.X_1;
                    label_name = 'x';
                    
                    propagate_axis_data = Data.Z_1;

                    on_axis_index = find(off_axis_data{1}(2,:)==0);   % find on-axis data index
                    Lens.aperture_radius = Lens.aperture/2;
                    display_line_position = linspace(-Lens.aperture_radius,Lens.aperture_radius,display_line);
                    display_index = [];
                    
                    for n = 1:display_line
                        inx = find(on_axis_data{1}(2,:) == display_line_position(n)); % find data
                        display_index = [display_index,inx];
                    end
                    index = intersect(on_axis_index,display_index);
                    
                    figure('units','normalized','outerposition',[0 0 1 1],'color','k')
                    for n = 1:numel(Lens.distance)
                        if Lens.material(n)==1
                            line_color = 'g';
                            lin_wid = 0.5;
                        else
                            line_color = [.9 .9 .9];
                            lin_wid = 3;
                        end
                        plot(propagate_axis_data{n}(:,index)-sum(Lens.distance(1:Lens.surface_num)),on_axis_data{n}(:,index), ...
                            'color',line_color,'linewidth',lin_wid)
                        hold on
                    end

                    axis equal; grid on; xlabel('z (mm)'); ylabel([label_name,' (mm)']); title('View Lens')
                    xlim([-sum(Lens.distance(1:Lens.surface_num)),sum(Lens.distance(Lens.surface_num+1:end))])
                    ylim([-Lens.aperture*1.2/2,Lens.aperture*1.2/2])
                  %% Lens Drawing
                    on_axis = linspace(-Lens.aperture*1.2/2,Lens.aperture*1.2/2,1001);
                    spher_z = @(r,R) r.^2./(R*(1+sqrt(1-(r.^2/R.^2)))); % Spherical surface
                    for i = 1:Lens.surface_num
                        z = spher_z(on_axis,Lens.y_radius(i));
                        plot(z-sum(Lens.distance(1:Lens.surface_num))+sum(Lens.distance(1:i)),on_axis,':','color','w')
                        hold on
                    end
                    hold off
                    
                case {'yx','YZ',2}
                    off_axis_data = Data.X_1;
                    on_axis_data = Data.Y_1;
                    label_name = 'y';

                    propagate_axis_data = Data.Z_1;

                    on_axis_index = find(off_axis_data{1}(2,:)==0);   % find on-axis data index
                    Lens.aperture_radius = Lens.aperture/2;
                    display_line_position = linspace(-Lens.aperture_radius,Lens.aperture_radius,display_line);
                    display_index = [];
                    
                    for n = 1:display_line
                        inx = find(on_axis_data{1}(2,:) == display_line_position(n)); % find data
                        display_index = [display_index,inx];
                    end
                    index = intersect(on_axis_index,display_index);
                    
                    figure('units','normalized','outerposition',[0 0 1 1],'color','k')
                    for n = 1:numel(Lens.distance)
                        if Lens.material(n)==1
                            line_color = 'g';
                            lin_wid = 0.5;
                        else
                            line_color = [.9 .9 .9];
                            lin_wid = 3;
                        end
                        plot(propagate_axis_data{n}(:,index)-sum(Lens.distance(1:Lens.surface_num)),on_axis_data{n}(:,index), ...
                            'color',line_color,'linewidth',lin_wid)
                        hold on
                    end
                    axis equal; grid on; xlabel('z (mm)'); ylabel([label_name,' (mm)']); title('View Lens')
                    xlim([-sum(Lens.distance(1:Lens.surface_num)),sum(Lens.distance(Lens.surface_num+1:end))])
                    ylim([-Lens.aperture*1.2/2,Lens.aperture*1.2/2])
                  %% Lens Drawing
                    on_axis = linspace(-Lens.aperture*1.2/2,Lens.aperture*1.2/2,1001);
                    spher_z = @(r,R) r.^2./(R*(1+sqrt(1-(r.^2/R.^2)))); % Spherical surface
                    for i = 1:Lens.surface_num
                        z = spher_z(on_axis,Lens.y_radius(i));
                        plot(z-sum(Lens.distance(1:Lens.surface_num))+sum(Lens.distance(1:i)),on_axis,':','color','w')
                        hold on
                    end
                    hold off
            end
            pause(0.01)
        end
        
        function spot_diagram(Data)
            figure('color','k')
            plot(Data.X_1{end}(2,:),Data.Y_1{end}(2,:),'.')
            axis equal; title('Spot Diagram')
            pause(0.01)
        end
        
        function transmission_plane(trans_plane_data)
            figure('color','k')
            pcolor(trans_plane_data.x,trans_plane_data.y,trans_plane_data.OP-min(trans_plane_data.OP,[],'all'))
            title('Transmission Optical Path Difference')
            axis equal; shading flat; colorbar; colormap('jet')
            pause(0.01)
        end
        
        function line_spread_function(LSF_data,diffra_limit)
            figure('color','k')
            plot(LSF_data.Monitor_y,LSF_data.Power_normalize,'linewidth',.5,'color',[0.93,0.69,0.13])
            hold on
            plot(diffra_limit.y,diffra_limit.I,':','linewidth',.5,'color','w')
            title('Line Spread Function',['Strehl Ratio = ',num2str(LSF_data.Strehl_ratio)])
            grid on
            ax = gca; ax.GridColor = [0.32 0.32 0.32];
            pause(0.01)
        end
        
        function point_spread_function(Switch,PSF_data,trans_plane_data,focal_plane_position)
            if Switch(1)==1
                plot_z = PSF_data.Monitor_z-trans_plane_data.dz;
                [~, index_z_1] = find(PSF_data.Intensity_normalize==1);
                [~, index_z_2] = min(abs(plot_z-focal_plane_position));
                disp(['Best Focus Plane = ',num2str(plot_z(index_z_1)),' mm'])
                
                figure('color','k')
                p1 = pcolor(plot_z,PSF_data.Monitor1_y,PSF_data.Power_normalize);
                p2 = line([plot_z(index_z_1) plot_z(index_z_1)],[PSF_data.Monitor1_y(1) PSF_data.Monitor1_y(end)], ...
                    'color','w','linewidth',0.5,'linestyle',':');
                p3 = line([plot_z(index_z_2) plot_z(index_z_2)],[PSF_data.Monitor1_y(1) PSF_data.Monitor1_y(end)], ...
                    'color','y','linewidth',0.5,'linestyle','-');
                title('Point Spread Function YZ',['Best Focus Plane = ',num2str(plot_z(index_z_1)),' mm'])
                legend([p2, p3],'Best Focus Plane','Focus Plane','Location','northwest','NumColumns',1)
                colormap('jet'); shading interp; xlabel('z (mm)'); ylabel('y (mm)'); colorbar
                pause(0.01)
            end
            %%
            if Switch(2)==1
                figure('color','k')
                surf(PSF_data.Monitor2_x,PSF_data.Monitor2_y,PSF_data.Power_normalize_xy)
                title('Point Spread Function XY',['Strehl Ratio = ',num2str(PSF_data.Strehl_ratio_xy)])
                colormap('jet'); shading interp; xlabel('x (mm)'); ylabel('y (mm)'); colorbar
                pause(0.01)
            end
        end
        
        function MTF(Lens,LSF_data,diffra_limit,ang_y)
            LSF = LSF_data.Power;
            OTF = fftshift(fft(LSF));
            MTF = abs(OTF);
            MTF = MTF./max(MTF);
            size = length(MTF);
            D = Lens.aperture;
            a = linspace(-size/2,size/2,size);
            f = a*(1/D);

            figure('color','k')
            plot(diffra_limit.f,diffra_limit.MTF',':','linewidth',.5,'color','w')
            hold on
            plot(f,MTF,'linewidth',.5,'color',[0.93,0.69,0.13])
            xlim([0,diffra_limit.cutoff_freq])
            title('Diffraction MTF')
            xlabel('cycles / mm')
            ylabel('Modulation')
            grid on
            legend('Diffraction Limit',['Ang ',num2str(ang_y),' degree'])
            ax = gca;
            ax.GridColor = [0.32 0.32 0.32];
            pause(0.01)
        end
    end
end