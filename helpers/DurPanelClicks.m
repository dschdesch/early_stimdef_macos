function Dur=DurPanelClicks(T, EXP, Prefix, Flag);
% DurPanelClicks - generic durations and timing panel for stimulus GUIs.
%   D=DurPanelClicks(Title, EXP) returns a GUIpanel D for specification of
%   stimulus parameters concerning timing and durations. Title is the title
%   of the GUIpanel. Title='-' means the default title 'duration & timing'.
%   EXP is the experiment definition, from which the number of DAC channels 
%   used (1 or 2) is determined. The paramQuery objects contained in D are 
%        BurstDur: duration of the stimulus in ms including ramps.
%           Delay: delay [ms] of stimulus onset, common to both DACs
%         RiseDur:  rise time in ms.
%         FallDur:  rise time in ms.
%             ITD: interaural time delay (ipsi vs contra) in ms
%         ITDtype: waveform|gating|ongoing determines how ITD is realized
%                  waveform = whole waveform delay;
%                  gating = delayed gating imposed on nondelayed waveform;
%                  ongoing = nondelayed gating imposed on delayed waveform.
%           Phase: (optional) starting phase.
%                    
%   BurstDur, RiseDur, and Falldur may be [left,right] pairs provided the
%   stimulus context allows dual-channel stimulation.
%
%   DurPanelClicks is a helper function for stimulus definitions like stimdefFS.
% 
%   M=DurPanelClicks(Title, ChanSpec, Prefix) prepends the string Prefix
%   to the paramQuery names, e.g. ITD -> NoiseITD, etc.
%
%   M=DurPanelClicks(Title, ChanSpec, Prefix, 'nophase') discards the phase
%   query.
%
%   M=DurPanelClicks(Title, ChanSpec, Prefix, 'basicsonly') only provides the
%   burstdur, risedur and falldur queries.
%
%   Use EvalDurPanel to read the values from the queries and to perform 
%   standard checks on their consistency with other parameters.
%
%   See StimGUI, GUIpanel, EvalDurPanel, stimdefFS.

if isequal('-', T), T= 'durations & timing'; end
if nargin<3, Prefix=''; end
if nargin<4, Flag=''; end

ITDstring = ['Positive values correspond to ' upper(strrep(EXP.ITDconvention, 'Lead', ' Lead')) '.'];

% # DAC channels fixes the allowed multiplicity of user-specied numbers
if isequal('Both', EXP.AudioChannelsUsed), 
    Nchan = 2;
    PairStr = ' Pairs of numbers are interpreted as [left right].';
else, % single Audio channel
    Nchan = 1;
    PairStr = ''; 
end


BurstDur = ParamQuery([Prefix 'BurstDur'], 'burst:', '15000 15000', 'ms', ...
    'rreal/positive', 'Duration of burst including ramps.',Nchan);
OnsetDelay = ParamQuery([Prefix 'OnsetDelay'], 'delay:', '1500', 'ms', ...
    'rreal/nonnegative', 'Delay of stimulus onset (common to both DA channels).',1);
ITD = ParamQuery([Prefix 'ITD'], 'ITD:', '-123.44', 'ms', ...
    'rreal', ['interaural delay. ' ITDstring],1);

Dur = GUIpanel('Dur', T);
Dur = add(Dur, BurstDur,'below',[0 0]);
Dur = add(Dur, OnsetDelay,below(BurstDur),[0 5]);
Dur = add(Dur, ITD, below(OnsetDelay),[0 5]);









