function [strSPL, strSpec1, strSpec2] = stimdispMTF(Stim)
% stimdispMTF - strings describing specific paMTFeters of MTF stimulus
%    [strSPL, strSpec1, strSpec2] = stimdispMTF(Stim) returns strings
%    strSPL, strSpec1, strSpec2 describing the stimulus paMTFeters of the
%    MTF stimulus. Stim is the struct containing all the stimulus
%    paMTFeters (see stimdefMTF). These strings are used by
%    dataset/stimlist and determine the listing in databrowse.
%
%    See also stimGUI, dataset/stimlist, dataset/stimlist_strfun, databrowse.

STR = stimlist_strfun(dataset); % helpers for num->str conversion

strSPL = [STR.shstring(Stim.SPL) ' ' Stim.SPLUnit];
strSpec1 = []; % modulation has already been handled
strSpec2 = [STR.shstring(Stim.Fcar) ' ' Stim.FcarUnit]; % carrier frequency