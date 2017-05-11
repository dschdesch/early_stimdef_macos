function [strSPL, strSpec1, strSpec2] = stimdispMOVN(Stim)
% stimdispMOVN - strings describing specific parameters of MOVN stimulus
%    [strSPL, strSpec1, strSpec2] = stimdispMOVN(Stim) returns strings
%    strSPL, strSpec1, strSpec2 describing the stimulus parameters of the
%    MOVN stimulus. Stim is the struct containing all the stimulus
%    parameters (see stimdefMOVN). These strings are used by
%    dataset/stimlist and determine the listing in databrowse.
%
%    See also stimGUI, dataset/stimlist, dataset/stimlist_strfun, databrowse.

STR = stimlist_strfun(dataset); % helpers for num->str conversion

strSPL = [STR.shstring(Stim.SPL) ' ' Stim.SPLUnit]; % noise SPL
strSpec1 = [STR.shstring([Stim.ITD1 Stim.ITD2], '..') ' us'];
strSpec2 = [STR.shstring([Stim.LowFreq Stim.HighFreq], '..') ' Hz']; % noise cutoffs