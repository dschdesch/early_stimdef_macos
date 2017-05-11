function [strSPL, strSpec1, strSpec2] = stimdispFM(Stim)
% stimdispFM - strings describing specific paFMeters of FM stimulus
%    [strSPL, strSpec1, strSpec2] = stimdispFM(Stim) returns strings
%    strSPL, strSpec1, strSpec2 describing the stimulus paFMeters of the
%    FM stimulus. Stim is the struct containing all the stimulus
%    paFMeters (see stimdefFM). These strings are used by
%    dataset/stimlist and determine the listing in databrowse.
%
%    See also stimGUI, dataset/stimlist, dataset/stimlist_strfun, databrowse.

STR = stimlist_strfun(dataset); % helpers for num->str conversion

strSPL = [STR.shstring(Stim.SPL) ' ' Stim.SPLUnit];
strSpec1 = []; % no modulation possible
strSpec2 = [];