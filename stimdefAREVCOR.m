function Params = stimdefAREVCOR(EXP);
% stimdefARevcor - definition of stimulus and GUI for ARevcor stimulus paradigm
%    P = stimdefARevcor(EXP) returns the definition for the ARevcor (moving noise)
%    stimulus paradigm. The definition P is a GUIpiece that can be rendered
%    by GUIpiece/draw. Stimulus definition like stimmdefZW are usually
%    called by StimGUI, which combines the parameter panels with
%    a generic part of stimulus GUIs. The input argument EXP contains 
%    Experiment definition, which co-determines the realization of
%    the stimulus: availability of DAC channels, calibration, recording
%    side, etc.
%
%    See also stimGUI, stimDefDir, Experiment, makestimARevcor.

list_params={{'addprecursor','add precursor','1','','int','tooltip',1}
    {'condtype','conditioner type','T','','string','tooltip',1},...
 
     {'notchW','notch width','23','oct','rreal','tooltip',1},
       {'conddB','cond dB','25','dB','rreal','tooltip',1},  
    {'tonefreq','tone freq','2.5 2.6 2.4 2.8 2.8 2.8','Hz','rreal','tooltip',5},
    {'tonedB','tone dB','25 26 24 28 28 28','dB','rreal','tooltip',5},
   {'polarity','polarity','1','','rreal','tooltip',5}
    
};
Miscl=Misclpanel('Miscl', EXP, list_params);

% ---Noise
Noise = NoisePanel('Noise parameters', EXP,'','ConstNoiseSeed'); % include SPL etc; exclude seed; 'mono' not available in this EARLY version
% ---NoiseSeed
NoiseSeed = SeedStepper('Noise seed', EXP);
% ---Interaural speed
PrecursorFlag = PrecursorFlagStepper('PrecursorFlag', EXP);

durTone = DurPanel('duration conditioner', EXP, 'cond', 'basicsonly_mono');
durNoise = DurPanel('duration noise', EXP, '', 'basicsonly_mono');

% ---Pres
Pres = PresentationPanel_XY('N', 'P');
% ---Summary
summ = Summary(17);
%====================
Params=GUIpiece('Params'); % upper half of GUI: parameters
Params = add(Params, summ);
Params = add(Params, Noise, nextto(summ), [10 0]);
Params = add(Params, PrecursorFlag, below(Noise));
Params = add(Params, NoiseSeed, nextto(PrecursorFlag), [20 0]);
Params = add(Params, durTone, nextto(Noise), [20 0]);
Params = add(Params, durNoise, below(durTone), [0 0]);
Params = add(Params, Pres,nextto(NoiseSeed) ,[0 80]);
Params = add(Params, Miscl, below(PrecursorFlag) ,[0 5]);