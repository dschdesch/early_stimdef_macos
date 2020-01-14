function Params = stimdefENH_DURC(EXP);
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
{'minf','min. frequency',' 10000 ','Hz','rreal/positive','tooltip',1},...
{'maxf','max. frequency',' 10000 ','Hz','rreal/positive','tooltip',1},...
{'dBdiff','dB of C related to T',' 100 ','dB','rreal','tooltip',1},...
{'sideT','test side',' L ','','string','tooltip',1},...
{'sband','side band',' B ','','string','tooltip',1},...
{'stim_type','stim type',' B ','','string','tooltip',1},...
{'polarity','polarity',' 0 ','','rreal','tooltip',1},...
{'probe_alone','probe alone',' 0 ','','rreal','tooltip',1},...
{'delta_T','time btw C and T',' 1000 ','ms','rreal','tooltip',1}
};

Miscl=Misclpanel('Miscl', EXP, list_params);

% durC = DurPanel('duration conditioner', EXP, 'whatev', 'basicsonly_mono');
durT = DurPanel('duration test', EXP, 'test', 'basicsonly_mono');

condBurstDursweep = condBurstDurstepper('condBurstDur', EXP);

% ---Levels
Levels = SPLpanel('-', EXP);


Wsweep = notch_Wstepper('notch width', EXP,'', 'nobinaural');

% ---Pres
Pres = PresentationPanel_XY('W', 'condBurstDur');

summ = Summary(19);
%====================
Params=GUIpiece('Params'); % upper half of GUI: parameters
Params = add(Params, summ);
Params = add(Params, condBurstDursweep, nextto(summ), [10 0]);
Params = add(Params, Wsweep, nextto(condBurstDursweep) ,[120 0]);

Params = add(Params, Miscl, nextto(Wsweep) ,[0 0]);
Params = add(Params, durT, below(condBurstDursweep) ,[10 0]);
Params = add(Params, Levels, nextto(durT) ,[0 00]);
Params = add(Params, Pres, below(durT) ,[0 0]);
% Params = add(Params, durT, nextto(durC) ,[0 0]);