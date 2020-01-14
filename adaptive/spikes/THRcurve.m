function S = THRcurve(P, Proc, Freq, BurstDur, ISI, MinSPL, MaxSPL, StartSPL, StepSPL, DAchan, SpikeCrit, MaxNpres, custom_SR)
% THRcurve - adaptive measurement of tonal threshold for a range of
% frequencies
% Usage:
%   THRcurve(P, ToneFreq, BurstDur, MinSPL, MaxSPL, StartSPL,
%   StepSPL, DAchan, MaxNpres);
persistent thr_fig
global open_figures
% Create dataset
DS = dataset(P.Experiment, P, [], P.GUIhandle, 'Dataset');
if isfield(P,'ds_info') 
    ds_info = P.ds_info;
    if ~isempty(ds_info)
        DS = AddDsInfo(DS,ds_info);
        upload(DS);
    else
%         local_GUImode(hdashboard, 'Ready');
%         GUImessage(hdashboard, 'Recording Interrupted');
        return;
    end

end
% Load circuit
dev = P.Experiment.Audio.Device;
Fsam = sys3loadCircuit('THR', dev, 110);
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
% Set the attenuators at 60 dB
SetAttenuators(P.Experiment, 60);
% Determine spontaneous rate criterion
if custom_SR == -1
    [dum, SR] = local_getSpikeCrit(dev, BurstDur,ISI);
    SR_duration = 15000; %ms
    SR_duration_unit = 'ms';
    SR_BurstDur = 50;
    SR_BurstDur_unit = 'ms';
    SR_ISI = 100;
    SR_ISI_unit = 'ms'
    SR_unit = 'Spikes/sec';
    DS = setSR(DS, CollectInStruct(SR, SR_unit, SR_ISI, SR_ISI_unit, SR_BurstDur, ...
    SR_BurstDur_unit, SR_duration, SR_duration_unit));
else
    SR = custom_SR;
    SR_info = 'Custom/preselected SR';
    SR_unit = 'Spikes/sec';
    DS = setSR(DS, CollectInStruct(SR, SR_info,SR_unit));
    dum = SR; % TODO: Should be the SpikeCriterion
end

% Reset the DSP program
pause(10);
if isequal(Proc,'Geisler'), SpikeCrit = dum; end;
if SpikeCrit == 0, SpikeCrit = 1; end
SRStr = ['SR = ' num2str(SR) ' spikes/s'];
THRStr = '';
% Create plot
Thr = nan(size(Freq));
if isempty(thr_fig) || ~ishandle(thr_fig)
    thr_fig = figure;
    open_figures(end+1) = thr_fig;
else
   figure(thr_fig);
   clf;
end
h = semilogx(Freq,Thr,'-sb','YDataSource','Thr');
x = logspace(log10(min(Freq)),log10(max(Freq)),10);
set(gca,'xtick',x); 
set(gca,'xticklabel',x);
xlim([min(x) max(x)]);
ylim([MinSPL MaxSPL]);
xlabel('frequency (Hz)','fontsize',10);
ylabel('threshold (dB SPL)','fontsize',10);
title(IDstring(DS, 'full'),'fontsize', 12, 'fontweight', 'bold', 'interpreter', 'none');
text(0.1, 0.1, SRStr, 'units', 'normalized', 'color', 'r', 'fontsize', 12 , 'interpreter', 'latex');
ht = text(0.1, 0.2, THRStr, 'units', 'normalized', 'color', 'r', 'fontsize', 12 , 'interpreter', 'latex');
timestr = datestr(clock,30);

% Determine order
ifreqs = 1:numel(Freq);
if strcmpi(P.Order(1),'R')
    ifreqs = fliplr(ifreqs);    
end

% Calculate # SPLs per Freq
NbSPL = size(P.LinAmp,1)/size(P.Freq,1);

% Set starting SPL
dynStartSPL = StartSPL;

for ifreq=ifreqs,
    GUImessage(gcg, ['Measuring threshold at frequency ', num2str(round(Freq(ifreq))) ' Hz']);
    % STOP button action
    if MyFlag('THRstop'),
        save(DS);
        break; % from loop
    end
    ic = (1+(ifreq-1)*NbSPL:ifreq*NbSPL)';
    % Get correct LinAmp and Attenuations
    SPL = P.SPLs;
    LinAmp = P.LinAmp(ic,:);
    Attenuation = P.Attenuations(ic,:);
    if ~strcmp(Proc,'Marcel');
        S(ifreq) = feval(['THRrec_' Proc], dev, P.Experiment, Freq(ifreq), BurstDur, ...
            MinSPL, MaxSPL, dynStartSPL, StepSPL, DAchan, SpikeCrit, MaxNpres, ...
            SPL, Attenuation, LinAmp, P.GUIhandle,P.ISI);
    else
        S(ifreq) = feval(['THRrec_' Proc], dev, P.Experiment, Freq(ifreq), BurstDur, ...
            MinSPL, MaxSPL, dynStartSPL, StepSPL, DAchan, SpikeCrit, MaxNpres, ...
            SPL, Attenuation, LinAmp, P.GUIhandle);
    end
    if ~isnan(S(ifreq).Thr),
        if isequal(Proc,'Geisler')
            dynStartSPL = S(ifreq).Thr - 2*StepSPL;
        else
            dynStartSPL = S(ifreq).Thr;
        end
    end
    Thr(ifreq) = S(ifreq).Thr;
    % Attempt to force resetting the timing of play action
    sys3halt(dev); 
    sys3run(dev);
    % Show THR and CF on plot
    [THR, imin] = min(Thr);
    THRStr = ['THR = ' num2str(THR) ' dB SPL @ ' num2str(round(Freq(imin))) ' Hz'];
    set(ht,'String',THRStr);
    % Refresh plot
    refreshdata(h,'caller') % Evaluate y in the function workspace
    drawnow
    % save data
    DS = addThr(DS,Thr);
    % keep old save format as backup
    save([folder(current(experiment)),'\THR_',timestr,'.mat'],'S','-mat');
end

sys3halt(dev);
save(DS);
SetAttenuators(P.Experiment, 120);
end

function [SpikeCrit, SR] = local_getSpikeCrit(dev, BurstDur,ISI)
    GUImessage(gcg, 'Measuring spontaneous rate.');
    
    % Get the circuit info for the sampline rate
    Info = sys3CircuitInfo(dev);
    Fsam = Info.Fsam;
    
    % The total burstdur
    TotalDur = 15e3;
    % Set the DSP program parameters
    sys3setpar(TotalDur, 'BurstDur',dev);
    sys3setpar(10e3, 'NonBurstDur',dev);
    sys3setpar(0, 'ToneAmpL', dev);
    sys3setpar(0, 'ToneAmpR', dev);
    sys3setpar(0, 'ToneFreq', dev);
    
    % Run the DSP program
    sys3setpar(1, 'Run', 'RX6');
    
    % Wait until the measurment is done
    pause(TotalDur/1e3 + 1);
    while 1
       isReady = sys3getpar('Ready',dev); 
       
       if isReady
          break; 
       end
       pause(1);
    end
    
    % Stop the DSP program
    sys3setpar(0, 'Run', 'RX6');
    
    % Get the paramters and data buffers from the DSP
    NbSpikes = sys3getpar('NbSpikes', dev);
    Spike_clock_count = sys3read('SpikeTimes',NbSpikes,dev,0,'I32');
    
    % calculate the spike times
    SpikeTimes = Spike_clock_count/Fsam; % in mili-sec
    
    % calculate the starting time of each block of duration BurstDur
    Nblocks = floor(15e3/BurstDur);
    if rem(15e3,BurstDur) ~0 % if the last block of duration BurstDur mili-sec does not fit in the 15sec discard these spikes
        % find the end time of the last full block 
        end_of_last_full_block = Nblocks*BurstDur;
        indices_bad_spikes = find(SpikeTimes>end_of_last_full_block);
        SpikeTimes(indices_bad_spikes) = [];
    end
    begin_block_times = [0:Nblocks-1]*BurstDur;
    BlockIndices = local_block_index_per_spike(begin_block_times, SpikeTimes);
    if ~isempty(BlockIndices)
        % Get the Number of spikes per block
        for i=1:Nblocks
           % Get all the spikes of that block
           NbSpikes(i) = sum(BlockIndices == i);
        end

        SpikeCrit = round(mean(NbSpikes) + std(NbSpikes)) + 1.;
        SR = mean(NbSpikes)/((BurstDur)/1e3);
    else
        NbSpikes = 0;
        SpikeCrit = round(mean(NbSpikes) + std(NbSpikes)) + 1.;
        SR = mean(NbSpikes)/((BurstDur)/1e3);
    end

end

function BlockIndices = local_block_index_per_spike(begin_block_times, SpikeTimes)
    BlockIndices = [];
    if ~isempty(SpikeTimes)
        for i = 1:length(SpikeTimes)
           SpikeTime = SpikeTimes(i);
           BlockIndices(i) = sum(begin_block_times < SpikeTime);
        end
    end
end

% function [SpikeCrit, SR] = local_getSpikeCrit(dev, BurstDur,ISI)
%     GUImessage(gcg, 'Measuring spontaneous rate.');
% %     NbSpikes = zeros(1,15);
%     Nrep = ceil(15*1e3/(BurstDur+10));
%     
%     for i=1:Nrep
%         i
%  
%         sys3setpar(0, 'ToneAmpL', dev);
%         sys3setpar(0, 'ToneAmpR', dev);
%         sys3setpar(0, 'ToneFreq', dev);
%         sys3setpar(1, 'Run', 'RX6');
%         pause((ISI+10)/1e3);
%         sys3setpar(0, 'Run', 'RX6');
%         NbSpikes(i) = sys3getpar('NbSpikes', dev);
%     end
%    
%     SpikeCrit = round(mean(NbSpikes) + std(NbSpikes)) + 1.;
%     SR = mean(NbSpikes)/((BurstDur)/1e3);
% 
% end