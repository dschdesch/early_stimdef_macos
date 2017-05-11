function [strSPL, strSpec1, strSpec2] = stimdispBBFC(Stim)
% stimdispBBFC - strings describing specific parameters of BBFC stimulus
%    [strSPL, strSpec1, strSpec2] = stimdispBBFC(Stim) returns strings
%    strSPL, strSpec1, strSpec2 describing the stimulus parameters of the
%    BBFC stimulus. Stim is the struct containing all the stimulus
%    parameters (see stimdefBBFC). These strings are used by
%    dataset/stimlist and determine the listing in databrowse.
%
%    See also stimGUI, dataset/stimlist, dataset/stimlist_strfun, databrowse.

STR = stimlist_strfun(dataset); % helpers for num->str conversion

strSPL = [STR.shstring(Stim.SPL) ' ' Stim.SPLUnit]; % SPL
strSpec1 = STR.modstr(Stim);
strSpec2 = ['BF ' STR.shstring(Stim.BeatFreq) ' ' Stim.BeatFreqUnit]; 