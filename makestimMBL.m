function P2=makestimMBL(P);
% MakestimMBL - stimulus generator for MBL stimGUI
%    P=MakestimMBL(P), where P is returned by GUIval, generates the stimulus
%    specified in P. MakestimMBL is typically called by StimGuiAction when
%    the user pushes the Check, Play or PlayRec button.
%    MakestimMBL does the following:
%        * Complete check of the stimulus parameters and their mutual
%          consistency, while reporting any errors
%        * Compute the stimulus waveforms
%        * Computation and broadcasting info about # conditions, total
%          stimulus duration, Max MBL, etc.
%
%    MakestimMBL renders P ready for D/A conversion by adding the following 
%    fields to P
%            Fsam: sample rate [Hz] of all waveforms. This value is
%                  determined by carrier & modulation freqs, but also by
%                  the Experiment definition P.Experiment, which may 
%                  prescribe a minimum sample rate needed for ADC.
%            Fcar: carrier frequencies [Hz] of all the presentations in an
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
% report any problems to the GUI and return [] or false in case of
% problems.

% SPL stepper: add it to stimparam struct P
P.SPL=EvalSPLstepper(figh, '', P); 
if isempty(P.SPL), return; end
Ncond = size(P.SPL,1); % # conditions

% Set SPL of other ear so that average equals MBL
switch P.ParamEar(1)
    case 'L'
        OtherChannel = 2;
    case 'R'
        OtherChannel = 1;
end

[dummy, P.MBLSPL] = SameSize(P.SPL, P.MBLSPL);

P.SPL = P.SPL*[1 1];
P.SPL(:,OtherChannel) = 2*P.MBLSPL - P.SPL(:,OtherChannel);

% Check if the user provided max SPL is not exceeded
[P.SPL, P.UserMaxSPL] = SameSize(P.SPL, P.UserMaxSPL);
if any(any(P.SPL>P.UserMaxSPL))
    GUImessage(figh,'One or more SPLs exceed the provided max SPL.', 'error',{'StartSPL' 'EndSPL' 'MBLSPL'});
    return;
end

% SAM (pass Fcar to enable checking of out-of-freq-range sidebands)
okay=EvalSAMpanel(figh,P,P.Fcar);
if ~okay, return; end

% Durations & PlayTime; this also parses ITD/ITDtype and adds ...
[okay, P]=EvalDurPanel(figh, P, Ncond);% ... FineITD, GateITD, ModITD fields to P
if ~okay, return; end

% Determine sample rate and actually generate the calibrated waveforms
P = toneStim(P); % P contains both Experiment (calib etc) & params, including P.Fcar 

% Sort conditions, add baseline waveforms (!), provide info on varied parameter etc
P = sortConditions(P, 'SPL', 'Carrier intensity', 'dB SPL', {P.SPL 'Linear'}  );

% Levels and active channels (must be called *after* adding the baseline waveforms)
[mxSPL P.Attenuation] = maxSPL(P.Waveform, P.Experiment);
okay = CheckSPL(figh, P.SPL, mxSPL, P.Fcar, '', {'StartSPL' 'EndSPL' 'MBLSPL'});
if ~okay, return; end



% 'TESTING MAKEDTIMMBL'
% P.Duration
% P.Duration = []; % 
% P.Fcar = [];

% Summary
ReportSummary(figh, P);

% everything okay: return P
P2=P;











