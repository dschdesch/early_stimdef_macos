function Params = stimdefDEP(EXP);
% stimdefDEP - definition of stimulus and GUI for DEP stimulus paradigm
%    P=stimdefDEP(EXP) returns the definition for the DEP (Modulation Depth Sweep)
%    stimulus paradigm. The definition P is a GUIpiece that can be rendered
%    by GUIpiece/draw. Stimulus definition like stimmdefDEP are usually
%    called by StimGUI, which combines the parameter panels with
%    a generic part of stimulus GUIs. The input argument EXP contains 
%    Experiment definition, which co-determines the realization of
%    the stimulus: availability of DAC channels, calibration, recording
%    side, etc.
%
%    See also stimGUI, stimDefDir, Experiment, makestimDEP.

PairStr = ' Pairs of numbers are interpreted as [left right].';
ClickStr = ' Click button to select ';
% ---ModDepthsweep
ModDepthsweep = SAMDepthStepper('SAM', EXP);

% ---Carrier frequency
freqPanel = FreqPanel('carrier frequency', EXP);

% ---Levels
Levels = SPLpanel('-', EXP);
% ---Durations
Dur = DurPanel('-', EXP);
% ---Pres
Pres = PresentationPanel;
% ---Summary
summ = Summary(17);

%====================
Params=GUIpiece('Params'); % upper half of GUI: parameters
Params = add(Params, summ);
Params = add(Params, ModDepthsweep, nextto(summ), [10 0]);
Params = add(Params, freqPanel, below(ModDepthsweep), [0 10]);
Params = add(Params, Levels, nextto(ModDepthsweep), [10 0]);
Params = add(Params, Dur, below(Levels) ,[0 10]);
Params = add(Params, Pres, nextto(Dur) ,[5 0]);
Params = add(Params, PlayTime, below(Dur) , [0 7]);




