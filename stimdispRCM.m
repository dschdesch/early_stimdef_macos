function [strSPL, strSpec1, strSpec2] = stimdispRCM(Stim)
% stimdispRCM - strings describing specific parameters of RCM stimulus
%    [strSPL, strSpec1, strSpec2] = stimdispRCM(Stim) returns strings
%    strSPL, strSpec1, strSpec2 describing the stimulus parameters of the
%    RCM stimulus. Stim is the struct containing all the stimulus
%    parameters (see stimdefRCM). These strings are used by
%    dataset/stimlist and determine the listing in databrowse.
%
%    See also stimGUI, dataset/stimlist, dataset/stimlist_strfun, databrowse.

STR = stimlist_strfun(dataset); % helpers for num->str conversion

strSPL = [STR.shstring(Stim.Fcar) ' ' Stim.FcarUnit]; % when SPL is the first varied parameter, i.e. Stim.Presentation.X, Fcar is shown here
strSpec1 = STR.modstr(Stim);
strSpec2 = [];