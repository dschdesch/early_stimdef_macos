function dB_maskersweep=dB_maskerstepper(T, EXP, Prefix, Flag, Flag2);
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
%      EndW: end dB_masker in Hz or in octave
%        AdjustFreq: toggle selecting which of the above params to adjust
%                    in case StepdB_masker does not fit exactly.
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

%==========dB_masker GUIpanel=====================
dB_maskersweep = GUIpanel('dB_maskersweep', T);
StartdB_masker = ParamQuery([Prefix 'StartdB_masker'], 'start:', FreqEditSizeString, 'dB', ...
    'rreal', ['Starting dB_masker of series.' PairStr], Nchan);
StepdB_masker = ParamQuery([Prefix 'StepdB_masker'], 'step:', '2', {'dB'}, ...
    'rreal/positive', ['dB_masker step of series.' ClickStr 'step units.'], Nchan);
EnddB_masker = ParamQuery('EnddB_masker', 'end:', FreqEditSizeString, 'dB', ...
    'rreal', ['Last dB_masker of series.' PairStr], Nchan);
AdjustdB_masker = ParamQuery([Prefix 'AdjustdB_masker'], 'adjust:', '', {'none' 'start' 'step' 'end'}, ...
    '', ['Choose which parameter to adjust when the stepsize does not exactly fit the start & end values.'], 1,'Fontsiz', 8);
Tol = ParamQuery([Prefix 'FreqTolMode'], 'acuity:', '', {'economic' 'exact'}, '', [ ...
    'Exact: no rounding applied;', char(10), 'Economic: allow slight (<1 part per 1000), memory-saving rounding of frequencies;'], ...
    1, 'Fontsiz', 8);

dB_maskersweep = add(dB_maskersweep, StartdB_masker);
dB_maskersweep = add(dB_maskersweep, StepdB_masker, alignedwith(StartdB_masker));
dB_maskersweep = add(dB_maskersweep, EnddB_masker, alignedwith(StepdB_masker));
dB_maskersweep = add(dB_maskersweep, AdjustdB_masker, nextto(StepdB_masker), [10 0]);
if ~isequal('notol', Flag),
    dB_maskersweep = add(dB_maskersweep, Tol, alignedwith(AdjustdB_masker) , [0 -10]);
end