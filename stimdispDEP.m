function [strSPL, strSpec1, strSpec2] = stimdispDEP(Stim)
% stimdispDEP - strings describing specific parameters of DEP stimulus
%    [strSPL, strSpec1, strSpec2] = stimdispDEP(Stim) returns strings
%    strSPL, strSpec1, strSpec2 describing the stimulus parameters of the
%    DEP stimulus. Stim is the struct containing all the stimulus
%    parameters (see stimdefDEP). These strings are used by
%    dataset/stimlist and determine the listing in databrowse.
%
%    See also stimGUI, dataset/stimlist, dataset/stimlist_strfun, databrowse.

STR = stimlist_strfun(dataset); % helpers for num->str conversion

strSPL = [STR.shstring(Stim.SPL) ' ' Stim.SPLUnit];
strSpec1 = []; % mod already handled  
strSpec2 = [STR.shstring(Stim.Fcar) ' ' Stim.FcarUnit];