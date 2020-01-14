function [strSPL, strSpec1, strSpec2] = stimdispBBFM(Stim)
% stimdispBBFM - strings describing specific parameters of BBFM stimulus
%    [strSPL, strSpec1, strSpec2] = stimdispBBFM(Stim) returns strings
%    strSPL, strSpec1, strSpec2 describing the stimulus parameters of the
%    BBFM stimulus. Stim is the struct containing all the stimulus
%    parameters (see stimdefBBFM). These strings are used by
%    dataset/stimlist and determine the listing in databrowse.
%
%    See also stimGUI, dataset/stimlist, dataset/stimlist_strfun, databrowse.

STR = stimlist_strfun(dataset); % helpers for num->str conversion

strSPL = [STR.shstring(Stim.SPL) ' ' Stim.SPLUnit]; % SPL
strSpec1 = [STR.shstring(Stim.Fcar) ' ' Stim.FcarUnit]; % mod already handled; field is used for carrier frequency
strSpec2 = ['BF ' STR.shstring(Stim.BeatFreq) ' ' Stim.BeatFreqUnit]; 