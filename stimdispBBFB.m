function [strSPL, strSpec1, strSpec2] = stimdispBBFB(Stim)
% stimdispBBFB - strings describing specific parameters of BBFB stimulus
%    [strSPL, strSpec1, strSpec2] = stimdispBBFB(Stim) returns strings
%    strSPL, strSpec1, strSpec2 describing the stimulus parameters of the
%    BBFB stimulus. Stim is the struct containing all the stimulus
%    parameters (see stimdefBBFB). These strings are used by
%    dataset/stimlist and determine the listing in databrowse.
%
%    See also stimGUI, dataset/stimlist, dataset/stimlist_strfun, databrowse.

STR = stimlist_strfun(dataset); % helpers for num->str conversion

strSPL = [STR.shstring(Stim.SPL) ' ' Stim.SPLUnit]; % SPL
strSpec1 = STR.modstr(Stim);
strSpec2 = [];