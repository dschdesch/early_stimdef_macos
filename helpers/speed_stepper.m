function speedsweep=speed_stepper(T, EXP, Prefix, Flag, Flag2);
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
    FreqEditSizeString = '100     ';
else,
    FreqEditSizeString = '100 100     ';
end

%==========frequency GUIpanel=====================
speedsweep = GUIpanel('speedsweep', T);
Startspeed = ParamQuery([Prefix 'Startspeed'], 'start:', '1000000000', 'Hz/ms', ...
    'rreal', ['Starting speed of series.' PairStr], Nchan);

Stepspeed = ParamQuery([Prefix 'Stepspeed'], 'step:', '1000000000', {'linear'}, ...
    'rreal', ['Speed step of series.' ClickStr 'step units.'], Nchan);

Endspeed = ParamQuery('Endspeed', 'end:', '1000000000', 'Hz/ms', ...
    'rreal', ['Last speed of series.' PairStr], Nchan);

Adjustspeed = ParamQuery([Prefix 'Adjustspeed'], 'adjust:', '', {'none' 'start' 'step' 'end'}, ...
    '', ['Choose which parameter to adjust when the stepsize does not exactly fit the start & end values.'], 1,'Fontsiz', 8);

Tol = ParamQuery([Prefix 'FreqTolMode'], 'acuity:', '', {'economic' 'exact'}, '', [ ...
    'Exact: no rounding applied;', char(10), 'Economic: allow slight (<1 part per 1000), memory-saving rounding of frequencies;'], ...
    1, 'Fontsiz', 8);

speedsweep = add(speedsweep, Startspeed);
speedsweep = add(speedsweep, Stepspeed, alignedwith(Startspeed));
speedsweep = add(speedsweep, Endspeed, alignedwith(Stepspeed));
speedsweep = add(speedsweep, Adjustspeed, nextto(Stepspeed), [10 0]);
if ~isequal('notol', Flag),
    speedsweep = add(speedsweep, Tol, alignedwith(Adjustspeed) , [0 -10]);
end