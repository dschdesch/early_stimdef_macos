function [strSPL, strSpec1, strSpec2] = stimdispNITD(Stim)
% stimdispNITD - strings describing specific parameters of NITD stimulus
%    [strSPL, strSpec1, strSpec2] = stimdispNITD(Stim) returns strings
%    strSPL, strSpec1, strSpec2 describing the stimulus parameters of the
%    NITD stimulus. Stim is the struct containing all the stimulus
%    parameters (see stimdefNITD). These strings are used by
%    dataset/stimlist and determine the listing in databrowse.
%
%    See also stimGUI, dataset/stimlist, dataset/stimlist_strfun, databrowse.

STR = stimlist_strfun(dataset); % helpers for num->str conversion

strSPL = [STR.shstring(Stim.SPL) ' ' Stim.SPLUnit]; % noise SPL
strSpec1 = []; % no modulation possible 
strSpec2 = [STR.shstring([Stim.LowFreq Stim.HighFreq], '..') ' Hz']; % noise cutoffs