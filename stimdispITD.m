function [strSPL, strSpec1, strSpec2] = stimdispITD(Stim)
% stimdispITD - strings describing specific parameters of ITD stimulus
%    [strSPL, strSpec1, strSpec2] = stimdispITD(Stim) returns strings
%    strSPL, strSpec1, strSpec2 describing the stimulus parameters of the
%    ITD stimulus. Stim is the struct containing all the stimulus
%    parameters (see stimdefITD). These strings are used by
%    dataset/stimlist and determine the listing in databrowse.
%
%    See also stimGUI, dataset/stimlist, dataset/stimlist_strfun, databrowse.

STR = stimlist_strfun(dataset); % helpers for num->str conversion

strSPL = [STR.shstring(Stim.SPL) ' ' Stim.SPLUnit];
strSpec1 = STR.modstr(Stim);
strSpec2 = [STR.shstring(Stim.Fcar) ' ' Stim.FcarUnit]; % carrier frequency