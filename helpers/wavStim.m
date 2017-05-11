function P = wavStim(P, Prefix); 
% wavStim - compute wav stimulus
%   P = wavStim(P) computes the Waveform objects from info in P:
%           Nwav: the numer of wav files
%   wavFileNames: a cell containing the wav locations as in the wavlist file
%      WavFileNb: an array of numbers from 1 to Nwav representing 
%                 each wav file
%            DAC: left|right|both active DAC channel(s)
%            ISI: inter-stimulus interval in ms
%
%   The output of wavStim is realized by updating/creating the following 
%   fields of P
%      Fsam: sample rate [Hz] of all waveforms.
%      Fcar: adjusted to slightly rounded values to save memory using cyclic
%            storage (see CyclicStorage).
%      Fmod: modulation frequencies [Hz] in Ncond x Nchan matrix or column 
%            array. Might deviate slightly from user-specified values to
%            facilitate storage (see CyclicStorage).
%      Dur: stimulus duration [ms] in Ncond column array. By convention, this
%           the maximum value of the duration in the two channels.
%    Waveform: Ncond x Nchan Waveform object containing the samples and 
%           additional info for D/A conversion.
%
%   S = wavStim(P, 'Foo') uses the FooModFreq field of P instead of
%   ModFreq, FooModDepth instead of ModDepth, etc. 
%   This is the same type of prefix as is optionally passed to SAMpanel,
%   DurPanel, etc. The use of a prefix allows the multiple use of a
%   single type of GUIpanel for different components within one stimulus.
%
%   See also makestimWAV, dePrefix, Waveform.

if nargin<3, Prefix=''; end;
S = [];

P = dePrefix(P, Prefix); % now all params in P have standard names (see dePrefix help text)

% There are Nwav conditions and Nch DA channels.
% Cast all numerical params in Ncond x Nch size, so we don't have to check
% sizes all the time.
[Nwav, wavFileNames, WavFileNb, Gap] = deal(P.Nwav, P.WavFile, P.WavFileNb, P.Gap);

% Restrict the parameters to the active channels. If only one DA channel is
% active, DAchanStr indicates which one.
[DAchanStr, WavFileNb] = channelSelect(P, 'LR', WavFileNb);


WAVdata = cell(1,Nwav);
Fsample = zeros(Nwav, 1);
Details = [];
AnyStereoFiles = 0;
ShortName = cell(1,Nwav);
for iwav=1:Nwav,
    wfn = wavFileNames{iwav}; 
    [dummy sn ee] = fileparts(wfn); sn = [sn ee]; % short name incl. extension
    ShortName{iwav} = sn;

    [waveform, Fsample(iwav)] = wavread(wfn);
    if size(waveform,2)==2, AnyStereoFiles = 1; end;
    
    WAVdata{iwav} = collectInStruct(waveform);
end;

% resample WAVdata
ResampleTolerance = 0.01; 
Durations = zeros(Nwav,1);
ResampleRatio = zeros(Nwav,1);

% give all wav files the same sample rate
Fmax = 0.5*Fsample;
% find the single sample rate to realize all the waveforms while  ....
NewFsample = sampleRate(Fmax, P.Experiment); % accounting for recording requirements minADCrate
GapSam = round(Gap*NewFsample/1e3);

if isempty(NewFsample)
      error('No suitable sample rate found')
end

for iwav=1:Nwav,
    % Channel selection
    WAVdata{iwav}.waveform = channelSelect(P.DAC, WAVdata{iwav}.waveform);

    [R S] = cheaprat(NewFsample/Fsample(iwav), ResampleTolerance);
    ResampleRatio(iwav) = R/S;
    WAVdata{iwav}.waveform = resample(WAVdata{iwav}.waveform,R,S);

    % add gap at end of each file
    WAVdata{iwav}.waveform(end+1:end+GapSam,:) = 0;
    
    Durations(iwav) = size(WAVdata{iwav}.waveform,1)/NewFsample*1e3; % in ms
    NSamples(iwav) = size(WAVdata{iwav}.waveform,1);
end; % for iwav

% 
% % determine maximum levels XXX no calibration yet
% UIinfo('Determining Levels');
% MaxSample = [0 0];
% MaxSPLs = zeros(Nwav,2)-inf;
% for iwav=1:Nwav,
%    MaxSample(iwav, 1) = max(abs(WAVdata{iwav}.waveform(:,1)));
%    MaxSample(iwav, 2) = max(abs(WAVdata{iwav}.waveform(:,end)));
% end;
% % set RMS of inactive channels to zero
% if Channels==1, RMS(:,2) = 0;
% elseif Channels==2, RMS(:,1) = 0;
% end
% 
% MaxBoth = max(MaxSample(:));
% ArtMaxActive = (MaxBoth<ArtMaxmag);
% MaxBoth = max(MaxBoth,ArtMaxmag);
% Scalor = MaxMagDA/MaxBoth;
% MaxSPLs = a2db(RMS)+a2db(Scalor);
% GrandMaxSPL = [max(MaxSPLs(:,1)) max(MaxSPLs(:,2))];
% % if both channels are not active, select channel-specific params
% if ~isequal(Channels,0),
%    MaxSample = MaxSample(:, Channels);
%    MaxSPLs = MaxSPLs(:, Channels);
%    GrandMaxSPL = GrandMaxSPL(Channels);
% end

% P.WavDetails = CollectInStruct(Nwav, wavFileNames, ShortName, ...
%    Fsample, NewFsample, FilterIndex, ResampleRatio, ...
%    Durations, maxDur, ...
%    MaxSample, MaxBoth, ArtMaxActive, Scalor, MaxSPLs, GrandMaxSPL, RMS);


% now compute the stimulus waveforms condition by condition, ear by ear.

[Ncond, Nchan] = size(WavFileNb);
[P.Fcar, P.Fmod] = deal(nan(Ncond, Nchan));
%originalSPL = SPL;
for ichan=1:Nchan
    DAchan = DAchanStr(ichan);
    %SPL = originalSPL(ichan);
    SPL = 0;
    Nsam = sum(NSamples(:,ichan));
    Param = CollectInStruct(Nsam);%, SPL);
    MaxMagSam = 0;
    P.Duration = Durations;
    Fsam = NewFsample;
    
    W = collectInStruct(Fsam, DAchan, MaxMagSam, SPL, Param);
    for icond=1:Ncond
        % compute the waveform
        W.Samples{1} = WAVdata{icond}.waveform(:,ichan);
        W.Nrep(1) = 1;
        W.MaxMagSam = max(abs(W.Samples{1})); % update max magnitude
        P.Waveform(icond,ichan) = W;
    end
end

P.Fsam = Fsam;
% make P.Waveform a waveform object
P.Waveform = Waveform(P.Waveform);
% plot(P.Waveform(1,:),'marker', '.');
