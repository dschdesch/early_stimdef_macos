function [okay, P]=EvalMovNoiseDurPanel(figh, P, Ncond, Prefix, mISI)
% EvalMovNoiseDurPanel - evaluate Dur parameters from stimulus GUI
%   [Okay, P]=EvalMovNoiseDurPanel(figh, P, Ncond, Prefix, mISI) evaluates the Duration 
%   parameters obtained from the paramqueries created by MovNoiseDurPanel. The 
%   first output argument Okay is true unles timing parameters 
%   are out of range or mutually inconsistent. The second output is
%   identical to the input struct P, except three new fields are added:
%   FineITD, GateITD, ModITD, which realize the expansion of the ITD and
%   ITDtype fields in P (see ITDparse). Input arguments are 
%
%      figh: handle to GUI, or stimulus context for non-interactive calls.
%         P: struct returned by GUIval(figh) containing GUI parameters 
%     Ncond: number of conditions (needed to report the total play time)
%    Prefix: prefix of Dur query names (see DurPanel). Defaults to ''.
%      mISI: mean inter-stimulus-interval in ms to be used in the
%            estimation and reporting of total play time. mISI defaults to
%            P.ISI, but may deviate from it due to warping (e.g. makeStimMask).
%   
%   If the GUI has a PlayTime messenger panel, EvalMovNoiseDurPanel also reports
%   the total play time to this messenger.
%   
%   See StimGUI, DurPanel, ReportPlayTime, makestimFS, ITDparse.

[Prefix, mISI] = arginDefaults('Prefix/mISI', '', P.ISI);
okay = 0; % pessimistic default

if isa(figh, 'experiment'), % non-interactive call - no GUI
    EXP = figh; 
    Interactive=false;
else,
    EXP = getGUIdata(figh,'Experiment');
    Interactive=true;
    ReportPlayTime(figh, nan); % reset PlayTime report
end
% get DurPanel params and ISI from P
P = dePrefix(P,Prefix);

% Check validity & consistency of params, report any error & highlight edits
anywrong = 1;
% parse ITD spec, if present

% ITD on waveform handled in another way
[P.ITD P.FineITD P.GateITD P.ModITD] = deal(0);

% Check validity: convention is ITD1 < ITD2
if (P.ITD1 >= P.ITD2),
    GUImessage(figh,'ITD1 greater than or equal to ITD2.', ...
        'error', {[Prefix 'ITD1'] [Prefix 'ITD2']});
end

% Extract burst durations from ITD while taking experiment info (left/right
% convention) into account
P = MovNoiseBurstDur(P);
if isempty(P.BurstDur), return; end

% combine onset delay + burstdur
Onset_Burst_dur = bsxfun(@plus, P.OnsetDelay, P.BurstDur);

if any(Onset_Burst_dur>P.ISI),
    GUImessage(figh,['Maximum OnsetDelay+Burst duration (' num2str(max(Onset_Burst_dur)) ' ms) exceeds ISI.'], ...
        'error', {[Prefix 'OnsetDelay'] [Prefix 'BurstDur'] 'ISI'});
elseif any(P.ISI<0.25),
    GUImessage(figh,'ISI must be at least 0.25 ms.', ...
        'error', 'ISI');
elseif any(Onset_Burst_dur>P.ISI),
    GUImessage(figh,'Sum of OnsetDelay, BurstDur exceeds ISI.', ...
        'error', {[Prefix 'OnsetDelay'] [Prefix 'BurstDur'] 'ISI'});
elseif any(P.Dur-(1e-3)*(P.ITD2-P.ITD1)<P.RiseDur+P.FallDur), % is undersampled waveform too small for Rise and Fall
    GUImessage(figh,'Sum of Rise & Fall durations exceeds BurstDur.', ...
        'error', {[Prefix 'BurstDur'] [Prefix 'RiseDur'] [Prefix 'FallDur']});
elseif prod(Ncond)>EXP.maxNcond,
    Mess = {['Too many (>' num2str(EXP.maxNcond) ') stimulus conditions.'],...
        'Increase stepsize(s) or decrease range(s)'};
    GUImessage(figh, Mess, 'error');
else, anywrong=0; % past all tests
end
if anywrong, return; end

if Interactive, % report playtime
    totBaseline = sum(SameSize(P.Baseline,[1 1])); % sum of pre- & post-stim baselines
    Ttotal=ReportPlayTime(figh, Ncond, P.Nrep, mISI, totBaseline);
end

okay=1;