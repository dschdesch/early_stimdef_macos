function Dur=MovNoiseDurPanel(T, EXP, Prefix, Flag)
% MovNoiseDurPanel - durations and timing panel for moving noise stimulus GUI.
%   D=MovNoiseDurPanel(Title, EXP) returns a GUIpanel D for specification of
%   stimulus parameters concerning timing and durations. Title is the title
%   of the GUIpanel. Title='-' means the default title 'duration & timing'.
%   EXP is the experiment definition, from which the number of DAC channels 
%   used (1 or 2) is determined. The paramQuery objects contained in D are 
%           Delay: delay [ms] of stimulus onset, common to both DACs
%         RiseDur:  rise time in ms.
%         FallDur:  fall time in ms.
%             ITD: interaural time delay (ipsi vs contra) in ms
%           Phase: (optional) starting phase.
%   
%   Notice that no duration (BurstDur) option is included, since it is
%   derived from the ITDs and binaural speed.
%
%   BurstDur, RiseDur, and Falldur can be [left,right] pairs provided the
%   stimulus context allows different dual-channel stimulation.
% 
%   M=DurPanel(Title, ChanSpec, Prefix) prepends the string Prefix
%   to the paramQuery names, e.g. ITD -> NoiseITD, etc.. 
%
%   Use EvaMovNoiselDurPanel to read the values from the queries and to perform 
%   standard checks on their consistency with other parameters.
%
%   See StimGUI, GUIpanel, EvalMovNoiseDurPanel, stimdefMOVN.

if isequal('-', T), T= 'Timing parameters'; end
if nargin<3, Prefix=''; end
if nargin<4, Flag=''; end

ITDstring = ['Positive values correspond to ' upper(strrep(EXP.ITDconvention, 'Lead', ' Lead')) '.'];

% # DAC channels fixes the allowed multiplicity of user-specied numbers
if isequal('Both', EXP.AudioChannelsUsed) && ~isequal('basicsonly_mono',Flag), 
    Nchan = 2;
    PairStr = ' Pairs of numbers are interpreted as [left right].';
else % single Audio channel
    Nchan = 1;
    PairStr = ''; 
end
if isequal('basicsonly_mono',Flag), % always mono, indep of EXP: use smaller edits
    Rampstr = '5.0';
else % use wider edits
    Rampstr = '5.0 6.0';
end

OnsetDelay = ParamQuery([Prefix 'OnsetDelay'], 'delay:', '1500', 'ms', ...
    'rreal/nonnegative', 'Delay of stimulus onset (common to both DA channels).',1);
ITD1 = ParamQuery([Prefix 'ITD1'], 'ITD1:', '-800.00', 'us', ...
    'rreal',['Interaural begin delay. ' ITDstring],1);
ITD2 = ParamQuery([Prefix 'ITD2'], 'ITD2:', '800.00', 'us', ...
    'rreal',['Interaural end delay. ' ITDstring],1);
RiseDur = ParamQuery([Prefix 'RiseDur'], 'rise:', Rampstr, 'ms', ...
    'rreal/nonnegative', ['Duration of onset ramps.' PairStr],Nchan);
FallDur = ParamQuery([Prefix 'FallDur'], 'fall:', Rampstr, 'ms', ...
    'rreal/nonnegative', ['Duration of offset ramps.' PairStr],Nchan);
ITDOrder = ParamQuery('ITDOrder', 'Order:', '', {'Forward' 'Backward'}, ...
    '','Ordering of begin and end stimulus ITDs. Forward means ITD1 -> ITD2, backward means ITD2 -> ITD1.',1);
ITDtype = ParamQuery('ITDtype', 'impose on', '', {'waveform'}, '', ...
    ['Implementation of ITD. Click to toggle between options.' char(10) ...
    '    waveform = whole waveform delay']);

Dur = GUIpanel('Dur', T);
Dur = add(Dur, ITD1, 'below',[0 0]);
Dur = add(Dur, ITD2, nextto(ITD1));
Dur = add(Dur,ITDOrder, below(ITD1), [0 0]);
Dur = add(Dur, ITDtype, below(ITDOrder),[0 0]);
Dur = add(Dur, OnsetDelay, below(ITDtype), [0 0]);
Dur = add(Dur, RiseDur, below(OnsetDelay), [0 0]);
Dur = add(Dur, FallDur, nextto(RiseDur));


