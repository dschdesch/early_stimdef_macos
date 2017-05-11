function Params = stimdefSPL(EXP);
% stimdefSPL - definition of stimulus and GUI for simple SPL stepping 
%    stimulus paradigm
%    P=stimdefSPL(EXP) returns the definition for the SPL
%    stimulus paradigm. The definition P is a GUIpiece that can be rendered
%    by GUIpiece/draw. Stimulus definition like stimdefSPL are usually
%    called by StimGUI, which combines the parameter panels with
%    a generic part of stimulus GUIs. The input argument EXP contains 
%    Experiment definition, which co-determines the realization of
%    the stimulus: availability of DAC channels, calibration, recording
%    side, etc.
%
%    See also stimGUI, stimDefDir, Experiment, makestimFS, stimparamsFS.

PairStr = ' Pairs of numbers are interpreted as [left right].';
ClickStr = ' Click button to select ';
%---Carrier frequency GUIpanel
Frequency = FreqPanel('carrier frequency', EXP);
% ---Levels
SPLsweep = SPLstepper('SPL', EXP);
% ---SAM
Sam = SAMpanel('modulation', EXP,''); % 
Sam = sameExtent(Sam,SPLsweep,'X'); % adjust width of Mod to match SPLsweep
% ---Durations
Dur = DurPanel('-', EXP);
% ---Pres
Pres = PresentationPanel;
% ---Summary
summ = Summary(17);

%====================
Params=GUIpiece('Params'); % upper half of GUI: parameters

Params = add(Params, summ);
Params = add(Params, SPLsweep, nextto(summ), [10 0]);
Params = add(Params, Sam, below(SPLsweep), [0 6]);
Params = add(Params, Frequency, nextto(SPLsweep), [10 0]);
Params = add(Params, Dur, below(Frequency) ,[0 10]);
Params = add(Params, Pres, nextto(Dur) ,[5 0]);
Params = add(Params, PlayTime, below(Dur) , [0 7]);




