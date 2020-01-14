function Params = stimdefMOVN(EXP);
% stimdefMOVN - definition of stimulus and GUI for MOVN stimulus paradigm
%    P = stimdefMOVN(EXP) returns the definition for the MOVN (moving noise)
%    stimulus paradigm. The definition P is a GUIpiece that can be rendered
%    by GUIpiece/draw. Stimulus definition like stimmdefZW are usually
%    called by StimGUI, which combines the parameter panels with
%    a generic part of stimulus GUIs. The input argument EXP contains 
%    Experiment definition, which co-determines the realization of
%    the stimulus: availability of DAC channels, calibration, recording
%    side, etc.
%
%    See also stimGUI, stimDefDir, Experiment, makestimMOVN.

% ---Noise
Noise = NoisePanel('Noise parameters', EXP,'','ConstNoiseSeed'); % include SPL etc; exclude seed; 'mono' not available in this EARLY version
% ---NoiseSeed
NoiseSeed = SeedStepper('Noise seed', EXP);
% ---Interaural speed
Speed = ITDSpeedStepper('Interaural speed', EXP);
% ---Durations
Dur = MovNoiseDurPanel('Durations', EXP, '', 'basicsonly_mono'); % for now, take same parameters for left and right
% ---Pres
Pres = PresentationPanel_XY('NoiseSeed', 'ITDSpeed');
% ---Summary
summ = Summary(17);
%====================
Params=GUIpiece('Params'); % upper half of GUI: parameters
Params = add(Params, summ);
Params = add(Params, Noise, nextto(summ), [10 0]);
Params = add(Params, Speed, below(Noise));
Params = add(Params, NoiseSeed, nextto(Speed), [20 0]);
Params = add(Params, Dur, nextto(Noise), [20 0]);
Params = add(Params, Pres, below(Dur) ,[0 2]);
Params = add(Params, PlayTime(), below(Speed) ,[0 5]);