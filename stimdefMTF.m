function Params = stimdefMTF(EXP);
% stimdefMTF - definition of stimulus and GUI for MTF stimulus paradigm
%    P=stimdefMTF(EXP) returns the definition for the MTF (Modulation Sweep)
%    stimulus paradigm. The definition P is a GUIpiece that can be rendered
%    by GUIpiece/draw. Stimulus definition like stimmdefMTF are usually
%    called by StimGUI, which combines the parameter panels with
%    a generic part of stimulus GUIs. The input argument EXP contains 
%    Experiment definition, which co-determines the realization of
%    the stimulus: availability of DAC channels, calibration, recording
%    side, etc.
%
%    See also stimGUI, stimDefDir, Experiment, makestimMTF.

PairStr = ' Pairs of numbers are interpreted as [left right].';
ClickStr = ' Click button to select ';
% ---Modsweep
Modsweep = SAMstepper('SAM', EXP, '', 1);

% ---Carrier frequency
freqPanel = FreqPanel('carrier frequency', EXP);
freqPanel = sameextent(freqPanel,Modsweep,'X');

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
Params = add(Params, Modsweep, nextto(summ), [10 0]);
Params = add(Params, freqPanel, below(Modsweep), [0 10]);
Params = add(Params, Levels, nextto(Modsweep), [10 0]);
Params = add(Params, Dur, below(Levels) ,[0 10]);
Params = add(Params, Pres, nextto(Dur) ,[5 0]);
Params = add(Params, PlayTime, below(Dur) , [0 7]);




