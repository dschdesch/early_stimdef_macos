function Params = stimdefTCKL(EXP);
% stimdefRF - definition of stimulus and GUI for RF stimulus paradigm
%    P=stimdefRF(EXP) returns the definition for the RF (Receptive Field)
%    stimulus paradigm. The definition P is a GUIpiece that can be rendered
%    by GUIpiece/draw. Stimulus definition like stimmdefFS are usually
%    called by StimGUI, which combines the parameter panels with
%    a generic part of stimulus GUIs. The input argument EXP contains 
%    Experiment definition, which co-determines the realization of
%    the stimulus: availability of DAC channels, calibration, recording
%    side, etc.
%
%    See also stimGUI, stimDefDir, Experiment, makestimRF.

PairStr = ' Pairs of numbers are interpreted as [left right].';
ClickStr = ' Click button to select ';

list_params={{'BF_TCKL','freq. tickling comp.',' 1000 ','Hz','rreal/positive','tooltip',1},...
    {'SPL_TCKL','level tickling comp',' 100 ','dB SPL','rreal/positive','tooltip',1},...
{'side_TCKL','tickling side',' L ','','string','tooltip',1},...
};


Miscl=Misclpanel('Tickling', EXP, list_params);

%==========Carrier frequency GUIpanel=====================
Fsweep = FrequencyStepper('carrier frequency', EXP);
SPLsweep = SPLstepper('SPL', EXP);
% ---SAM
Sam = SAMpanel('SAM', EXP);
Sam = sameextent(Sam,Fsweep,'X'); % adjust width of Mod to match Fsweep

% ---Durations
Dur = DurPanel('-', EXP,'', 'basicsonly_mono');
% ---Pres
Pres = PresentationPanel_XY('Freq', 'SPL');
% ---Summary
summ = Summary(17);
%====================
Params=GUIpiece('Params'); % upper half of GUI: parameters

Params = add(Params, summ);
Params = add(Params, Fsweep, nextto(summ), [10 0]);
Params = add(Params, SPLsweep, nextto(Fsweep), [10 0]);
Params = add(Params, Dur, nextto(SPLsweep) ,[4 0]);
Params = add(Params, Sam, below(Fsweep), [0 23]);
Params = add(Params, Pres, nextto(Sam) ,[10 5]);
Params = add(Params, PlayTime, below(Sam) , [20 3]);
Params = add(Params, Miscl, below(Dur) , [20 3]);



