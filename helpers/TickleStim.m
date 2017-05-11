function P = TickleStim(P, varargin);
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
%         dBdiff: dB difference between condtioner and test
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

% P.polarity=1;

[Fcar,SPL,FallDur,RiseDur,BurstDur,OnsetDelay,ISI,...
       BF_TCKL,side_TCKL,SPL_TCKL]=...
    SameSize(P.Fcar,P.SPL,P.FallDur,P.RiseDur,P.BurstDur,P.OnsetDelay,P.ISI,...
       P.BF_TCKL,P.side_TCKL,P.SPL_TCKL);

% Restrict the parameters to the active channels. If only one DA channel is
% active, DAchanStr indicates which one.
[DAchanStr,Fcar,SPL,FallDur,RiseDur,BurstDur,OnsetDelay,ISI,...
       BF_TCKL,side_TCKL,SPL_TCKL]=...
    channelSelect(P.DAC, 'LR',Fcar,SPL,FallDur,RiseDur,BurstDur,OnsetDelay,ISI,...
       BF_TCKL,side_TCKL,SPL_TCKL);


% find the single sample rate to realize all the waveforms while  ....
Fsam = sampleRate(Fcar,P.Experiment); % accounting for recording requirements minADCrate


% now compute the stimulus waveforms condition by condition, ear by ear.
[Ncond, Nchan] = size(Fcar);
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
                Fcar(idx),SPL(idx),FallDur(idx),RiseDur(idx),BurstDur(idx),OnsetDelay(idx),ISI(idx),...
                       BF_TCKL(idx),side_TCKL(idx),SPL_TCKL(idx),P);
        else
            [w,duration] = local_WaveformBinaural(chanStr,Fsam,idx,...
                Fcar(idx),SPL(idx),FallDur(idx),RiseDur(idx),BurstDur(idx),OnsetDelay(idx),ISI(idx),...
                       BF_TCKL(idx),side_TCKL(idx),SPL_TCKL(idx),P);
            
            
        end
        P.Waveform(icond,ichan) =w;
        P.Duration(icond,ichan) =duration;
%         P.SPL = P.Waveform(icond,ichan).SPL
        P.Fcar(icond,ichan) = Fcar(idx);
    end
end

P = structJoin(P, CollectInStruct(Fsam));
end

%here is where GenricParamsCall
% P.GenericParamsCall = {fhandle(mfilename) struct([]) 'GenericStimParams'};


%===================================================
%===================================================

function  [W,duration] = local_WaveformMono(DAchan, Fsam,idx,...
            Fcar,SPL,FallDur,RiseDur,BurstDur,OnsetDelay,ISI,...
                   BF_TCKL,side_TCKL,SPL_TCKL,P);



% Generate the waveform from the elementary parameters
%=======TIMING, DURATIONS & SAMPLE COUNTS=======
% get sample counts of subsequent segments
nsamp = NsamplesofChain([BurstDur], Fsam/1e3);

dt = 1e3/Fsam; % sample period in ms
phase = load('phase.mat'); 
phase = phase.phase;

%if lower corners, no stimu so spontenaoeus
Fcars = unique(P.Fcar);
dBs = unique(P.SPL);
SPL,Fcar,SPL,Fcar
if ((SPL==dBs(1))&(Fcar==Fcars(1))) | ((SPL==dBs(1))&(Fcar==Fcars(end)))
    SPL=-50;
end


SPLs =[SPL_TCKL,SPL];
freq =[BF_TCKL,Fcar];
[DL, Dphi] = calibrate(P.Experiment, Fsam, DAchan, freq);
Amp = dB2A(SPLs+DL)*sqrt(2); % calibrated linear amplitude
w = tonecomplex(Amp, freq, phase(1:2), Fsam, BurstDur); % ungated waveform buffer; starting just after OnsetDelay
w = ExactGate(w, Fsam, BurstDur, 0, RiseDur, FallDur);



% display([SPL,Fcar,BF_TCKL,SPL_TCKL])
% t = linspace(0,length(w)*dt,length(w));
% subplot(2,1,1)
% plot(t,w)
% subplot(2,1,2)
% absfft = abs(fft(w));
% freq = linspace(0,Fsam,length(absfft));
% plot(freq,absfft)
% xlim([100,14000])
% pause
% clf

duration = ceil(length(w)*dt);

% FROM NOISEconvert to waveform object & provide heading & trailing silence
Nsam = CollectInStruct(nsamp); %differnet number of smaples
duration = CollectInStruct(FallDur,RiseDur,BurstDur,OnsetDelay,...
    RiseDur,BurstDur,OnsetDelay); %differnet durations
SPL = max([SPL,SPL_TCKL]);
P = CollectInStruct(Nsam,duration,SPL,SPL_TCKL,BF_TCKL,Fcar,phase); % store stim parameters for debugging purposes

NsamOnsetDelay = round(OnsetDelay/dt);
W = Waveform(Fsam, DAchan, NaN, max([SPL,SPL_TCKL]), P, {0 w}, [NsamOnsetDelay 1]);
W = AppendSilence(W, ISI); % pas zeros to ensure correct ISI
end



function  [W,duration] = local_WaveformBinaural(DAchan, Fsam,idx,...
            Fcar,SPL,FallDur,RiseDur,BurstDur,OnsetDelay,ISI,...
                   BF_TCKL,side_TCKL,SPL_TCKL,P);



% Generate the waveform from the elementary parameters
%=======TIMING, DURATIONS & SAMPLE COUNTS=======
% get sample counts of subsequent segments
nsamp = NsamplesofChain([BurstDur], Fsam/1e3);

dt = 1e3/Fsam; % sample period in ms
load phase 

%if lower corners, no stimu so spontenaoeus
Fcars = unique(P.Fcar);
dBs = unique(P.SPL);
if ((SPL==dBs(1))&(Fcar==Fcars(1))) | ((SPL==dBs(end))&(Fcar==Fcars(1)))
    SPL=-50;
end

if DAchan~=side_TCKL %if the tickle is NOT on this side
SPLs =[SPL];
freq =[Fcar];
[DL, Dphi] = calibrate(P.Experiment, Fsam, DAchan, freq);
Amp = dB2A(SPLs+DL)*sqrt(2); % calibrated linear amplitude
w = tonecomplex(Amp, freq, phase(1), Fsam, BurstDur); % ungated waveform buffer; starting just after OnsetDelay
w = ExactGate(w, Fsam, BurstDur, 0, RiseDur, FallDur);
else
 SPLs =[SPL_TCKL];
freq =[BF_TCKL];
[DL, Dphi] = calibrate(P.Experiment, Fsam, DAchan, freq);
Amp = dB2A(SPLs+DL)*sqrt(2); % calibrated linear amplitude
w = tonecomplex(Amp, freq, phase(1), Fsam, BurstDur); % ungated waveform buffer; starting just after OnsetDelay
w = ExactGate(w, Fsam, BurstDur, 0, RiseDur, FallDur);
end

% display([SPL,Fcar,BF_TCKL,SPL_TCKL])
% t = linspace(0,length(w)*dt,length(w));
% subplot(2,1,1)
% plot(t,w)
% subplot(2,1,2)
% absfft = abs(fft(w));
% freq = linspace(0,Fsam,length(absfft));
% plot(freq,absfft)
% xlim([100,10000])
% pause
% clf

duration = ceil(length(w)*dt);

% FROM NOISEconvert to waveform object & provide heading & trailing silence
Nsam = CollectInStruct(nsamp); %differnet number of smaples
duration = CollectInStruct(FallDur,RiseDur,BurstDur,OnsetDelay,...
    RiseDur,BurstDur,OnsetDelay); %differnet durations
SPL = max([SPL,SPL_TCKL]);
P = CollectInStruct(Nsam,duration,SPL,SPL_TCKL,BF_TCKL,Fcar,phase); % store stim parameters for debugging purposes

NsamOnsetDelay = round(OnsetDelay/dt);
W = Waveform(Fsam, DAchan, NaN, max([SPL,SPL_TCKL]), P, {0 w}, [NsamOnsetDelay 1]);
W = AppendSilence(W, ISI); % pas zeros to ensure correct ISI
end

% 
% 
% 
% function  [W,duration] = local_WaveformBinaural(DAchan, Fsam,idx,...
%     dBdiffs,BFs,delta_Ts,SPLs,condBurstDurs,Ws,...
%     minf,maxf,condFallDur,condRiseDur,condOnsetDelay,...
%     testFallDur,testRiseDur,testBurstDur,testOnsetDelay,ISI,polarity,P,sideT,sband,stim_type);
% 
% 
% 
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
% nsamp_total = NsamplesofChain([condBurstDur,testBurstDur,delta_T], Fsam/1e3);
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
% SPLcond=SPL;
% SPLtest=SPL+dBdiff;
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
%     test = toneComplex(Amptest, freqtest, phase(idx_kept_test), Fsam, testBurstDur); % ungated waveform buffer; starting just after OnsetDelay
%     test = exactGate(test, Fsam, testBurstDur, 0, testRiseDur, testFallDur);
%     if sign(Xvars(idxX))==1 %if  conditioner in stimulus, test is delayed
%         %delay is duration of conditioner + deltaT
%         silence = zeros(nsamp_silence+nsamp_cond,1);
%         w = [silence;test]; %not delayed
%     else
%         w = [test]; %not delayed
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
%     testRiseDur,testBurstDur,testOnsetDelay); %differnet durations
% 
% P = collectInStruct(polarity,Nsam,duration,SPLtest,minf,maxf,BF,SPL,SPLcond,ISI,freqtest,freqcond,sband,stim_type); % store stim parameters for debugging purposes
% 
% NsamOnsetDelay = round(condOnsetDelay/dt);
% W = waveform(Fsam, DAchan, NaN, SPL, P, {0 w}, [NsamOnsetDelay 1]);
% W = appendSilence(W, ISI); % pas zeros to ensure correct ISI
% end

