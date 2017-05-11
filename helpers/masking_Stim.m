function P = masking_Stim(P, varargin);
%   P = enhancement_harmonicStim(P) computes the waveforms of tonal stimulus
%   The carrier frequencies are given by P.Fcar [Hz], which is a column
%   vector (mono) or Nx2 vector (stereo). The remaining parameters are
%   taken from the parameter struct P returned by GUIval. The Experiment
%   field of P specifies the calibration, available sample rates etc
%   In addition to Experiment, the following fields of P are used to
%   compute the waveforms

%    FreqTolMode: tolerance mode for freq rounding; equals exact|economic.
%            ISI: onset-to-onset inter-stimulus interval in ms

%     testOnsetDelay: silent interval (ms) preceding onset (common to both DACs)
%       testBurstDur: burst duration in ms including ramps
%        testRiseDur: duration of onset ramp
%        testFallDur,: duration of offset ramp

%     condOnsetDelay: silent interval (ms) preceding onset (common to both DACs)
%       condBurstDur: burst duration in ms including ramps
%        condRiseDur: duration of onset ramp
%        condFallDur: duration of offset ramp

%            DAC: left|right|both active DAC channel(s)
%            SPL: carrier sound pressure level [dB SPL]
%        delta_T: time between conditoner and test
%             BF: notch center frequency
%           minf: minum frequency
%           maxf: maximum frequency
%         dB_masker: dB difference between condtioner and test
%         notchW



%   Most of these parameters may be a scalar or a [1 2] array, or
%   a [Ncond x 1] or [Ncond x 2] or array, where Ncond is the number of
%   stimulus conditions. The allowed number of columns (1 or 2) depends on
%   the character of the paremeter, i.e., whether it may have separate
%   values for the left and right DA channel. The exceptions are
%   FineITD, GateITD, ModITD, and ISI, which which are allowed to have
%   only one column, and SPLtype and FreqTolMode, which are a single char
%   strings that apply to all of the conditions.


% %TODO2, that's at the end
% if nargin>1
%     if isequal('GenericStimParams', varargin{1}),
%         P = local_genericstimparams(P);
%         return;
%     else,
%         error('Invalid second input argument.');
%     end
% end
% S = [];
% % test the channel restrictions described in the help text
% error(local_test_singlechan(P,{'FineITD', 'GateITD', 'ModITD', 'ISI'}));

% There are Ncond=size(Fcar,1) conditions and Nch DA channels.
% Cast all numerical params in Ncond x Nch size, so we don't have to check
% sizes all the time.



[dB_masker,minf,maxf,BF,delta_T,SPL,FallDur,...
    RiseDur,BurstDur,OnsetDelay,...
    ISI,notchW,sideT,polarity,sband,stim_type,dur_probe]=...
    SameSize(P.dB_masker,P.minf,P.maxf,P.BF,P.delta_T,P.SPL,P.FallDur,...
    P.RiseDur,P.BurstDur,P.OnsetDelay,...
    P.ISI,P.notchW,P.sideT,P.polarity,P.sband,P.stim_type,P.dur_probe);

if P.DAC(1)=='B'
    notchW = [notchW,notchW];
end

% Restrict the parameters to the active channels. If only one DA channel is
% active, DAchanStr indicates which one.
[DAchanStr,dB_masker,minf,maxf,BF,delta_T,SPL,FallDur,...
    RiseDur,BurstDur,OnsetDelay,...
    ISI,notchW,sideT,polarity,sband,stim_type,dur_probe]=...
    channelSelect(P.DAC, 'LR',dB_masker,minf,maxf,BF,delta_T,SPL,FallDur,...
    RiseDur,BurstDur,OnsetDelay,...
    ISI,notchW,sideT,polarity,sband,stim_type,dur_probe);


% find the single sample rate to realize all the waveforms while  ....
Fsam = sampleRate(maxf, P.Experiment); % accounting for recording requirements minADCrate


% now compute the stimulus waveforms condition by condition, ear by ear.
[Ncond, Nchan] = size(notchW);
for ichan=1:Nchan,
    chanStr = DAchanStr(ichan); % L|R
    for icond=1:Ncond,
        % select the current element from the param matrices. All params ...
        % are stored in a (iNcond x Nchan) matrix. Use a single index idx
        % to avoid the cumbersome A(icond,ichan).
        idx = icond + (ichan-1)*Ncond;
        % compute the waveform
        if length(DAchanStr)==1
            [w,duration] = local_WaveformMono(chanStr, Fsam,idx,...
                dB_masker,BF,delta_T,SPL,BurstDur,notchW,...
                minf(idx),maxf(idx),FallDur(idx),RiseDur(idx),OnsetDelay(idx),...
                ISI(idx),polarity(idx),P,sband(idx),stim_type(idx),dur_probe(idx));
        else
            [w,duration] = local_WaveformBinaural(chanStr, Fsam,idx,...
                dB_masker,BF,delta_T,SPL,BurstDur,notchW,...
                minf(idx),maxf(idx),FallDur(idx),RiseDur(idx),OnsetDelay(idx),...
                ISI(idx),polarity(idx),P,sideT(idx),sband(idx),stim_type(idx),dur_probe(idx));
            
            
        end
        P.Waveform(icond,ichan) =w;
        P.Duration(icond,ichan) =duration;
    end
end

P = structJoin(P, CollectInStruct(Fsam));
end

%here is where GenricParamsCall
% P.GenericParamsCall = {fhandle(mfilename) struct([]) 'GenericStimParams'};


%===================================================
%===================================================

function  [W,duration] = local_WaveformMono(DAchan, Fsam,idx,...
    dB_maskers,BFs,delta_Ts,SPLs,BurstDurs,Ws,...
    minf,maxf,FallDur,RiseDur,OnsetDelay,...
    ISI,polarity,P,sband,stim_type,dur_probe);

SPLmasker = dB_maskers(idx);
BF =BFs(idx);
delta_T=delta_Ts(idx);
SPLprobe=SPLs(idx);
BurstDur=BurstDurs(idx);
W=Ws(idx);

% Generate the waveform from the elementary parameters
%=======TIMING, DURATIONS & SAMPLE COUNTS=======
% get sample counts of subsequent segments

if isfield(P,'Startdelta_T')
negT = min([0,P.Startdelta_T]);
posT = max([0,P.Enddelta_T]);
elseif P.delta_T>0
  negT = 0;
posT = P.delta_T;  
else
     negT = P.delta_T;
posT = 0;   
end
nsamp_negT = NsamplesofChain([negT], Fsam/1e3);
nsamp_posT = NsamplesofChain([posT], Fsam/1e3);
nsamp_masker = NsamplesofChain([BurstDur], Fsam/1e3);
nsamp_probe = NsamplesofChain([dur_probe], Fsam/1e3);
nsamp_silence = NsamplesofChain([delta_T], Fsam/1e3);


dt = 1e3/Fsam; % sample period in ms

%if Yvars is the first value, no conditioner
%so Yval should always be a param of the conditioner

% Yvars = unique(eval([P.Yname,'s']));
% eval(['idxY=find(Yvars==',P.Yname,');'])
% Xvars = unique(eval([P.Xname,'s']));
% eval(['idxX=find(Xvars==',P.Xname,');'])


% cfs= round(2.^linspace(log2(BF/8),log2(BF*8),(6*10)+1));
cfs= 2.^linspace(log2(BF/16),log2(BF*16),(8*10)+1);
cfs(find(cfs<BF))= ceil(cfs(find(cfs<BF)));
cfs(find(cfs>BF))= floor(cfs(find(cfs>BF)));

cfs = cfs(find(cfs>=minf));
cfs = cfs(find(cfs<=maxf));

freq_probe = [BF];

[freq_masker]=spectrum_masker(BF,abs(W),cfs,stim_type);

if abs(W)>50 %if W is given in Hz, the masker is a single tone at that frequency
   freq_masker = W;
end


phase = load('phase2.mat');
phase = phase.phase;
% phase = 2*pi*rand(1,length(cfs));
% save('phase2','phase')

[DL, Dphi] = calibrate(P.Experiment, Fsam, DAchan, freq_probe);
Amp_probe = dB2A(SPLprobe+DL)*sqrt(2); % calibrated linear amplitude

%we do random phase without other choice at the moment
probe = tonecomplex(Amp_probe, freq_probe, 0, Fsam, dur_probe); % ungated waveform buffer; starting just after OnsetDelay
probe = ExactGate(probe, Fsam, dur_probe, 0, RiseDur, FallDur);
probe = [zeros(nsamp_posT,1);probe];
nsamp = length(probe)
if SPLprobe==-10
    probe = zeros(length(probe),1);
end


if sign(W)>=0&delta_T~=-1000000
    [DL, Dphi] = calibrate(P.Experiment, Fsam, DAchan, freq_masker);
    Amp_masker = dB2A(SPLmasker+DL)*sqrt(2); % calibrated linear amplitude
    if sband=='H' & abs(W)<50
        Amp_masker(find(freq_masker<BF))=0;
    elseif sband=='L' & abs(W)<50
        Amp_masker(find(freq_masker>BF))=0;
    end
    masker = tonecomplex(Amp_masker, freq_masker, phase(1:length(freq_masker)), Fsam, BurstDur); % ungated waveform buffer; starting just after OnsetDelay
    masker = ExactGate(masker, Fsam, BurstDur, 0, RiseDur, FallDur);
    
    tmp = zeros(nsamp_posT+length(masker)+abs(nsamp_negT),1);
    tmp(nsamp_posT-nsamp_silence+1:nsamp_posT-nsamp_silence+length(masker),1) = masker;
    masker=tmp;
    
    tmp = zeros(nsamp_posT+nsamp_masker+abs(nsamp_negT),1);
    tmp(1:length(probe)) = probe;
    probe = tmp;
    w = probe+masker;
else
    tmp = zeros(nsamp_posT+nsamp_masker+abs(nsamp_negT),1);
    tmp(1:length(probe)) = probe;
    probe = tmp;
    w = probe;
end





w = polarity*w;


% figure(1)
% display([SPLprobe,SPLmasker,W,delta_T,freq_masker,freq_probe])
% t = linspace(0,length(w)*dt,length(w));
% if sign(W)>=0&delta_T~=-1000000
%     subplot(2,3,1)
%     absfft = abs(fft(masker));
%     freq = linspace(0,Fsam,length(absfft));
%     plot(freq,absfft)
%     xlim([1000,4000])
% end
% subplot(2,3,2)
% absfft = abs(fft(probe));
% freq = linspace(0,Fsam,length(absfft));
% plot(freq,absfft)
% xlim([1000,4000])
% subplot(2,3,3)
% absfft2 = abs(fft(w));
% freq = linspace(0,Fsam,length(absfft2));
% plot(freq,absfft2)
% xlim([1000,4000])
% if sign(W)>=0&delta_T~=-1000000
%     subplot(2,3,4)
%     plot(masker)
% end
% % xlim([100,10000])
% subplot(2,3,5)
% plot(probe)
% subplot(2,3,6)
% plot(w)
% 
% pause
% clf

duration = ceil(length(w)*dt);

% FROM NOISEconvert to waveform object & provide heading & trailing silence
Nsam = CollectInStruct(nsamp); %differnet number of smaples
duration = CollectInStruct(delta_T,FallDur,...
    RiseDur,BurstDur,OnsetDelay,...
    OnsetDelay); %differnet durations

% SPL = min(SPLtest,SPLcond); %take the max to compute SPLmax
SPL = max(SPLprobe,SPLmasker); %take the max to compute SPLmax

P = CollectInStruct(polarity,Nsam,duration,SPLprobe,SPLmasker,minf,maxf,BF,ISI,freq_probe,freq_masker,phase,sband,stim_type); % store stim parameters for debugging purposes

NsamOnsetDelay = round(OnsetDelay/dt);
% arg #3 is MagMaxsam
W = Waveform(Fsam, DAchan, NaN, SPL, P, {0 w}, [NsamOnsetDelay 1]);
W = AppendSilence(W, ISI); % pas zeros to ensure correct ISI
end

%
% function  [W,duration] = local_WaveformBinaural(DAchan, Fsam,idx,...
%     dBdiffs,BFs,delta_Ts,SPLs,condBurstDurs,Ws,...
%     minf,maxf,FallDur,RiseDur,OnsetDelay,...
%     ISI,polarity,P,sideT,sband,stim_type,dur_probe);
% dBdiff = dBdiffs(idx);
% BF =BFs(idx);
% delta_T=delta_Ts(idx);
% SPL=SPLs(idx);
% condBurstDur=condBurstDurs(idx);
% W=Ws(idx);
%
% % Generate the waveform from the elementary parameters
% %=======TIMING, DURATIONS & SAMPLE COUNTS=======
% % get sample counts of subsequent segments
% nsamp_cond = NsamplesofChain([condBurstDur], Fsam/1e3);
% nsamp_test = NsamplesofChain([testBurstDur], Fsam/1e3);
% nsamp_silence = NsamplesofChain([delta_T], Fsam/1e3);
% nsamp_total = NsamplesofChain([condBurstDur,delta_T], Fsam/1e3);
%
%
%
% dt = 1e3/Fsam; % sample period in ms
%
% %if Yvars is the first value, no conditioner
% %so Yval should always be a param of the conditioner
% Yvars = unique(eval([P.Yname,'s']));
% eval(['idxY=find(Yvars==',P.Yname,');'])
% Xvars = unique(eval([P.Xname,'s']));
% eval(['idxX=find(Xvars==',P.Xname,');'])
%
%
% %make conditioner
% if abs(W)==100
%     W=0;
% end
% cfs= round(2.^linspace(log2(BF/8),log2(BF*8),(6*10)+1));
% cfs = cfs(find(cfs>=minf));
% cfs = cfs(find(cfs<=maxf));
% [freqtest,idx_kept_test,iBF]=remove_comp(BF,abs(W),cfs);
% freqcond = setdiff(freqtest,BF);
%
% % freqtest
% % freqcond
%
% idx_kept_cond = setdiff(idx_kept_test,iBF);
% phase = 2*pi*rand(1,length(cfs));
%
% SPLcond=SPL+dBdiff;
% SPLtest=SPL;
%
% if sign(Xvars(idxX))==1 & DAchan~=sideT %if only conditioner present at that side
%     [DL, Dphi] = calibrate(P.Experiment, Fsam, DAchan, freqcond);
%     Ampcond = db2a(SPLcond+DL)*sqrt(2); % calibrated linear amplitude
%     if sband=='H'
%         Ampcond(find(freqcond<BF))=0;
%     elseif sband=='L'
%         Ampcond(find(freqcond>BF))=0;
%     end
%     conditioner = toneComplex(Ampcond, freqcond, phase(idx_kept_cond), Fsam, condBurstDur); % ungated waveform buffer; starting just after OnsetDelay
%     conditioner = exactGate(conditioner, Fsam, condBurstDur, 0, condRiseDur, condFallDur);
%     w = [conditioner];
%
% elseif  DAchan==sideT  % if test at that side (test not delayed)
%     [DL, Dphi] = calibrate(P.Experiment, Fsam, DAchan, freqtest);
%     Amptest = db2a(SPLtest+DL)*sqrt(2); % calibrated linear amplitude
%     if sband=='H'
%         Amptest(find(freqtest<BF))=0;
%     elseif sband=='L'
%         Amptest(find(freqtest>BF))=0;
%     end
%
%     if dur_probe==1
%             Amptest(find(freqtest~=BF))=0;
%     end
%     test = toneComplex(Amptest, freqtest, phase(idx_kept_test), Fsam, testBurstDur); % ungated waveform buffer; starting just after OnsetDelay
%     test = exactGate(test, Fsam,  0,  testFallDur);
%     if sign(Xvars(idxX))==1 %if  conditioner in stimulus, test is delayed
%         %delay is duration of conditioner + deltaT
%         silence = zeros(nsamp_silence+nsamp_cond,1);
%         w = [silence;test]; %not delayed
%     else
%         w = [silence;test]; %not delayed
%     end
% else
%     w=[0;0;0;0];
% end
%
% w = polarity*w;
% %make stimulus (column vector)
%
%
% % Xvars(idxX),W
% % t = linspace(0,length(w)*dt,length(w));
% % subplot(2,2,1)
% % plot(t,w)
% % subplot(2,2,2)
% % absfft = abs(fft(conditioner));
% % freq = linspace(0,Fsam,length(absfft));
% % plot(freq,absfft)
% % xlim([0,20000])
% % subplot(2,2,3)
% % absfft2 = abs(fft(test));
% % freq = linspace(0,Fsam,length(absfft2));
% % plot(freq,absfft2)
% % xlim([0,20000])
% % subplot(2,2,4)
% % plot(conditioner)
% % var(absfft),var(absfft2)
% % xlim([0,16000])
% % pause
% % clf
%
% duration = ceil(length(w)*dt);
%
% % FROM NOISEconvert to waveform object & provide heading & trailing silence
% Nsam = collectInStruct(nsamp_cond,nsamp_test,nsamp_silence,nsamp_total); %differnet number of smaples
% duration = collectInStruct(delta_T,condFallDur,...
%     condRiseDur,condBurstDur,condOnsetDelay,...
%     testOnsetDelay); %differnet durations
%
% SPL = max(SPLtest,SPLcond); %take the max to compute SPLmax
% test_alone_is_delayed = 1;
% P = collectInStruct(test_alone_is_delayed,polarity,Nsam,duration,SPLtest,SPLcond,minf,maxf,BF,SPL,SPLcond,ISI,freqtest,freqcond,sband,stim_type); % store stim parameters for debugging purposes
%
% NsamOnsetDelay = round(condOnsetDelay/dt);
% W = waveform(Fsam, DAchan, NaN, SPL, P, {0 w}, [NsamOnsetDelay 1]);
% W = appendSilence(W, ISI); % pas zeros to ensure correct ISI
% end