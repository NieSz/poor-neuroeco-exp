% read lines from the serial port instance s into cell array l, but only
% when there are bytes available to read.
%
% 20180131 J Carlin
%
% l = readserial(s)
function l = readserial(s)

l = {};
while get(s,'BytesAvailable')>0
    l{end+1} = fgetl(s);
end