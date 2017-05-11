function Params = stimdefBBFB(EXP)
% stimdefBBFB - definition of stimulus and GUI for BBFB stimulus paradigm
%    P=stimdefBBFB(EXP) returns the definition for the BBFB (Binaural Beat
%    changing the Frequency of the Carrier)
%    stimulus paradigm. The definition P is a GUIpiece that can be rendered
%    by GUIpiece/draw. Stimulus definition like stimmdefBBFB are usually
%    called by StimGUI, which combines the parameter panels with
%    a generic part of stimulus GUIs. The input argument EXP contains 
%    Experiment definition, which co-determines the realization of
%    the stimulus: availability of DAC channels, calibration, recording
%    side, etc.
%
%    See also stimGUI, stimDefDir, Experiment, makestimBBFB.

PairStr = ' Pairs of numbers are interpreted as [left right].';
ClickStr = ' Click button to select ';
% ---Beat frequency stepper
Fsweep = FrequencyStepper('beats', EXP, 'Beat', 'notol', 'nobinaural');

% ---Freq panel
freqPanel = FreqPanel('carrier frequency', EXP);
Fsweep = sameextent(Fsweep,freqPanel,'X'); % adjust width

% ---SAM
Sam = SAMpanel('SAM', EXP);
Sam = sameextent(Sam,freqPanel,'X'); % adjust width

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
Params = add(Params, freqPanel, below(Fsweep), [0 6]);
Params = add(Params, Sam, below(freqPanel), [0 6]);
Params = add(Params, Levels, nextto(Fsweep), [10 0]);
Params = add(Params, Dur, below(Levels) ,[0 10]);
Params = add(Params, Pres, nextto(Dur) ,[5 0]);
Params = add(Params, PlayTime, below(Dur) , [0 7]);




