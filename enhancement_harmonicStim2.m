function P = enhancement_harmonicStim(P, varargin); 
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


% %TODO, that's at the end
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
[dBdiff,minf,maxf,BF,delta_T,SPL,condFallDur,...
    condRiseDur,condBurstDur,condOnsetDelay,...
    testFallDur,testRiseDur,testBurstDur,testOnsetDelay,ISI,notchW]=...
    samesize(P.dBdiff,P.minf,P.maxf,P.BF,P.delta_T,P.SPL,P.condFallDur,...
    P.condRiseDur,P.condBurstDur,P.condOnsetDelay,...
    P.testFallDur,P.testRiseDur,P.testBurstDur,P.testOnsetDelay,P.ISI,P.notchW);

% Restrict the parameters to the active channels. If only one DA channel is
% active, DAchanStr indicates which one.
[DAchanStr,dBdiff,minf,maxf,BF,delta_T,SPL,condFallDur,...
    condRiseDur,condBurstDur,condOnsetDelay,...
    testFallDur,testRiseDur,testBurstDur,testOnsetDelay,ISI,notchW]=...
    channelSelect(P.DAC, 'LR',dBdiff,minf,maxf,BF,delta_T,SPL,condFallDur,...
    condRiseDur,condBurstDur,condOnsetDelay,...
    testFallDur,testRiseDur,testBurstDur,testOnsetDelay,ISI,notchW);


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
        [w,duration] = local_Waveform(chanStr, Fsam,idx,...
                          dBdiff,BF,delta_T,SPL,condBurstDur,notchW,...
                          minf(idx),maxf(idx),condFallDur(idx),condRiseDur(idx),condOnsetDelay(idx),...
                           testFallDur(idx),testRiseDur(idx),testBurstDur(idx),testOnsetDelay(idx),ISI(idx),P);
           
           P.Waveform(icond,ichan) =w;
          P.Duration(icond,ichan) =duration;
    end
end

P = structJoin(P, collectInStruct(Fsam));

%here is where GenricParamsCall
% P.GenericParamsCall = {fhandle(mfilename) struct([]) 'GenericStimParams'};


%===================================================
%===================================================

function  [W,duration] = local_Waveform(DAchan, Fsam,idx,...
             dBdiffs,BFs,delta_Ts,SPLs,condBurstDurs,Ws,...
           minf,maxf,condFallDur,condRiseDur,condOnsetDelay,...
               testFallDur,testRiseDur,testBurstDur,testOnsetDelay,ISI,P);
           
           
dBdiff = dBdiffs(idx);
BF =BFs(idx); 
delta_T=delta_Ts(idx);
SPL=SPLs(idx);
condBurstDur=condBurstDurs(idx);
W=Ws(idx);


% Generate the waveform from the elementary parameters
%=======TIMING, DURATIONS & SAMPLE COUNTS=======
% get sample counts of subsequent segments
nsamp_cond = NsamplesofChain([condBurstDur], Fsam/1e3);
nsamp_test = NsamplesofChain([testBurstDur], Fsam/1e3);
nsamp_silence = NsamplesofChain([delta_T], Fsam/1e3);
nsamp_total = NsamplesofChain([condBurstDur,testBurstDur,delta_T], Fsam/1e3);

dt = 1e3/Fsam; % sample period in ms


% freqtest=freqs_harm(BF,minf,maxf);

cfs= floor(2.^linspace(log2(BF/8),log2(BF*8),(6*10)+1));
freqtest = cfs(find(cfs>=minf));
freqtest = freqtest(find(freqtest<=maxf));

%if Yvars is the first value, no conditioner
%so Yval should always be a param of the conditioner
Yvars = unique(eval([P.Yname,'s']));
eval(['idxY=find(Yvars==',P.Yname,');'])



Xvars = unique(eval([P.Xname,'s']));
eval(['idxX=find(Xvars==',P.Xname,');'])


%make conditioner
W,idxY,idxX,Xvars,Yvars
[freqcond,idx_kept]=remove_comp(BF,W,freqtest);

phase = 2*pi*rand(1,length(freqtest));

SPLcond=SPL;
%SPL=0 handles the case when there is no conditioner
if idxY==1
   conditioner=zeros(nsamp_cond,1); 
else
[DL, Dphi] = calibrate(P.Experiment, Fsam, DAchan, freqcond);
Ampcond = db2a(SPLcond+DL)*sqrt(2); % calibrated linear amplitude
%we do random phase without other choice at the moment
conditioner = toneComplex(Ampcond, freqcond, phase(idx_kept), Fsam, condBurstDur); % ungated waveform buffer; starting just after OnsetDelay
conditioner = exactGate(conditioner, Fsam, condBurstDur, 0, condRiseDur, condFallDur);
end



'make a flag value (like -1) on the paramter that control conditioner'
'i.e. width, durC,deltaT, when to set conditioner to zero'
'then the other one just continuer normaly'


%check is the random order eally working?
%TODO it should be able to hand all paramters
if idxY==1
   SPLtest=Yvars(min(idxX,length());%TODO
   W=0;
else
    SPLtest=SPL+dBdiff;
end
idxY,idxX,SPLtest,SPLcond,W

%make test

[DL, Dphi] = calibrate(P.Experiment, Fsam, DAchan, freqtest);
Amptest = db2a(SPLtest+DL)*sqrt(2); % calibrated linear amplitude
test = toneComplex(Amptest, freqtest, phase, Fsam, testBurstDur); % ungated waveform buffer; starting just after OnsetDelay
test = exactGate(test, Fsam, testBurstDur, 0, testRiseDur, testFallDur);

%make silence in between
silence = zeros(nsamp_silence,1);

%make stimulus (column vector)
w = [conditioner;silence;test];


subplot(2,2,1)
plot(w)
subplot(2,2,2)
absfft = abs(fft(conditioner));
freq = linspace(0,Fsam,length(absfft));
plot(freq,absfft)
xlim([0,4000])
subplot(2,2,3)
absfft2 = abs(fft(test));
freq = linspace(0,Fsam,length(absfft2));
plot(freq,absfft2)
xlim([0,4000])
subplot(2,2,4)
plot(freq,absfft-absfft2)
% var(absfft),var(absfft2)
xlim([0,16000])
pause
% clf

duration = ceil(length(w)*dt); 

% FROM NOISEconvert to waveform object & provide heading & trailing silence
Nsam = collectInStruct(nsamp_cond,nsamp_test,nsamp_silence,nsamp_total); %differnet number of smaples
duration = collectInStruct(delta_T,condFallDur,...
             condRiseDur,condBurstDur,condOnsetDelay,...
               testRiseDur,testBurstDur,testOnsetDelay); %differnet durations
           
P = collectInStruct(Nsam,duration,SPLtest,minf,maxf,BF,SPL,SPLcond,ISI,freqtest,freqcond); % store stim parameters for debugging purposes

NsamOnsetDelay = round(condOnsetDelay/dt);
W = waveform(Fsam, DAchan, NaN, SPL, P, {0 w}, [NsamOnsetDelay 1]);
W = appendSilence(W, ISI); % pas zeros to ensure correct ISI


% function Mess = local_test_singlechan(P, FNS);
% % test whether specified fields of P have single chan values
% Mess = '';
% for ii=1:numel(FNS),
%     fn = FNS{ii};
%     if size(P.(fn),2)~=1,
%         Mess = ['The ''' fn ''' field of P struct must have a single column.'];
%         return;
%     end
% end
% 
% function P = local_genericstimparams(S);
% % extracting generic stimulus parameters. Note: this only works after
% % SortCondition has been used to add a Presentation field to the
% % stimulus-defining struct S.
% Ncond = S.Presentation.Ncond;
% dt = 1e3/S.Fsam; % sample period in ms
% Nx1 = zeros(Ncond,1); % dummy for resizing
% Nx2 = zeros(Ncond,2); % dummy for resizing
% %
% ID.StimType = S.StimType;
% ID.Ncond = Ncond;
% ID.Nrep  = S.Presentation.Nrep;
% ID.Ntone = 1;
% % ======timing======
% T.PreBaselineDur = channelSelect('L', S.Baseline);
% T.PostBaselineDur = channelSelect('R', S.Baseline);
% T.ISI = samesize(S.ISI, Nx1);
% T.BurstDur = samesize(channelSelect('B', S.Duration), Nx2);
% T.OnsetDelay = samesize(dt*floor(S.OnsetDelay/dt), Nx1); % always integer # samples
% T.RiseDur = samesize(channelSelect('B', S.RiseDur), Nx2);
% T.FallDur = samesize(channelSelect('B', S.FallDur), Nx2);
% T.ITD = samesize(S.ITD, Nx1);
% T.ITDtype = S.ITDtype;
% T.TimeWarpFactor = ones(Ncond,1);
% % ======freqs======
% F.Fsam = S.Fsam;
% F.Fcar = samesize(channelSelect('B', S.Fcar),Nx2);
% F.Fmod = samesize(channelSelect('B', S.ModFreq), Nx2);
% F.LowCutoff = nan(Ncond,2);
% F.HighCutoff = nan(Ncond,2);
% F.FreqWarpFactor = ones(Ncond,1);
% % ======startPhases & mod Depths
% Y.CarStartPhase = nan([Ncond 2 ID.Ntone]);
% Y.ModStartPhase = samesize(channelSelect('B', S.ModStartPhase), Nx2);
% Y.ModTheta = samesize(channelSelect('B', S.ModTheta), Nx2);
% Y.ModDepth = samesize(channelSelect('B', S.ModDepth), Nx2);
% % ======levels======
% L.SPL = samesize(channelSelect('B', S.SPL), Nx2);
% L.SPLtype = 'per tone';
% L.DAC = S.DAC;
% P = structJoin(ID, '-Timing', T, '-Frequencies', F, '-Phases_Depth', Y, '-Levels', L);
% P.CreatedBy = mfilename; % sign
% 
% 
% 
% 
