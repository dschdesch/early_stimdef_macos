function [strSPL, strSpec1, strSpec2] = stimdispRC(Stim);
% stimdispRC - strings describing specific parameters of RC stimulus
%    [strSPL, strSpec1, strSpec2] = stimdispRC(Stim) returns strings
%    strSPL, strSpec1, strSpec2 describing the stimulus parameters of the
%    RC stimulus. Stim is the struct containing all the stimulus
%    parameters (see stimdefRC). These strings are used by
%    dataset/stimlist and determine the listing in databrowse.
%
%    See also stimGUI, dataset/stimlist, dataset/stimlist_strfun, databrowse.

STR = stimlist_strfun(dataset); % helpers for num->str conversion

strSPL = [STR.shstring(Stim.Fcar) ' ' Stim.FcarUnit]; % when SPL is the first varied parameter, i.e. Stim.Presentation.X, Fcar is shown here 
strSpec1 = [];
strSpec2 = STR.xrange(Stim.Presentation.Y); % phase stepping, i.e. Stim.Presentation.Y