load Ws

subplot(311)
plot(Ws(1,:))
subplot(312)
plot(Ws(2,:))

a = Ws(1,1:33482);
b = Ws(2,33483:2*33482);

subplot(313)
plot(b-a)

load Ws2
a2 = Ws2(1,1:33482);
b2 = Ws2(2,33483:2*33482);

figure()
subplot(311)
plot(-Ws2(1,:))

subplot(312)
plot(b2+a)
subplot(313)
plot(a2+a)