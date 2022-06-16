% Returns positions of bits of input number that are 1.
function bin_one_position = Get_High_Bit_Positions(number)
% Assumed that number has less then 1 byte of data.
arguments
    number (1,1) {mustBeInteger(number), mustBeLessThanOrEqual(number,255)}
end
    bin_one_position = find(flip(str2num(dec2bin(number,8)'),1)>0)';
end