clear
%last number is the index in the index of the stimulus in the experiment
D = read(dataset,'F16551',17)
oldstim=0


bin_psth=1
stimparapm = D.stimparam;

dd=100
start_test=stimparapm.condBurstDur;
end_test = stimparapm.condBurstDur+stimparapm.testBurstDur;

delta=stimparapm.delta_T
start_test = start_test+delta+3;
end_test = end_test+delta+3;

durT = end_test-start_test;


iCond=stimparapm.Presentation.iCond;
iRep = stimparapm.Presentation.iRep;

Xname = stimparapm.Presentation.X.FieldName;
Xval = stimparapm.Presentation.X.PlotVal;
nX=length(unique(Xval));

Yname = stimparapm.Presentation.Y.FieldName;
Yval = stimparapm.Presentation.Y.PlotVal;
nY=length(unique(Yval));

Nconds = prod(stimparapm.Ncond_XY);
spks = D.spiketimes;
Nreps = stimparapm.Nrep

count_mat = zeros(nY,nX);

bins = 0:bin_psth:2000;
lPSTH = length(bins);

count=zeros(1,Nconds);
varcount=zeros(1,Nconds);
PSTHs = zeros(Nconds,lPSTH);
for icond=1:Nconds
    vartmp=[];
    for irep=1:Nreps
        train = spks{icond,irep};
%         PSTHs(icond,:)=PSTHs(icond,:)+hist(train,bins);
            if oldstim~=1
            ispk = intersect(find(train>=start_test),find(train<=end_test-dd));
            else
            ispk = find(train<=durT-dd);
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
        var_mat(iY,iX)=varcount(icond)
        icond=icond+1;
    end
end


figure(3)
subplot(211)
plot(unique(Yval),(count_mat(:,2)-count_mat(:,1))./sqrt(0.5*(var_mat(:,2).^2+var_mat(:,1).^2)),'b')

subplot(212)
% plot(Xval,count_mat)
plot(unique(Yval),count_mat(:,2),'r','LineWidth',2)
hold on
plot(unique(Yval),count_mat(:,2)+var_mat(:,2),':r')
plot(unique(Yval),count_mat(:,2)-var_mat(:,2),':r')


plot(unique(Yval),count_mat(:,1),'b','LineWidth',2)
plot(unique(Yval),count_mat(:,1)+var_mat(:,1),':b')
plot(unique(Yval),count_mat(:,1)-var_mat(:,1),':b')

% imagesc(count_mat)

