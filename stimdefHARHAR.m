function Params = stimdefHARHAR(EXP);
% stimdefHARHAR - definition of stimulus and GUI for HARHAR stimulus paradigm
%    P=stimdefHARHAR(EXP) returns the definition for the HAR
%    stimulus paradigm (Cedolin & Delgutte 2010). The definition P is a GUIpiece that can be rendered
%    by GUIpiece/draw. Stimulus definition like stimmdefARMIN are usually
%    called by StimGUI, which combines the parameter panels with
%    a generic part of stimulus GUIs. The input argument EXP contains 
%    Experiment definition, which co-determines the realization of
%    the stimulus: availability of DAC channels, calibration, recording
%    side, etc.
%
%    See also stimGUI, stimDefDir, Experiment, makestimARMIN, stimparamsARMIN.

PairStr = ' Pairs of numbers are interpreted as [left right].';
ClickStr = ' Click button to select ';

%==========Carrier frequency GUIpanel=====================
Fsweep = FrequencyStepperHARHAR('frequencies', EXP, '', '', 'nobinaural');

% --- SPL
SPLsweep = SPLstepper('SPL', EXP,'','','','In dB SPL per component. ');

% --- Phase
Phase = PhaseHARHAR('Phase', EXP);

% --- Distortion
Distortion = DistortionHARHAR('Distortion', EXP); 

% --- LP Noise
Noise = LpNoiseHARHAR('Noise', EXP);

% ---Durations
Dur = DurPanel('-', EXP, '', 'nophase');
% ---Pres
Pres = PresentationPanel_XY('F0', 'SPL');
% ---Summary
summ = Summary(19);

%====================
Params=GUIpiece('Params'); % upper half of GUI: parameters
Params = add(Params, summ);
Params = add(Params, Fsweep, nextto(summ) ,[10 0]);
Params = add(Params, SPLsweep, nextto(Fsweep) ,[10 0]);
Params = add(Params, Phase, below(Fsweep) ,[0 0]);
Params = add(Params, Noise, nextto(SPLsweep) ,[10 0]);
Params = add(Params, Dur, below(summ) ,[0 0]);
Params = add(Params, Distortion, nextto(Dur) ,[0 0]);
Params = add(Params, Pres, below(SPLsweep) ,[0 0]);
Params = add(Params, PlayTime, below(Pres) , [0 0]);




