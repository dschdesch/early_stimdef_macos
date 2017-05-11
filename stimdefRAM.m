function Params = stimdefRAM(EXP)
% stimdefRAM - definition of stimulus and GUI for RAM stimulus paradigm
%    P=stimdefRAM(EXP) returns the definition for the RAM (Response Area Modulation)
%    stimulus paradigm. The definition P is a GUIpiece that can be rendered
%    by GUIpiece/draw. Stimulus definition like stimmdefFS are usually
%    called by StimGUI, which combines the parameter panels with
%    a generic part of stimulus GUIs. The input argument EXP contains 
%    Experiment definition, which co-determines the realization of
%    the stimulus: availability of DAC channels, calibration, recording
%    side, etc.
%
%    See also stimGUI, stimDefDir, Experiment, makestimRAM.

PairStr = ' Pairs of numbers are interpreted as [left right].';
ClickStr = ' Click button to select ';

% ---SPL sweep
SPLsweep = SPLstepper('SPL', EXP);

% ---SAM sweep
Samsweep = SAMstepper('SAM', EXP);

% ---Carrier frequency
freqPanel = FreqPanel('carrier frequency', EXP);
freqPanel = sameextent(freqPanel,Samsweep,'X'); % adjust width

% ---Durations
Dur = DurPanel('-', EXP);

% ---Pres
Pres = PresentationPanel_XY('Fmod', 'SPL');
Pres = sameextent(Pres,SPLsweep,'X'); % adjust width

% ---Summary
summ = Summary(17);

%====================
Params=GUIpiece('Params'); % upper half of GUI: parameters
Params = add(Params, summ);
Params = add(Params, Samsweep, nextto(summ), [10 0]);
Params = add(Params, SPLsweep, nextto(Samsweep), [10 0]);
Params = add(Params, freqPanel, below(Samsweep), [0 10]);
Params = add(Params, Pres, below(SPLsweep) ,[0 10]);
Params = add(Params, Dur, nextto(Pres) ,[10 0]);
Params = add(Params, PlayTime, below(freqPanel) , [0 10]);




