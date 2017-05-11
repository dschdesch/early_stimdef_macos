function Params = stimdefWAV(EXP);
% stimdefWAV - definition of stimulus and GUI for WAV stimulus paradigm
%    P=stimdefWAV(EXP) returns the definition for the WAV (wave file)
%    stimulus paradigm. The definition P is a GUIpiece that can be rendered
%    by GUIpiece/draw. Stimulus definition like stimmdefWAV are usually
%    called by StimGUI, which combines the parameter panels with
%    a generic part of stimulus GUIs. The input argument EXP contains 
%    Experiment definition, which co-determines the realization of
%    the stimulus: availability of DAC channels, calibration, recording
%    side, etc.
%
%    See also stimGUI, stimDefDir, Experiment, makestimWAV, stimparamsWAV.

PairStr = ' Pairs of numbers are interpreted as [left right].';
ClickStr = ' Click button to select ';
% ---WAV file
WAV = WavPanel('-', EXP);
% ---Attenuation
Levels = AttenuationPanel('-', EXP);
% ---Pres
Pres = PresentationPanelWAV;
% ---Summary
summ = Summary(12);

%====================
Params=GUIpiece('Params'); % upper half of GUI: parameters
Params = add(Params, summ);
Params = add(Params, WAV, nextto(summ), [10 0]);
Params = add(Params, Levels, below(WAV), [0 50]);
Params = add(Params, Pres, nextto(WAV) ,[30 0]);
Params = add(Params, PlayTime, below(Levels) , [0 10]);




