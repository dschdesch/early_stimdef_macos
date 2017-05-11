function P=PrecursorFlagStepper(T, EXP)
% PrecursorFlagStepper - Noise seed stepper panel for MOVN stimulus GUI.
%   F=PrecursorFlagStepper(Title, EXP) returns a GUIpanel F allowing the 
%   user to specify a series of seeds, using a linear spacing.  
%   The Guipanel F has title Title. EXP is the experiment 
%   definition, from which the number of DAC channels used (1 or 2) is
%   determined.
%
%   The paramQuery objects contained in F are named: 
%         StartPrecursorFlag: startingseed
%     StepPrecursorFlag: step seed (toggle unit)
%      EndPrecursorFlag: end seed
%        AdjustPrecursorFlag: toggle selecting which of the above params to adjust
%                    in case StepPrecursorFlag does not fit exactly.
%
%   Use EvalPrecursorFlagStepper to read the values from the queries and to
%   compute the actual frequencies specified by the above step parameters.
%
%   See StimGUI, GUIpanel, EvalPrecursorFlagStepper, makestimMOVN.

%==========PrecursorFlag GUIpanel=====================
P = GUIpanel('PrecursorFlag', T);
startPrecursorFlag = ParamQuery('startPrecursorFlag', 'start:', '10', '', 'int', '0', 1);
endPrecursorFlag = ParamQuery('endPrecursorFlag', 'end:', '20', '', 'int', '1', 1);
stepPrecursorFlag = ParamQuery('stepPrecursorFlag', 'step:', '1', '', 'posint', '1', 1);
adjustPrecursorFlag = ParamQuery('adjustPrecursorFlag', 'adjust:', '', {'none' 'start' 'step' 'end'}, ...
    '', 'Choose which parameter to adjust when the stepsize does not exactly fit the start & end values.', 1,'Fontsiz', 8);

P = add(P, startPrecursorFlag, 'below', [0 0]);
P = add(P, stepPrecursorFlag, alignedwith(startPrecursorFlag));
P = add(P, endPrecursorFlag, alignedwith(stepPrecursorFlag));
P = add(P, adjustPrecursorFlag, nextto(stepPrecursorFlag));