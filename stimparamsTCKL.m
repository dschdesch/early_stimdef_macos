
function P = stimparamsENH_TCKL(S);
% stimparamsNPHI - generic stimulus parameters for NPHI stimulus protocol
%    G = stimparamsNPHI(S) takes the stimulus-defining struct S of an NPHI
%    protocol and returns the corresponding set of generic stimulus 
%    parameters im struct P. For a list of required fields in P, see
%    GenericStimparams. The trinity of functions stimdefNPHI, stimparamsNPHI,
%    and makestimNPHI completely define the NPHI stimulus protocol. 
%   
%    StimparamsNPHI is called by stimGUI during the preparation of the 
%    auditory stimuli (see Stimcheck). For older datasets, which do
%    not store the generic parameters, StimparamsNPHI may also be called by
%    GenericStimparams during data analysis.
%
%    See also GenericStimparams, stimGUI, stimDefPath, makestimNPHI, 
%    stimparamsNPHI.

%public(S)
Ncond = S.Presentation.Ncond;
dt = 1e3/S.Fsam; % sample period in ms

ID.StimType = 'harmonic';
ID.Ncond = Ncond;
ID.Nrep  = S.Presentation.Nrep;
ID.Ntone = 0;
% ===backward compatibility
if ~isfield(S,'Baseline'), S.Baseline = 0; end
if ~isfield(S,'OnsetDelay'), S.OnsetDelay = 0; end

% ======timing======
T.PreBaselineDur = channelSelect('L', S.Baseline);
T.PostBaselineDur = channelSelect('R', S.Baseline);
T.ISI = ones(Ncond,1)*S.ISI;
T.BurstDur = ones(Ncond,2)*(S.BurstDur);
T.OnsetDelay = dt*floor(ones(Ncond,1)*S.OnsetDelay/dt); % always integer # samples
T.RiseDur = repmat(channelSelect('B', S.RiseDur), [Ncond 1]);
T.FallDur = repmat(channelSelect('B', S.FallDur), [Ncond 1]);
T.ITD = ones(Ncond,1)*nan;
T.ITDtype = 'none';
T.TimeWarpFactor = ones(Ncond,1);
% ======freqs======
F.Fsam = S.Fsam;
F.Fcar = nan(Ncond,2,ID.Ntone);
F.Fmod = zeros(Ncond,2);
F.LowCutoff = nan(Ncond,2);
F.HighCutoff = nan(Ncond,2);
F.FreqWarpFactor = ones(Ncond,1);
% ======startPhases & mod Depths
Y.CarStartPhase = nan([Ncond 2 ID.Ntone]);
Y.ModStartPhase = zeros([Ncond 2]);
Y.ModTheta = zeros([Ncond 2]);
Y.ModDepth = zeros([Ncond 2]);
% ======levels======
L.SPL = channelSelect('B', S.SPL);
L.SPLtype = 'per tone';
L.DAC = S.DAC;
P = structJoin(ID, '-Timing', T, '-Frequencies', F, '-Phases_Depth', Y, '-Levels', L);












