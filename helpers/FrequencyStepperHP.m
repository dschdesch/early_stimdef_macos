function Fsweep=FrequencyStepperHP(T, EXP);
% FrequencyStepperHP - frequency stepper panel for HP stimulus GUI.
%   F=FrequencyStepperHP(Title, EXP) returns a GUIpanel F allowing the 
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
%        NHarmonics: number of harmonics of Freq
%     StartHarmonic: first harmonic
%                BW: transition bandwidth (in % of fundamental frequency)
%              Sign: positive or negative stimulus (i.e. HP+ or HP-)
%           IPDChan: chan (Left/Right) to apply interaural phase difference to 
%
%   FrequencyStepperHP is a helper function for stimulus generators like 
%   makestimHP.
%
%   Use EvalFrequencyStepperHP to read the values from the queries and to
%   compute the actual frequencies specified by the above step parameters.
%
%   See StimGUI, GUIpanel, EvalFrequencyStepperHP, makestimHP.

Nchan = 1;
PairStr = ''; 
ClickStr = ' Click button to select ';

switch EXP.Recordingside,
    case 'Left', Lstr = 'Left=Ipsi'; Rstr = 'Right=Contra';
    case 'Right', Lstr = 'Left=Contra'; Rstr = 'Right=Ipsi';
end
DACstr = {Lstr Rstr};

%==========frequency GUIpanel=====================
Fsweep = GUIpanel('Fsweep', T);
StartFreq = ParamQuery('StartFreq', 'F start:', '15000.5', 'Hz', ...
    'rreal/positive', ['Starting frequency of series.' PairStr], Nchan);
StepFreq = ParamQuery('StepFreq', 'F step:', '12000', {'Hz' 'Octave'}, ...
    'rreal/positive', ['Frequency step of series.' ClickStr 'step units.'], Nchan);
EndFreq = ParamQuery('EndFreq', 'F end:', '12000.1', 'Hz', ...
    'rreal/positive', ['Last frequency of series.' PairStr], Nchan);
AdjustFreq = ParamQuery('AdjustFreq', 'adjust:', '', {'none' 'start' 'step' 'end'}, ...
    '', 'Choose which parameter to adjust when the stepsize does not exactly fit the start & end values.', 1,'Fontsiz', 8);
Tol = ParamQuery('FreqTolMode', 'acuity:', '', {'economic' 'exact'}, '', [ ...
    'Exact: no rounding applied;', char(10), 'Economic: allow slight (<1 part per 1000), memory-saving rounding of frequencies;'], ...
    1, 'Fontsiz', 8);
StartHarmonic = ParamQuery('StartHarmonic', 'lowest harmonic:', '5', '', ...
    'rreal/positive', 'Fill in the harmonic to start with (1 = fundamental frequency). E.g. 5',1);
NHarmonics = ParamQuery('NHarmonics', '# harmonics:', '10', '', ...
    'rreal/positive', 'Fill in the number of harmonics to be presented (fundamental frequency included). E.g. 10',1);
BW = ParamQuery('BW', 'Bandwith:', '6', '', ...
    'rreal/positive', 'Fill in the bandwith of the transition (in % of fundamental frequency). E.g. 6 = 6%',1);
Version = ParamQuery('Version', 'Version', '', {'1' '2'}, ...
    '', 'Choose stimulus version .', 1);
Sign = ParamQuery('Sign', 'HP', '', {'+' '-'}, ...
    '', 'Choose positive or negative stimulus.', 1);
IPDChan = ParamQuery('IPDChan', 'IPDC:', '', DACstr, ...
    '', ['Interaural phase difference is applied to this channel.' ClickStr 'channel.']);

Fsweep = add(Fsweep, StartFreq);
Fsweep = add(Fsweep, StepFreq, alignedwith(StartFreq));
Fsweep = add(Fsweep, EndFreq, alignedwith(StepFreq));
Fsweep = add(Fsweep, AdjustFreq, nextto(StepFreq), [10 0]);
Fsweep = add(Fsweep, Tol, below(AdjustFreq), [0 0]);
Fsweep = add(Fsweep, StartHarmonic, below(EndFreq), [0 2]);
Fsweep = add(Fsweep, IPDChan, nextto(StartHarmonic), [10 0]);
Fsweep = add(Fsweep, NHarmonics, below(StartHarmonic), [0 0]);
Fsweep = add(Fsweep, BW, below(IPDChan), [0 0]);
Fsweep = add(Fsweep, Version, below(NHarmonics), [0 0]);
Fsweep = add(Fsweep, Sign, nextto(Version), [10 0]);
