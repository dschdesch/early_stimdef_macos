function Params = stimdefMASK_T(EXP);
% stimdefENH_w - definition of stimulus and GUI for ENH_w stimulus paradigm
%    P=stimdefENH_w(EXP) returns the definition for the ENH_w
%    stimulus paradigm. The definition P is a GUIpiece that can be rendered
%    by GUIpiece/draw. Stimulus definition like stimmdefENH_w are usually
%    called by StimGUI, which combines the parameter panels with
%    a generic part of stimulus GUIs. The input argument EXP contains 
%    Experiment definition, which co-determines the realization of
%    the stimulus: availability of DAC channels, calibration, recording
%    side, etc.
%
%    See also stimGUI, stimDefDir, Experiment, makestimARMIN, stimparamsARMIN.

PairStr = ' Pairs of numbers are interpreted as [left right].';
ClickStr = ' Click button to select ';
% VF,minf,maxf,deltaT

%Name, Prompt, String, Unit, Constraint, Tooltip
list_params={{'BF','notch center freq.',' 1000 ','Hz','rreal/positive','tooltip',1},...
    {'dur_probe','duration probe',' 0 ','','rreal','tooltip',1},...
    {'dB_masker','level of the ',' 100 ','dB','rreal','tooltip',1},...
    {'notchW','spectrum masker',' 1000 ','octave','rreal','tooltip',1},...
    {'stim_type','stim type',' B ','','string','tooltip',1},...
    {'sband','side band',' B ','','string','tooltip',1},...
{'minf','min. frequency',' 10000 ','Hz','rreal/positive','tooltip',1},...
{'maxf','max. frequency',' 10000 ','Hz','rreal/positive','tooltip',1},...
{'sideT','masker side',' L ','','string','tooltip',1},...
{'polarity','polarity',' 0 ','','rreal','tooltip',1},...
{'max_BW','max BW',' 0 ','','rreal','tooltip',1}
};
Miscl=Misclpanel('Miscl', EXP, list_params);

dur = DurPanel('duration', EXP, '', 'basicsonly_mono');


SPLsweep = SPLstepper('SPL', EXP);
delta_Tsweep = delta_Tstepper('delta_T', EXP);



% ---Pres
Pres = PresentationPanel_XY('W', 'SPL');

summ = Summary(19);
%====================
Params=GUIpiece('Params'); % upper half of GUI: parameters
Params = add(Params, summ);
Params = add(Params, SPLsweep, nextto(summ), [10 0]);
Params = add(Params, delta_Tsweep, nextto(SPLsweep) ,[10 0]);

Params = add(Params, Miscl, nextto(delta_Tsweep) ,[0 0]);
Params = add(Params, dur, below(SPLsweep) ,[10 0]);
Params = add(Params, Pres, below(dur) ,[0 0]);
