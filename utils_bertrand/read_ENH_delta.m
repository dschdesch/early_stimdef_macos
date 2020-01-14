clear
%last number is the index in the index of the stimulus in the experiment
D = read(dataset,'F15093',90);
oldstim=0

%47
%55
%65,67

dd=50
bin_psth=1

stimparapm = D.stimparam;

start_test=500;
end_test = 700;

delta=stimparapm.delta_T
start_test = start_test+delta;
end_test = end_test+delta;

durT = end_test-start_test;


iCond=stimparapm.Presentation.iCond;
iRep = stimparapm.Presentation.iRep;

Xname = stimparapm.Presentation.X.FieldName;
Xval = stimparapm.Presentation.X.PlotVal;
nX=length(unique(Xval));

Yname = stimparapm.Presentation.Y.FieldName;
Yval = stimparapm.Presentation.Y.PlotVal;
nY=length(unique(Yval));

% NX,NY = stimparapm.Ncond_XY;
Nconds = prod(stimparapm.Ncond_XY);
spks = D.spiketimes;
Nreps = stimparapm.Nrep

count_mat = zeros(nY,nX);

bins = 0:bin_psth:2000;
lPSTH = length(bins);

count=zeros(Nconds);
PSTHs = zeros(Nconds,lPSTH);
for icond=1:Nconds
    for irep=1:Nreps
        train = spks{icond,irep};
%         PSTHs(icond,:)=PSTHs(icond,:)+hist(train,bins);
        if Xval(icond)>0|oldstim~=1
        ispk = intersect(find(train>=start_test(icond)),find(train<=end_test(icond)-dd));
        else
            ispk = find(train<=durT(icond)-dd);
        end
        train = train(ispk);
        PSTHs(icond,:)=PSTHs(icond,:)+hist(train,bins);
        count(icond) = count(icond)+length(train);
        vartmp(irep)=length(train);
    end
    count(icond) = count(icond)/Nreps;
    varcount(icond)=std(vartmp)
end

icond=1
for iY=1:nY
    for iX=1:nX
        count_mat(iY,iX)=count(icond);
        var_mat(iY,iX)=varcount(icond);
        icond=icond+1;
    end
end



Yval = unique(Yval)

figure()
subplot(211)
% plot(PSTHs')
plot(Yval,(count_mat(:,2)-count_mat(:,1))/sqrt(0.5*(varcount(:,2).^2+varcount(:,1).^2)),'LineWidth',2)

subplot(212)
% plot(Xval,count_mat)
plot(Yval,count_mat(:,2),'r','LineWidth',2)
hold on
plot(Yval,count_mat(:,2)+varcount(:,2),':r')
plot(Yval,count_mat(:,2)-varcount(:,2),':r')

plot(Yval,count_mat(:,1),'b','LineWidth',2)
plot(Yval,count_mat(:,1)+varcount(:,1),':b')
plot(Yval,count_mat(:,1)-varcount(:,1),':b')

count_mat

% imagesc(count_mat)

