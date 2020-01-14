function [strSPL, strSpec1, strSpec2] = stimdispNSAM(Stim)
% stimdispNSAM - strings describing specific paNSAMeters of NSAM stimulus
%    [strSPL, strSpec1, strSpec2] = stimdispNSAM(Stim) returns strings
%    strSPL, strSpec1, strSpec2 describing the stimulus paNSAMeters of the
%    NSAM stimulus. Stim is the struct containing all the stimulus
%    paNSAMeters (see stimdefNSAM). These strings are used by
%    dataset/stimlist and determine the listing in databrowse.
%
%    See also stimGUI, dataset/stimlist, dataset/stimlist_strfun, databrowse.

STR = stimlist_strfun(dataset); % helpers for num->str conversion

strSPL = [STR.shstring(Stim.SPL) ' ' Stim.SPLUnit];
strSpec1 = []; % modulation has already been handled
strSpec2 = [STR.shstring([Stim.LowFreq Stim.HighFreq], '..') ' Hz']; % noise cutoffs