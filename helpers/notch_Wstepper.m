function Wsweep=notch_Wstepper(T, EXP, Prefix, Flag, Flag2);
% notch_Wstepper - generic notch width stepper panel for stimulus GUIs.
%   Wsweep=notch_Wstepper(Title, EXP) returns a GUIpanel F allowing the 
%   user to specify a series of notch width, using either be logarithmic or
%   linear spacing.  The Guipanel Wsweep has title Title. EXP is the experiment 
%   definition, from which the number of DAC channels used (1 or 2) is
%   determined.
%
%   The paramQuery objects contained in F are named: 
%         StartW: starting notch in Hz or in octave
%     StepW: step in Hz or Octaves (toggle unit)
%      EndW: end frequency in Hz or in octave
%        AdjustFreq: toggle selecting which of the above params to adjust
%                    in case StepFrequency does not fit exactly.
%       FreqTolMode: toggle selecting whether frequencies should be
%                    realized exactly, or whether memory-saving rounding is
%                    allowed.
%
%   notch_Wstepper is a helper function for stimulus generators like 
%   makestimFS.
% 
%   F=notch_Wstepper(Title, ChanSpec, Prefix) prepends the string Prefix
%   to the paramQuery names, e.g. StartFreq -> ModStartFreq, etc.
%
%   Use Evalnotch_Wstepper to read the values from the queries and to
%   compute the actual frequencies specified by the above step parameters.
%
%   See StimGUI, GUIpanel, Evalnotch_Wstepper.

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
if isequal('nobinaural', Flag2), % fixed monuaral, indep of experiment: reduce width
    FreqEditSizeString = '15000.5';
else,
    FreqEditSizeString = '15000.5';
end

%==========frequency GUIpanel=====================
Wsweep = GUIpanel('Wsweep', T);
StartW = ParamQuery([Prefix 'StartW'], 'start:', FreqEditSizeString, 'Hz', ...
    'rreal', ['Starting frequency of series.' PairStr], Nchan);

StepW = ParamQuery([Prefix 'StepW'], 'step:', '12000', {'Hz' 'Octave'}, ...
    'rreal/positive', ['Frequency step of series.' ClickStr 'step units.'], Nchan);

EndW = ParamQuery('EndW', 'end:', FreqEditSizeString, 'Hz', ...
    'rreal/positive', ['Last frequency of series.' PairStr], Nchan);

AdjustW = ParamQuery([Prefix 'AdjustW'], 'adjust:', '', {'none' 'start' 'step' 'end'}, ...
    '', ['Choose which parameter to adjust when the stepsize does not exactly fit the start & end values.'], 1,'Fontsiz', 8);

Tol = ParamQuery([Prefix 'FreqTolMode'], 'acuity:', '', {'economic' 'exact'}, '', [ ...
    'Exact: no rounding applied;', char(10), 'Economic: allow slight (<1 part per 1000), memory-saving rounding of frequencies;'], ...
    1, 'Fontsiz', 8);

Wsweep = add(Wsweep, StartW);
Wsweep = add(Wsweep, StepW, alignedwith(StartW));
Wsweep = add(Wsweep, EndW, alignedwith(StepW));
Wsweep = add(Wsweep, AdjustW, nextto(StepW), [10 0]);
if ~isequal('notol', Flag),
    Wsweep = add(Wsweep, Tol, alignedwith(AdjustW) , [0 -10]);
end