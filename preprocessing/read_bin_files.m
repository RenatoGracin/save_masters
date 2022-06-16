fid = fopen('D:/fft.bin', 'r');
data = fread(fid,inf,'4*uint8=>float32');
% data2 = fread(fid);
fclose(fid);