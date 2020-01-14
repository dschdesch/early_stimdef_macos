function delta_Tsweep=delta_Tstepper(T, EXP, Prefix, Flag, Flag2);
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
%      EndW: end delta_T in Hz or in octave
%        AdjustFreq: toggle selecting which of the above params to adjust
%                    in case Stepdelta_T does not fit exactly.
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
if nargin < 5, Flag2 = ''; end
if nargin < 4, Flag = ''; end
if nargin < 3, Prefix = ''; end

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
    FreqEditSizeString = '8';
else,
    FreqEditSizeString = '8 8';
end

%==========delta_T GUIpanel=====================
delta_Tsweep = GUIpanel('delta_Tsweep', T);
Startdelta_T = ParamQuery([Prefix 'Startdelta_T'], 'start:', FreqEditSizeString, 'ms', ...
    'rreal', ['Starting delta_T of series.' PairStr], Nchan);
Stepdelta_T = ParamQuery([Prefix 'Stepdelta_T'], 'step:', '2', {'ms'}, ...
    'rreal/positive', ['delta_T step of series.' ClickStr 'step units.'], Nchan);
Enddelta_T = ParamQuery('Enddelta_T', 'end:', FreqEditSizeString, 'ms', ...
    'rreal', ['Last delta_T of series.' PairStr], Nchan);
Adjustdelta_T = ParamQuery([Prefix 'Adjustdelta_T'], 'adjust:', '', {'none' 'start' 'step' 'end'}, ...
    '', ['Choose which parameter to adjust when the stepsize does not exactly fit the start & end values.'], 1,'Fontsiz', 8);
Tol = ParamQuery([Prefix 'FreqTolMode'], 'acuity:', '', {'economic' 'exact'}, '', [ ...
    'Exact: no rounding applied;', char(10), 'Economic: allow slight (<1 part per 1000), memory-saving rounding of frequencies;'], ...
    1, 'Fontsiz', 8);

delta_Tsweep = add(delta_Tsweep, Startdelta_T);
delta_Tsweep = add(delta_Tsweep, Stepdelta_T, alignedwith(Startdelta_T));
delta_Tsweep = add(delta_Tsweep, Enddelta_T, alignedwith(Stepdelta_T));
delta_Tsweep = add(delta_Tsweep, Adjustdelta_T, nextto(Stepdelta_T), [10 0]);
if ~isequal('notol', Flag),
    delta_Tsweep = add(delta_Tsweep, Tol, alignedwith(Adjustdelta_T) , [0 -10]);
end