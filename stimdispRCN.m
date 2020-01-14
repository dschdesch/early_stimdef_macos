function [strSPL, strSpec1, strSpec2] = stimdispRCN(Stim)
% stimdispRCN - strings describing specific parameters of RCN stimulus
%    [strSPL, strSpec1, strSpec2] = stimdispRCN(Stim) returns strings
%    strSPL, strSpec1, strSpec2 describing the stimulus parameters of the
%    RCN stimulus. Stim is the struct containing all the stimulus
%    parameters (see stimdefRCN). These strings are used by
%    dataset/stimlist and determine the listing in databrowse.
%
%    See also stimGUI, dataset/stimlist, dataset/stimlist_strfun, databrowse.

STR = stimlist_strfun(dataset); % helpers for num->str conversion

strSPL = [];
strSpec1 = [];
strSpec2 = [STR.shstring([Stim.LowFreq Stim.HighFreq], '..') ' Hz']; % noise cutoffs
