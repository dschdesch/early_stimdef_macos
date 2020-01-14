clear
%last number is the index in the index of the stimulus in the experiment
D = read(dataset,'F15040',38);

bin_psth=1
stimparapm = D.stimparam;



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
        ispk = intersect(find(train>=0),find(train<=stimparapm.condBurstDur));
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
        icond=icond+1;
    end
end

Xval(find(Xval==-1))=0;
Xval(find(abs(Xval)==100))=0;
xparam = Xval

figure()
plot(xparam,count_mat,'b','LineWidth',2)
hold on
plot(xparam,count_mat+varcount,':b')
plot(xparam,count_mat-varcount,':b')


