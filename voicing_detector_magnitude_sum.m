
function msf = voicing_detector_magnitude_sum(y)

clear msf;

[B, A] = butter(9,.33, 'low');  %.5 or .33?
y1 = filter(B, A, y);

msf = sum(abs(y1));

