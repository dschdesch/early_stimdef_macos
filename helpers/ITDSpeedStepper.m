function P=ITDSpeedStepper(T, EXP)
% ITDSpeedStepper - Interaural speed stepper panel for MOVN stimulus GUs.
%   F=ITDSpeedStepper(Title, EXP) returns a GUIpanel F allowing the 
%   user to specify a series of Speeds, using a linear spacing.  
%   The Guipanel F has title Title. EXP is the experiment 
%   definition, from which the number of DAC channels used (1 or 2) is
%   determined.
%
%   The paramQuery objects contained in F are named: 
%         StartSpeed: starting frequency in Hz
%     StepSpeed: step in Hz or Octaves (toggle unit)
%      EndSpeed: end frequency in Hz
%        AdjustSpeed: toggle selecting which of the above params to adjust
%                    in case StepFrequency does not fit exactly.
%
%   Use EvalSpeedStepper to read the values from the queries and to
%   compute the actual frequencies specified by the above step parameters.
%
%   See StimGUI, GUIpanel, EvalITDSpeedStepper, makestimMOVN.

ITDstring = ['Positive values correspond to ' upper(strrep(EXP.ITDconvention, 'Lead', ' Lead')) '.'];

%==========ITDSpeed GUIpanel=====================
P = GUIpanel('ITDSpeed', T);
startSpeed = ParamQuery('startSpeed', 'start:', '100', 'us/s', 'rreal', 'Start value of interaural speed.', 1);
endSpeed = ParamQuery('endSpeed', 'end:', '10000', 'us/s', 'rreal', 'End value of interaural speed.', 1);
stepSpeed = ParamQuery('stepSpeed', 'step:', '100', 'us/s', 'rreal/positive', 'Step value of interaural speed.', 1);
adjustSpeed = ParamQuery('adjustSpeed', 'adjust:', '', {'none' 'start' 'step' 'end'}, ...
    '', 'Choose which parameter to adjust when the stepsize does not exactly fit the start & end values.', 1,'Fontsiz', 8);

P = add(P, startSpeed, 'below', [0 0]);
P = add(P, stepSpeed, alignedwith(startSpeed));
P = add(P, endSpeed, alignedwith(stepSpeed));
P = add(P, adjustSpeed, nextto(stepSpeed));