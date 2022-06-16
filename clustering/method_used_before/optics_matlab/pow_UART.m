% mjerenje potrošnje, samo UART

clear all
instrreset

addpath('C:\Users\Darjan\Desktop\moj_optics\functions_help');

s = serial('COM5','BaudRate',115200);
s.InputBufferSize = 50000;
fopen(s);

%%
reset=1;    
while(1)
    
fprintf(s,'%f\n',reset);
%pause(0.005);
data=str2double(fgetl(s));
printf('data %f',data);
data=0;
reset=reset+1;
end
