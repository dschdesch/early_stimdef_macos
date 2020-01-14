function Params = stimdefBBFC(EXP)
% stimdefBBFC - definition of stimulus and GUI for BBFC stimulus paradigm
%    P=stimdefBBFC(EXP) returns the definition for the BBFC (Binaural Beat
%    changing the Frequency of the Carrier)
%    stimulus paradigm. The definition P is a GUIpiece that can be rendered
%    by GUIpiece/draw. Stimulus definition like stimmdefBBFC are usually
%    called by StimGUI, which combines the parameter panels with
%    a generic part of stimulus GUIs. The input argument EXP contains 
%    Experiment definition, which co-determines the realization of
%    the stimulus: availability of DAC channels, calibration, recording
%    side, etc.
%
%    See also stimGUI, stimDefDir, Experiment, makestimBBFC.

PairStr = ' Pairs of numbers are interpreted as [left right].';
ClickStr = ' Click button to select ';
% ---Carrier frequency panel
Fsweep = FrequencyStepper('carrier frequency', EXP, '', '', 'nobinaural');

% ---Beat freq panel
beatFreqPanel = BeatFreqPanel('beats', EXP);
beatFreqPanel = sameextent(beatFreqPanel,Fsweep,'X'); % adjust width

% ---SAM
Sam = SAMpanel('SAM', EXP);
Sam = sameextent(Sam,Fsweep,'X'); % adjust width

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
Params = add(Params, Fsweep, nextto(summ), [10 0]);
Params = add(Params, beatFreqPanel, below(Fsweep), [0 6]);
Params = add(Params, Sam, below(beatFreqPanel), [0 6]);
Params = add(Params, Levels, nextto(Fsweep), [10 0]);
Params = add(Params, Dur, below(Levels) ,[0 10]);
Params = add(Params, Pres, nextto(Dur) ,[5 0]);
Params = add(Params, PlayTime, below(Dur) , [0 7]);




