function Params = stimdefBBFM(EXP)
% stimdefBBFM - definition of stimulus and GUI for BBFM stimulus paradigm
%    P=stimdefBBFM(EXP) returns the definition for the BBFM (Binaural Beat
%    changing the Frequency of the Carrier)
%    stimulus paradigm. The definition P is a GUIpiece that can be rendered
%    by GUIpiece/draw. Stimulus definition like stimmdefBBFM are usually
%    called by StimGUI, which combines the parameter panels with
%    a generic part of stimulus GUIs. The input argument EXP contains 
%    Experiment definition, which co-determines the realization of
%    the stimulus: availability of DAC channels, calibration, recording
%    side, etc.
%
%    See also stimGUI, stimDefDir, Experiment, makestimBBFM.

PairStr = ' Pairs of numbers are interpreted as [left right].';
ClickStr = ' Click button to select ';
% ---Carrier frequency panel
%Fsweep = FrequencyStepper('carrier frequency', EXP, '', '', 'nobinaural');

% ---SAM
Sam = SAMstepper('SAM', EXP);

% ---Beat freq panel
beatFreqPanel = BeatFreqPanel('beats', EXP, '', '', 'modulation');
beatFreqPanel = sameextent(beatFreqPanel,Sam,'X'); % adjust width

% ---Carrier frequency
freqPanel = FreqPanel('carrier frequency', EXP);
freqPanel = sameextent(freqPanel,Sam,'X');

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
Params = add(Params, Sam, nextto(summ), [10 0]);
Params = add(Params, beatFreqPanel, below(Sam), [0 6]);
Params = add(Params, freqPanel, below(beatFreqPanel), [0 6]);
Params = add(Params, Levels, nextto(Sam), [10 0]);
Params = add(Params, Dur, below(Levels) ,[0 10]);
Params = add(Params, Pres, nextto(Dur) ,[5 0]);
Params = add(Params, PlayTime, below(Dur) , [0 7]);




