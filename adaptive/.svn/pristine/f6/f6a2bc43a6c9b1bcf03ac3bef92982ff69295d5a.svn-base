function S = THRcurve_tckl(P, Proc, Freq, BurstDur, ISI, MinSPL, MaxSPL, StartSPL, StepSPL, DAchan, SpikeCrit, MaxNpres)
% THRcurve - adaptive measurement of tonal threshold for a range of
% frequencies
% Usage:
%   THRcurve(P, ToneFreq, BurstDur, MinSPL, MaxSPL, StartSPL,
%   StepSPL, DAchan, MaxNpres);

% Create dataset
DS = dataset(P.Experiment, P, [], P.GUIhandle, 'Dataset');

% Load circuit
dev = P.Experiment.Audio.Device;
Fsam = sys3loadCircuit('THR_TCKL', dev, 110);
sys3run(dev); % in fact still halted until setting 'Run' to 1

% Set non-changing parameters
sys3setpar(BurstDur, 'BurstDur', dev);
NonBurstDur = ISI-BurstDur;
if NonBurstDur < 0
    GUImessage(figh,'Burst duration exceeds ISI.', ...
        'error', {'BurstDur', 'ISI'});
else
    sys3setpar(NonBurstDur, 'NonBurstDur', dev);
end

% Determine spontaneous rate criterion
[dum, SR] = local_getSpikeCrit(dev, BurstDur,P.rep_for_SR);

if isequal(Proc,'Geisler'), SpikeCrit = dum; end;
SRStr = ['SR = ' num2str(SR) ' spikes/s'];
THRStr = '';

% % Create plot
% Thr = nan(size(Freq));
% figure;
% h = semilogx(Freq,Thr,'-sb','YDataSource','Thr');
% x = logspace(log10(min(Freq)),log10(max(Freq)),10);
% set(gca,'xtick',x);
% set(gca,'xticklabel',x);
% xlim([min(x) max(x)]);
% ylim([MinSPL MaxSPL]);
% xlabel('frequency (Hz)','fontsize',10);
% ylabel('threshold (dB SPL)','fontsize',10);
% title(IDstring(DS, 'full'),'fontsize', 12, 'fontweight', 'bold', 'interpreter', 'none');
% text(0.1, 0.1, SRStr, 'units', 'normalized', 'color', 'r', 'fontsize', 12 , 'interpreter', 'latex');
% ht = text(0.1, 0.2, THRStr, 'units', 'normalized', 'color', 'r', 'fontsize', 12 , 'interpreter', 'latex');
% timestr = datestr(clock,30);

% Determine order
ifreqs = 1:numel(Freq);
if strcmpi(P.Order(1),'R')
    ifreqs = fliplr(ifreqs);
end

% Calculate # SPLs per Freq
NbSPL = size(P.LinAmp,1)/size(P.Freq,1);

% Set starting SPL
dynStartSPL = StartSPL;

thr_data = load('thr')
xv =  [thr_data.freqs(1);thr_data.freqs;thr_data.freqs(end);thr_data.freqs(1)];
yv =  [80;thr_data.thrs;80;thr_data.thrs(1)];

nconds=0;
for ifreq_masker=1:P.NFreq_masker;
    for iSPL_masker=1:P.NSPL_masker;
        
        freq_masker = P.Freq_masker(ifreq_masker);
        SPL_masker = P.dB_masker(iSPL_masker);
        if inpolygon(freq_masker,SPL_masker,xv,yv)==0;
            nconds=nconds+1;
        end
    end
end

[thr_probe,i] = min(yv);
cf = xv(i);

[num2str(nconds),' to be done out of ',num2str(P.NFreq_masker*P.NSPL_masker)]
thrs = nan*zeros(P.NSPL_masker,P.NFreq_masker);

% figure()
% h = imagesc(P.Freq_masker,P.dB_masker,thrs)
% set(gca,'XScale','log')
% set(gca,'YDir','normal')
% xlim([min(P.Freq_masker),max(P.Freq_masker)])
% ylim([min(P.dB_masker),max(P.dB_masker)])
% hold on
% semilogx(xv,yv,'w','linewidth',2)
% x = P.Freq_masker;
% y=P.dB_masker;
% for i=1:length(x)
% for j=1:length(y)
% in = inpolygon(x(i),y(j),xv,yv);
% if in==0
%     semilogx(x(i),y(j),'xw')
% end
% end
% end





icount=1;
% thrs(10,10)=1;
% refreshdata(h,'caller') % Evaluate y in the function workspace
% drawnow

flag=0

for ifreq_masker=1:P.NFreq_masker;
    for iSPL_masker=1:P.NSPL_masker;
        
        freq_masker = P.Freq_masker(ifreq_masker);
        SPL_masker = P.dB_masker(iSPL_masker);
        
        if 0%inpolygon(freq_masker,SPL_masker,xv,yv)==1
            GUImessage(gcg, ['passing ', num2str(freq_masker),'Hz ',num2str(SPL_masker),'dB ',num2str(icount),' out of  ',num2str(icount)]);
        else
%             GUImessage(gcg, ['measuring ', num2str(freq_masker),'Hz ',num2str(SPL_masker),'dB ']);
            %set masker to right SPL and freq
            sys3setpar(freq_masker, 'Tone2Freq', dev);
            if strcmpi(DAchan(1),'L')
                sys3setpar(P.LinAmp_masker(icount,1), 'Tone2AmpL', dev);
                sys3setpar(0, 'Tone2AmpR', dev);
            elseif strcmpi(DAchan(1),'R')
                sys3setpar(P.LinAmp_masker(icount,end), 'Tone2AmpR', dev);
                sys3setpar(0, 'Tone2AmpL', dev);
            elseif strcmpi(DAchan(1),'B')
                sys3setpar(P.LinAmp_masker(icount,1), 'Tone2AmpL', dev);
                sys3setpar(P.LinAmp_masker(icount,end), 'Tone2AmpR', dev);
            end
            
            % STOP button action
            if MyFlag('THRstop'),
                save(DS);
                flag=1;
                break; % from loop
            end

            % Get correct LinAmp and Attenuations
            SPL = P.SPLs;
            LinAmp = P.LinAmp;
            Attenuation = P.Attenuations;
%             SpikeCrit = 100;
            S = feval(['THRrec_' Proc '_tckl'], dev, P.Experiment, Freq, BurstDur, ...
                MinSPL, MaxSPL, dynStartSPL, StepSPL, DAchan, SpikeCrit, MaxNpres, ...
                SPL, Attenuation, LinAmp, P.GUIhandle,P.ISI);
            
            if ~isnan(S.Thr),
                if isequal(Proc,'Geisler')
                    dynStartSPL = S.Thr - 2*StepSPL;
                else
                    dynStartSPL = S.Thr;
                end
            end
            thrs(iSPL_masker,ifreq_masker) =  S.Thr;
            % Attempt to force resetting the timing of play action
            sys3halt(dev);
            sys3run(dev);
            close all
            figure(1)
            title([freq_masker,SPL_masker])
            %             h = imagesc(P.Freq_masker,P.dB_masker,thrs)
            %             h = surf(P.Freq_masker,P.dB_masker,thrs)
            h = pcolor(P.Freq_masker,P.dB_masker,thrs);
            set(gca,'XScale','log')
            set(gca,'YDir','normal')
            xlim([min(P.Freq_masker),max(P.Freq_masker)])
            ylim([min(P.dB_masker),max(P.dB_masker)])
            hold on
            semilogx(xv,yv,'r','linewidth',2)
            x = P.Freq_masker;
            y=P.dB_masker;
            for i=1:length(x)
                for j=1:length(y)
                    in = inpolygon(x(i),y(j),xv,yv);
                    if in==0
                        semilogx(x(i),y(j),'xr')
                    end
                end
            end
            
            
        end
        DS = addResults(DS,P.Freq_masker,P.dB_masker,thrs,thr_probe,cf,thr_data,SR);
        % keep old save format as backup
        %         save([folder(current(experiment)),'\THR_',timestr,'.mat'],'S','-mat');
        icount=icount+1;
    end
    if(flag==1)
        break
    end
end
sys3halt(dev);
save(DS);

end

function [SpikeCrit, SR] = local_getSpikeCrit(dev, BurstDur,rep_for_SR)
GUImessage(gcg, 'Measuring spontaneous rate.');
NbSpikes = zeros(1,rep_for_SR);
Nrep = ceil(rep_for_SR*1e3/(BurstDur+10));
for i=1:Nrep
    sys3setpar(0, 'ToneAmpL', dev);
    sys3setpar(0, 'ToneAmpR', dev);
    sys3setpar(0, 'ToneFreq', dev);
    sys3setpar(1, 'Run', 'RX6');
    pause((BurstDur+10)/1e3);
    sys3setpar(0, 'Run', 'RX6');
    NbSpikes(i) = sys3getpar('NbSpikes', dev);
end
SpikeCrit = round(mean(NbSpikes) + std(NbSpikes)) + 1.5;
SR = mean(NbSpikes)/((BurstDur+10)/1e3);
end