function Params = stimdefCFS(EXP);
% stimdefCFS - definition of stimulus and GUI for CFS stimulus paradigm
%    P=stimdefCFS(EXP) returns the definition for the CFS (Click Freqency Sweep)
%    stimulus paradigm. The definition P is a GUIpiece that can be rendered
%    by GUIpiece/draw. Stimulus definition like stimmdefCFS are usually
%    called by StimGUI, which combines the parameter panels with
%    a generic part of stimulus GUIs. The input argument EXP contains 
%    Experiment definition, which co-determines the realization of
%    the stimulus: availability of DAC channels, calibration, recording
%    side, etc.
%
%    See also stimGUI, stimDefDir, Experiment, makestimCFS, stimparamsCFS.

PairStr = ' Pairs of numbers are interpreted as [left right].';
ClickStr = ' Click button to select ';
%==========Carrier frequency GUIpanel=====================
Fsweep = FrequencyStepper('click frequency', EXP);
% ---Clicks
Clicks = ClickPanel('click parameters', EXP);
Clicks = sameextent(Clicks,Fsweep,'X'); % adjust width of Mod to match Freq
% ---Levels
Levels = SPLpanel('-', EXP);
% ---Durations
Dur = DurPanelClicks('-', EXP);
% ---Pres
Pres = PresentationPanel;
% ---Summary
summ = Summary(17);

%====================
Params=GUIpiece('Params'); % upper half of GUI: parameters
Params = add(Params, summ);
Params = add(Params, Fsweep, nextto(summ), [10 0]);
Params = add(Params, Clicks, below(Fsweep) ,[0 10]);
Params = add(Params, Levels, nextto(Fsweep), [10 0]);
Params = add(Params, Dur, below(Levels) ,[0 10]);
Params = add(Params, Pres, nextto(Dur) ,[5 0]);
Params = add(Params, PlayTime, below(Clicks) , [0 7]);




