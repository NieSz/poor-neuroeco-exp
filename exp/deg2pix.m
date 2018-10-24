function pix = deg2pix(deg)
pack = evalin('base','[display_info.seat_distance, pix_per_cm]');
seat_distance = pack(1);
pix_per_cm = pack(2);
pix = round(2.*tand(deg./2).*seat_distance.*pix_per_cm);
end