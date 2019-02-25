function signal=add_noisedata(s,data,fs,fs1,snr)
s=s-mean(s);
sL=length(s);

if fs~=fs1
    x=resample(data,fs,fs1);
else
    x=data;
end

x=x(:);
x=x-mean(x);
xL=length(x);
if xL>=sL
    x=x(1:sL);
else
    x=[x; zeros(sL-xL,1)];
end

Sr=snr;
Es=sum(x.*x);
Ev=sum(s.*s);
a=sqrt(Ev/Es/(10^(Sr/10)));
noise=a*x;
signal=s+noise;