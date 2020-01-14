function P=SeedStepper(T, EXP)
% SeedStepper - Noise seed stepper panel for MOVN stimulus GUI.
%   F=SeedStepper(Title, EXP) returns a GUIpanel F allowing the 
%   user to specify a series of seeds, using a linear spacing.  
%   The Guipanel F has title Title. EXP is the experiment 
%   definition, from which the number of DAC channels used (1 or 2) is
%   determined.
%
%   The paramQuery objects contained in F are named: 
%         StartSeed: startingseed
%     StepSeed: step seed (toggle unit)
%      EndSeed: end seed
%        AdjustSeed: toggle selecting which of the above params to adjust
%                    in case StepSeed does not fit exactly.
%
%   Use EvalSeedStepper to read the values from the queries and to
%   compute the actual frequencies specified by the above step parameters.
%
%   See StimGUI, GUIpanel, EvalSeedStepper, makestimMOVN.

%==========Seed GUIpanel=====================
P = GUIpanel('Seed', T);
startSeed = ParamQuery('startSeed', 'start:', '100', '', 'rseed', 'Start seed used for realization of noise waveform.', 1);
endSeed = ParamQuery('endSeed', 'end:', '200', '', 'rseed', 'End seed used for realization of noise waveform.', 1);
stepSeed = ParamQuery('stepSeed', 'step:', '10', '', 'rreal/posint', 'Step seed used for realization of noise waveform..', 1);
adjustSeed = ParamQuery('adjustSeed', 'adjust:', '', {'none' 'start' 'step' 'end'}, ...
    '', 'Choose which parameter to adjust when the stepsize does not exactly fit the start & end values.', 1,'Fontsiz', 8);

P = add(P, startSeed, 'below', [0 0]);
P = add(P, stepSeed, alignedwith(startSeed));
P = add(P, endSeed, alignedwith(stepSeed));
P = add(P, adjustSeed, nextto(stepSeed));