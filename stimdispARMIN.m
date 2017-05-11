function [strSPL, strSpec1, strSpec2] = stimdispARMIN(Stim)
% stimdispARMIN - strings describing specific parameters of ARMIN stimulus
%    [strSPL, strSpec1, strSpec2] = stimdispARMIN(Stim) returns strings
%    strSPL, strSpec1, strSpec2 describing the stimulus parameters of the
%    ARMIN stimulus. Stim is the struct containing all the stimulus
%    parameters (see stimdefARMIN). These strings are used by
%    dataset/stimlist and determine the listing in databrowse.
%
%    See also stimGUI, dataset/stimlist, dataset/stimlist_strfun, databrowse.

STR = stimlist_strfun(dataset); % helpers for num->str conversion

if ~isfield(Stim,'SPLUnit')
    strSPL = [STR.shstring(Stim.SPL) ' ' 'dB']; % noise SPL
else
    strSPL = [STR.shstring(Stim.SPL) ' ' Stim.SPLUnit]; % noise SPL
end
strSpec1 = STR.modstr(Stim);
strSpec2 = [STR.shstring([Stim.LowFreq Stim.HighFreq], '..') ' Hz']; % noise cutoffs