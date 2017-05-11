
clear all
load thr

xv =  [freqs;freqs(1)];
yv =  [thrs;thrs(1)];
plot(xv,yv)

x = 500:100:2000;
y=60:5:80;
hold on
for i=1:length(x)
for j=1:length(y)
in = inpolygon(x(i),y(j),xv,yv);
if in==0
    plot(x(i),y(j),'x')
end
end
end