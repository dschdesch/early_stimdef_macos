function Modsweep=SAMDepthStepper(T, EXP, Prefix, IncludeTheta, NoTol);
% SAMDepthStepper - modulation depth stepping panel for stimulus GUIs.
%   S=SAMDepthStepper(Title, EXP) returns a GUIpanel M allowing the 
%   user to specify a series of modulation depths. Guipanel S has title
%   Title. EXP is the  experiment definition, from which the number of DAC
%   (1 or 2) is determined.
%
%   The paramQuery objects contained in F are named: 
%           ModFreq: modulation frequency in Hz
%    ModFreqTolMode: toggle selecting whether frequencies should be
%                    realized exactly, or whether memory-saving rounding is
%                    allowed.
%     StartModDepth: start modulation depth in % (100%==full AM)
%      StepModdepth: step modulation depth in %
%       EndModDepth: end modulation depth in % (100%==full AM)
%     ModStartPhase: starting phase of modulation in Cycles (0=cos)
%            ModITD: Interaural delay of modulation
%             Theta: Modulation angle. Theta = 0 results in AM; Theta=0.25
%                    is QFM; other values give mixed modulation
%
%   SAMDepthStepper is a helper function for stimulus definitions like stimdefDEP.
% 
%   M=SAMDepthStepper(Title, EXP, Prefix) prepends the string Prefix
%   to the paramQuery names, e.g. ModFreq -> NoiseModFreq, etc.
%   Default Prefix is '', i.e., no prefix.
%
%   M=SAMDepthStepper(Title, EXP, Prefix, 1) also includes a Theta query. Theta is
%   the modulation angle.
%
%   Use EvalSAMDepthStepper to read the values from the queries.
%
%   See StimGUI, GUIpanel, EvalSAMDepthStepper, stimdefDEP.

[Prefix, IncludeTheta, NoTol] = arginDefaults('Prefix/IncludeTheta/NoTol', '', 1, 0);

% # DAC channels fixes the allowed multiplicity of user-specied numbers
if isequal('Both', EXP.AudioChannelsUsed), 
    Nchan = 2;
    PairStr = ' Pairs of numbers are interpreted as [left right].';
else, % single Audio channel
    Nchan = 1;
    PairStr = ''; 
end
ClickStr = ' Click button to select ';

% ---Modulation
Modsweep = GUIpanel('Modsweep', T);
ModFreq = ParamQuery([Prefix 'ModFreq'], 'freq:', '15000.5 15000.5', 'Hz', ...
    'rreal/nonnegative', ['Modulation frequency.' PairStr], Nchan);
Tol = ParamQuery([Prefix 'ModFreqTolMode'], 'acuity:', '', {'economic' 'exact'}, '', [ ...
    'Exact: no rounding applied;', char(10), 'Economic: allow slight (<1 part per 1000), memory-saving rounding of frequencies;'], ...
    1, 'Fontsiz', 8);
StartModDepth = ParamQuery([Prefix 'StartModDepth'], ...
    'start depth:', '20.5 33.3', '%', 'rreal/nonnegative', ...
    ['Start modulation depth.' PairStr], Nchan);
StepModDepth = ParamQuery([Prefix 'StepModDepth'], ...
    'step depth:', '20.5 33.3', '%', 'rreal/positive', ...
    ['Step modulation depth.' PairStr], Nchan);
EndModDepth = ParamQuery([Prefix 'EndModDepth'], ...
    'end depth:', '20.5 33.3', '%', 'rreal/nonnegative', ...
    ['End modulation depth.' PairStr], Nchan);
ModStartPhase = ParamQuery([Prefix 'ModStartPhase'], ...
    'phase:', '-0.25 -0.33', 'Cycle', 'rreal', ...
    ['Starting phase of modulation. Zero means cosine phase.' PairStr], Nchan);
% ModITD = paramquery([Prefix 'ModITD'], 'ITD:', '-123.44', 'ms', ...
%     'rreal', 'Interaural delay of modulation; will be superimposed on waveform ITD!. Positive values correspond to IPSI LEADING.',1);
Theta = ParamQuery([Prefix 'ModTheta'], ...
    'theta:', '-0.25 -0.33', 'Cycle', 'rreal', ...
    ['Modulation angle. Theta = 0 results in AM; Theta=0.25 is QFM; other values give mixed modulation.' PairStr], Nchan);

Modsweep = add(Modsweep, ModFreq);
Modsweep = add(Modsweep, StartModDepth, below(ModFreq));
Modsweep = add(Modsweep, StepModDepth, alignedwith(StartModDepth));
Modsweep = add(Modsweep, EndModDepth, alignedwith(StepModDepth));
Modsweep = add(Modsweep, ModStartPhase, alignedwith(EndModDepth));
% Modsweep = add(Modsweep, ModITD, alignedwith(ModStartPhase));

if IncludeTheta,
    Modsweep = add(Modsweep,Theta, 'aligned', [0 -5]);
end
if ~isequal('notol', NoTol),
    Modsweep = add(Modsweep, Tol, nextto(ModFreq) , [0 5]);
end



