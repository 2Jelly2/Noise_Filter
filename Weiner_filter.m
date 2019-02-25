function h = Weiner_filter( h_length,desired_signal,observed_signal )
row_number = h_length;
col_number = row_number;

M = col_number;
Rx_c_full = xcorr(observed_signal);
[~,k] = max(Rx_c_full);
Rx_c = Rx_c_full(k:k+M-1);
Rx_c = Rx_c.';

Rdx_c_full = xcorr(desired_signal,observed_signal);
Rdx_c = Rdx_c_full(k:k+M-1);

A = toeplitz(Rx_c,Rx_c);
b = Rdx_c;
h = A\b;
end