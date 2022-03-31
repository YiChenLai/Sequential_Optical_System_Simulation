function [surface_num,distance,material,aperture] = Parameter_Setting

promt = 'Surface number = ';
surface_num = input(promt);

distance = zeros(surface_num+1,1);
material = zeros(surface_num+1,1);

promt = 'Distance: Obj to S1 = ';
distance(1) = input(promt);
for i = 1:surface_num-1
    promt = ['Distance: S',num2str(i),' to S',num2str(i+1),' = '];
    distance(1+i) = input(promt); 
end
promt = ['Distance: S',num2str(i+1),' to Img = '];
distance(end) = input(promt);

promt = 'Material: Obj to S1 = ';
material(1) = input(promt);
for i = 1:surface_num-1
    promt = ['Material: S',num2str(i),' to S',num2str(i+1),' = '];
    material(1+i) = input(promt); 
end
promt = ['Material: S',num2str(i+1),' to Img = '];
material(end) = input(promt);

promt = 'Aperture size = ';
aperture = input(promt);