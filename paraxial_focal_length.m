%% Calculate Back Focal length(BFL) & Effective Focal Length(EFL)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The equation refer to "Introdution to Optics Third Edition" by F. L.
% Pedrotti, L. M. Pedrotti & L. S. Pedrotti 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [BFL, EFL] = paraxial_focal_length(surface_num,distance,material,sur_radius)
M = eye(2,2);

for i = 1:surface_num
    M_traslation = [1, distance(i); 0, 1];
    M_refraction = [1, 0; (material(i)-material(i+1))/(material(i+1)*sur_radius(i)), material(i)/material(i+1)];
    M = M_refraction * M_traslation * M;
end

A = M(1,1); B = M(1,2); C = M(2,1); D = M(2,2);
q = -A/C;
s = (1-A)/C;
f_s = q-s;

BFL = q; EFL = f_s;

