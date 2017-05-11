function [strSPL, strSpec1, strSpec2] = stimdispRAM(Stim)
% stimdispRAM - strings describing specific parameters of RAM stimulus
%    [strSPL, strSpec1, strSpec2] = stimdispRAM(Stim) returns strings
%    strSPL, strSpec1, strSpec2 describing the stimulus parameters of the
%    RAM stimulus. Stim is the struct containing all the stimulus
%    parameters (see stimdefRAM). These strings are used by
%    dataset/stimlist and determine the listing in databrowse.
%
%    See also stimGUI, dataset/stimlist, dataset/stimlist_strfun, databrowse.

STR = stimlist_strfun(dataset); % helpers for num->str conversion

strSPL = STR.xrange(Stim.Presentation.Y); % SPL stepping
strSpec1 = []; % modulation has already been handled
strSpec2 = [STR.shstring(Stim.Fcar) ' ' Stim.FcarUnit]; % carrier frequency