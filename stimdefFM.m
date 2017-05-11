function Params = stimdefFM(EXP);
% stimdefFS - definition of stimulus and GUI for FS stimulus paradigm
%    P=stimdefFS(EXP) returns the definition for the FS (Freqency Sweep)
%    stimulus paradigm. The definition P is a GUIpiece that can be rendered
%    by GUIpiece/draw. Stimulus definition like stimmdefFS are usually
%    called by StimGUI, which combines the parameter panels with
%    a generic part of stimulus GUIs. The input argument EXP contains 
%    Experiment definition, which co-determines the realization of
%    the stimulus: availability of DAC channels, calibration, recording
%    side, etc.
%
%    See also stimGUI, stimDefDir, Experiment, makestimFS.

PairStr = ' Pairs of numbers are interpreted as [left right].';
ClickStr = ' Click button to select ';
%==========Carrier frequency GUIpanel=====================
Fsweep = ChirpPanel('chirp', EXP);

% ---Levels
Levels = SPLpanel('-', EXP);
% ---Durations
Dur = DurPanel('-', EXP);
% ---Pres
Pres = PresentationPanel;

%====================
Params=GUIpiece('Params'); % upper half of GUI: parameters
Params = add(Params, Fsweep);
Params = add(Params, Levels, nextto(Fsweep), [10 0]);
Params = add(Params, Dur, below(Levels) ,[0 10]);
Params = add(Params, Pres, nextto(Dur) ,[5 0]);
Params = add(Params, PlayTime, below(Dur) , [0 7]);




