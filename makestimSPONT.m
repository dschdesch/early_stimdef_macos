function P2 = makestimSPONT(P)
% MakestimSPONT - stimulus generator for SPONT (Spontanious Activity) stimGUI
%    P2=MakestimSPONT(P), where P2 is returned by GUIval, generates the stimulus
%    specified in P. MakestimSPONT is typically called by StimGuiAction when
%    the user pushes the Check, Play or PlayRec button.
%    MakestimSPONT does the following:
%        * Complete check of the stimulus parameters and their mutual
%          consistency, while reporting any errors
%        * Compute the stimulus waveforms
%        * Computation and broadcasting info about # conditions, total
%          stimulus duration, Max SPL, etc.
%
%    MakestimSPONT renders P ready for D/A conversion by adding the following 
%    fields to P
%            Fsam: sample rate [Hz] of all waveforms. This value is
%                  determined by carrier & modulation freqs, but also by
%                  the Experiment definition P.Experiment, which may 
%                  prescribe a minimum sample rate needed for ADC.
%            Fcar: carrier frequencies [Hz] of all the presentations in an
%                  Nx2 matrix or column array
%             SPL: Intensities [dB SPL] of all the presentations in an
%                  Nx2 matrix or column array
%        Waveform: Waveform object array containing the samples in SeqPlay
%                  format.
%     Attenuation: scaling factors and analog attuater settings for D/A
%    Presentation: struct containing detailed info on stimulus order,
%                  broadcasting of D/A progress, etc.
% 
%   See also toneStim, Waveform/maxSPL, Waveform/play, sortConditions, 
%   evalfrequencyStepper.

P2 = []; % a premature return will result in []
if isempty(P), return; end
figh = P.handle.GUIfig;

% check & convert params. Note that helpers like evalfrequencyStepper
% report any problems to the GUI and return [] or false in case of problems.

% Presentation
pres=local_eval_pres(figh, P); 
if isempty(pres), return; end

% SPL
SPL=-Inf;
if isempty(SPL), return; end
P.SPL=-Inf;
P.WavePhase = 0;
P.Ncond_XY = [1 1];

% Durations & PlayTime; this also parses ITD/ITDtype and adds ...

P.BurstDur = P.ISI;
P.FineITD = 0;
P.GateITD = 0;
P.ModITD = 0;

% Other stimulus fields
P.Fcar = 0;
P.FreqTolMode = 'exact';
P.OnsetDelay = 0;
P.RiseDur = 0;
P.FallDur = 0;
P.Nrep = P.REP;
P.Slowest = 'Rep';
P.RSeed = SetRandState();
P.Order = 'Forward';
P.Grouping = 'rep by rep';
P.Baseline = 0;
P.ITD = 0;
P.ITDtype = 'waveform';

% No modulation panel
[P.ModFreq, P.ModDepth, P.ModStartPhase, P.ModITD, P.ModTheta] = deal(0);

% Determine sample rate and actually generate the calibrated waveforms
P = toneStim(P); % P contains both Experiment (calib etc) & params, including P.Fcar 

% Sort conditions, add baseline waveforms (!), provide info on varied parameter etc
P = sortConditions(P, {'SPL'}, {'Carrier Intensity'}, ...
    {'dB SPL'}, {'Linear'});

% Levels and active channels (must be called *after* adding the baseline waveforms)
[mxSPL P.Attenuation] = maxSPL(P.Waveform, P.Experiment);
if isnan(P.Attenuation.AnaAtten)
    array_size = size(P.Attenuation.NumGain_dB);
    P.Attenuation.AnaAtten = 120*ones(1,length(P.Attenuation.AnaAtten));
    P.Attenuation.NumGain_dB = ones(array_size);
    P.Attenuation.NumScale = ones(array_size);
end

% Summary
%ReportSummary(figh, P);

P2=P;


end


function pres=local_eval_pres(figh, P)
pres = {};

if isnumeric(P.ISI) && ischar(P.DAC)
    if P.ISI > 0  && P.REP >0
       pres{1} = round(P.ISI); 
       pres{2} = round(P.REP);
       pres{3} = P.DAC;
    else
        return;
    end
end

end