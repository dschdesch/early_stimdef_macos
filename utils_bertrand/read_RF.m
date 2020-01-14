clear
%last number is the index in the index of the stimulus in the experiment
D = read(dataset,'F16507',18);

% D = read(dataset,'L16556',62);
% imagesc(a-D.data.thr_probe)


% 2.^linspace(log2(BF/8),log2(BF*8),(6*10)+1);
BF=1000
notchW = 2
floor(BF/(2^(notchW/2)))
ceil(BF*(2^(notchW/2)))

bin_psth=1
stimparapm = D.stimparam;

duration = stimparapm.BurstDur+1

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


count=zeros(1,Nconds);
varcount=zeros(1,Nconds);

for icond=1:Nconds
    vartmp=[];
    for irep=1:Nreps
        train = spks{icond,irep};
        ispk = find(train<=duration);
        count(icond) = count(icond)+length(ispk);
        vartmp(irep)=length(ispk);
    end
    count(icond) = count(icond)/Nreps;
    varcount(icond)=std(vartmp);
end

icond=1;
for iY=1:nY
    for iX=1:nX
        count_mat(iY,iX)=count(icond);
        icond=icond+1;
    end
end

[val,idz_max] = max(count);
display(['BF= ',num2str(Xval(idz_max))])
display(['best dB= ',num2str(Yval(idz_max))])


figure
pcolor(unique(Xval),unique(Yval),count_mat)
set(gca,'xscale','log')
colorbar()
% figure
% mesh(unique(Xval),unique(Yval),count_mat)
% imagesc(count_mat)
% imagesc(unique(Xval),unique(Yval),count_mat)
figure
semilogx(unique(Xval),count_mat)
legend(num2str(unique(Yval)))
