function Fsweep=ChirpPanel(T, EXP, Prefix);
% ChirpPanel - generic frequency sweep panel for stimulus GUIs.
%   F=ChirpPanel(Title, EXP) returns a GUIpanel F allowing the 
%   user to specify start and end frequencies of a chirp, using either be
%   logarithmic or linear sweeping.  The Guipanel F has title Title. 
%   EXP is the experiment definition, from which the number of DAC channels
%   used (1 or 2) is determined.
%
%   The paramQuery objects contained in F are named: 
%         StartFreq: starting frequency in Hz
%           EndFreq: holding frequency in Hz
%         SweepMode: either 'Linear' or 'Logarithmic'
%             upDur: duration of the upward part of the sweep
%           holdDur: duration of the holding part of the sweep
%           downDur: duration of the downward part of the sweep
%
%   ChirpPanel is a helper function for stimulus generators like 
%   makestimFM.
% 
%   F=ChirpPanel(Title, EXP, Prefix) prepends the string Prefix
%   to the paramQuery names, e.g. StartFreq -> ModStartFreq, etc.
%
%   See StimGUI, GUIpanel, makestimFM.

if nargin<3, Prefix=''; end

% # DAC channels and Flag2 determines the allowed multiplicity of user-specied numbers
if isequal('Both', EXP.AudioChannelsUsed) 
    Nchan = 2;
    PairStr = ' Pairs of numbers are interpreted as [left right].';
else % single Audio channel
    Nchan = 1;
    PairStr = ''; 
end

%==========frequency GUIpanel=====================
Fsweep = GUIpanel('Fsweep', T);
StartFreq = ParamQuery([Prefix 'StartFreq'], 'start/end:', '15000.5 15000.5', 'Hz', ...
    'rreal/positive', ['Starting frequency of chirp.' PairStr], Nchan);
EndFreq = ParamQuery([Prefix 'EndFreq'], 'hold:', '12000.1 12000.1', 'Hz', ...
    'rreal/positive', ['Last frequency of chirp.' PairStr], Nchan);
SweepMode = ParamQuery([Prefix 'SweepMode'], 'mode:', '', {'Linear' 'Logarithmic'}, ...
    '', 'Sweeping mode.', Nchan);
upDur = ParamQuery([Prefix 'upDur'], 'up:', '15000 15000', 'ms', ...
    'rreal', 'Duration of upward part.',Nchan);
holdDur = ParamQuery([Prefix 'holdDur'], 'hold:', '15000 15000', 'ms', ...
    'rreal', 'Duration of hold part.',Nchan);
downDur = ParamQuery([Prefix 'downDur'], 'down:', '15000 15000', 'ms', ...
    'rreal', 'Duration of downward part.',Nchan);

Fsweep = add(Fsweep, StartFreq);
Fsweep = add(Fsweep, EndFreq, alignedwith(StartFreq));
Fsweep = add(Fsweep, SweepMode, alignedwith(EndFreq));
Fsweep = add(Fsweep, upDur, alignedwith(SweepMode));
Fsweep = add(Fsweep, holdDur, alignedwith(upDur));
Fsweep = add(Fsweep, downDur, alignedwith(holdDur));






