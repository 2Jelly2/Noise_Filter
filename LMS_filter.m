function y_out = LMS_filter( h_length, h, Ntimes, y_out, err2, counter, s, N, r1, miu )
for kk = 1:Ntimes
   for k = h_length : N
       idx = k: -1 :(k-h_length+1);
       r1_in_sub = r1(idx);
       filter_out = h.' * r1_in_sub;
       y_out(k) = filter_out;
       dk = s(k);
       err = dk - filter_out;
       err2(counter) = err^2;
       h = h + miu * err * r1_in_sub;
       counter = counter + 1;
    end
end
end

