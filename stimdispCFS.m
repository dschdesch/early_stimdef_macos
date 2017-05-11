function [strSPL, strSpec1, strSpec2] = stimdispCFS(Stim)
% stimdispCFS - strings describing specific parameters of CFS stimulus
%    [strSPL, strSpec1, strSpec2] = stimdispCFS(Stim) returns strings
%    strSPL, strSpec1, strSpec2 describing the stimulus parameters of the
%    CFS stimulus. Stim is the struct containing all the stimulus
%    parameters (see stimdefCFS). These strings are used by
%    dataset/stimlist and determine the listing in databrowse.
%
%    See also stimGUI, dataset/stimlist, dataset/stimlist_strfun, databrowse.

STR = stimlist_strfun(dataset); % helpers for num->str conversion

strSPL = [STR.shstring(Stim.SPL) ' ' Stim.SPLUnit];
strSpec1 = [];
pulseType = '';
if isfield(Stim, 'PulseTypeStr')
    pulseType = pulseType2String(Stim.PulseTypeStr);
end
strSpec2 = [STR.shstring(Stim.PulseWidth) ' ' Stim.PulseWidthUnit ' ' pulseType]; % click parameters

function s = pulseType2String(pulseType)
s = [pulseType(1) pulseType(end)];