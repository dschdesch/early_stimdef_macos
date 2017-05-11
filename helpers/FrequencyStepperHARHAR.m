function Fsweep=FrequencyStepperHARHAR(T, EXP, Prefix, Flag, Flag2);
% FrequencyStepperARMIN - generic frequency stepper panel for stimulus GUIs.
%   F=FrequencyStepperARMIN(Title, EXP) returns a GUIpanel F allowing the 
%   user to specify a series of frequencies, using either be logarithmic or
%   linear spacing.  The Guipanel F has title Title. EXP is the experiment 
%   definition, from which the number of DAC channels used (1 or 2) is
%   determined.
%
%   The paramQuery objects contained in F are named: 
%         StartFreq: starting frequency in Hz
%     StepFrequency: step in Hz or Octaves (toggle unit)
%      EndFrequency: end frequency in Hz
%        AdjustFreq: toggle selecting which of the above params to adjust
%                    in case StepFrequency does not fit exactly.
%       FreqTolMode: toggle selecting whether frequencies should be
%                    realized exactly, or whether memory-saving rounding is
%                    allowed.
%       LowPolarity: the sign of the correlation below the flip frequency
%          CorrUnit: the varied channel (I/C), of which part of the
%                    spectrum is modified
%
%   FrequencyStepperARMIN is a helper function for stimulus generators like 
%   makestimARMIN.
% 
%   F=FrequencyStepperARMIN(Title, ChanSpec, Prefix) prepends the string Prefix
%   to the paramQuery names, e.g. StartFreq -> ModStartFreq, etc.
%
%   Use EvalFrequencyStepperARMIN to read the values from the queries and to
%   compute the actual frequencies specified by the above step parameters.
%
%   See StimGUI, GUIpanel, EvalFrequencyStepperARMIN, makestimARMIN.

[Prefix, Flag, Flag2] = arginDefaults('Prefix/Flag/Flag2', '');

% # DAC channels and Flag2 determines the allowed multiplicity of user-specied numbers
if isequal('Both', EXP.AudioChannelsUsed) && ~isequal('nobinaural', Flag2), 
    Nchan = 2;
    PairStr = ' Pairs of numbers are interpreted as [left right].';
else, % single Audio channel
    Nchan = 1;
    PairStr = ''; 
end
ClickStr = ' Click button to select ';

switch EXP.Recordingside,
    case 'Left', Lstr = 'Left=Ipsi'; Rstr = 'Right=Contra';
    case 'Right', Lstr = 'Left=Contra'; Rstr = 'Right=Ipsi';
end
switch EXP.AudioChannelsUsed,
    case 'Left', DACstr = {Lstr};
    case 'Right', DACstr = {Rstr};
    case 'Both', DACstr = {Lstr Rstr 'Both'};
end

%==========frequency GUIpanel=====================
Fsweep = GUIpanel('Fsweep', T);
StartNHN = ParamQuery([Prefix 'StartNHN'], 'CF/F0 start:', '15000.5 15000.5', '', ...
    'rreal/positive', ['Starting neural harmonic number (= CF / F0) of series.' PairStr], Nchan);
StepNHN = ParamQuery([Prefix 'StepNHN'], 'CF/F0 step:', '12000', '', ...
    'rreal/positive', ['neural harmonic number (= CF / F0)  step of series.' ClickStr 'step units.'], Nchan);
EndNHN = ParamQuery([Prefix 'EndNHN'], 'CF/F0 end:', '12000.1 12000.1', '', ...
    'rreal/positive', ['Last neural harmonic number (= CF / F0) of series.' PairStr], Nchan);
AdjustFreq = ParamQuery([Prefix 'AdjustFreq'], 'adjust:', '', {'none' 'start' 'step' 'end'}, ...
    '', ['Choose which parameter to adjust when the stepsize does not exactly fit the start & end values.'], 1,'Fontsiz', 8);
Tol = ParamQuery([Prefix 'FreqTolMode'], 'acuity:', '', {'economic' 'exact'}, '', [ ...
    'Exact: no rounding applied;', char(10), 'Economic: allow slight (<1 part per 1000), memory-saving rounding of frequencies;'], ...
    1, 'Fontsiz', 8);
HarLowest = ParamQuery('HarLow', 'Lowest Har:', '2', '', ...
    'rreal/positive', 'Lowest Harmonic in the stumulus.');
HarHighest = ParamQuery('HarHigh', 'Highest Har:', '20', '', ...
    'rreal/positive', 'Highest Harmonic in the stumulus.');
CF = ParamQuery('CF', 'CF:', '1200', ...
    'Hz','rreal/positive', 'Fill in the CF of the cell');

Fsweep = add(Fsweep, StartNHN);
Fsweep = add(Fsweep, StepNHN, alignedwith(StartNHN));
Fsweep = add(Fsweep, EndNHN, alignedwith(StepNHN));
Fsweep = add(Fsweep, AdjustFreq, nextto(StepNHN), [10 0]);
Fsweep = add(Fsweep, HarLowest, below(EndNHN), [0 2]);
Fsweep = add(Fsweep, HarHighest, below(HarLowest), [0 2]);
Fsweep = add(Fsweep, CF, below(HarHighest), [10 0]);

if ~isequal('notol', Flag),
    Fsweep = add(Fsweep, Tol, alignedwith(AdjustFreq) , [0 -10]);
end





