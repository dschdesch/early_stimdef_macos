function freqs = freqs_harm(BF,minf,maxf)

n=round(BF/minf);
F0=round(BF/n);


freqs(1)=F0;
last=F0;
i=2;
while last<maxf
%  i
    freqs(i)=freqs(i-1)+F0;
    last=freqs(i);
    i=i+1;
end