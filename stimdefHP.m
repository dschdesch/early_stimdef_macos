function Params = stimdefHP(EXP);
% stimdefHP - definition of stimulus and GUI for HP stimulus paradigm
%    P = stimdefHP(EXP) returns the definition for the HP (Huggin's pitch)
%    stimulus paradigm. The definition P is a GUIpiece that can be rendered
%    by GUIpiece/draw. Stimulus definition like stimmdefHP are usually
%    called by StimGUI, which combines the parameter panels with
%    a generic part of stimulus GUIs. The input argument EXP contains 
%    Experiment definition, which co-determines the realization of
%    the stimulus: availability of DAC channels, calibration, recording
%    side, etc.
%
%    See also stimGUI, stimDefDir, Experiment, makestimMOVN.

% ---Noise
Noise = NoisePanelSPL('Noise parameters', EXP); % without SPL etc;
% ---SPL
SPLsweep = SPLstepper('SPL', EXP);
% ---Signal band center frequency and other parameters for Huggin's pitch
Fsweep = FrequencyStepperHP('Band frequency', EXP);
% ---Durations
Dur = DurPanel('Durations', EXP);
% ---Pres
Pres = PresentationPanel_XY('Freq','SPL');
% ---Summary
summ = Summary(17);
%====================
Params=GUIpiece('Params'); % upper half of GUI: parameters
Params = add(Params, summ);
Params = add(Params, Noise, nextto(summ), [10 0]);
Params = add(Params, Fsweep, below(Noise));
Params = add(Params, Dur, nextto(Noise), [20 0]);
Params = add(Params, SPLsweep, nextto(Dur),[10 0]);
Params = add(Params, Pres, below(Dur) ,[0 2]);
Params = add(Params, PlayTime(), below(Fsweep) ,[0 5]);