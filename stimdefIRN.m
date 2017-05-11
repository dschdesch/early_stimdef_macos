function Params = stimdefIRN(EXP)
% stimdefIRN - definition of stimulus and GUI for IRN stimulus paradigm
%    P=stimdefIRN(EXP) returns the definition for the IRN (Iterated Rippled Noise)
%    stimulus paradigm. The definition P is a GUIpiece that can be rendered
%    by GUIpiece/draw. Stimulus definition like stimmdefIRN are usually
%    called by StimGUI, which combines the parameter panels with
%    a generic part of stimulus GUIs. The input argument EXP contains 
%    Experiment definition, which co-determines the realization of
%    the stimulus: availability of DAC channels, calibration, recording
%    side, etc.
%
%    See also stimGUI, stimDefDir, Experiment, makestimIRN.

PairStr = ' Pairs of numbers are interpreted as [left right].';
ClickStr = ' Click button to select ';

% ---Noise
Noise = NoisePanel('Noise parameters', EXP, '', 'SPL','nobinaural'); % exclude SPL since it is already included in SPL-stepper
%---SPL sweep
SPLsweep = SPLstepper('SPL', EXP);
%---IRND sweep
DelaySweep = delta_Tstepper('Delay', EXP, '','nobinaural');
% ---Durations
Dur = DurPanel('Durations', EXP, '', 'nophase');

%---Stimulus specific parameters
IRN = GUIpanel('IRN', 'Specific parameters');
Phi = ParamQuery('Phi', 'Phase shift:', '0.1251', 'Cycle', ...
    'rreal', 'Phase shift applied to the delayed noise waveform when added to the undelayed noise waveform.' , 1);
Gain = ParamQuery('Gain', 'Gain:', '1', '', ...
    'rreal/positive', 'Gain (between 0 and 1) applied to the delayed noise waveform when added to the undelayed noise waveform.', 1);
Niter = ParamQuery('Niter', '# iterations:', '1', '', ...
    'posint', 'Number of iterations of the delay and add networks (1 = rippled noise, cf. Yost (1996)).', 1);
IRN = add(IRN, Phi, 'below', [0 0]);
IRN = add(IRN, Gain, alignedwith(Phi));
IRN = add(IRN, Niter, alignedwith(Gain));

% ---Pres
Pres = PresentationPanel_XY('Delay', 'SPL');
%Pres = sameExtent(Pres,SPLsweep,'X'); % adjust width
% ---Summary
summ = Summary(17);

%====================
Params=GUIpiece('Params'); % upper half of GUI: parameters
Params = add(Params, summ);
Params = add(Params, Noise, nextto(summ), [10 0]);
Params = add(Params, SPLsweep, below(Noise), [0 4]);
Params = add(Params, DelaySweep, below(SPLsweep), [0 4]);
Params = add(Params, IRN, nextto(DelaySweep), [10 0]);
Params = add(Params, Dur, nextto(Noise), [10 0]);
Params = add(Params, Pres, below(Dur) ,[0 4]);
Params = add(Params, PlayTime(), below(DelaySweep) ,[0 5]);

