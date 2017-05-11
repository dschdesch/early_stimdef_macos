function  P2 = MovNoiseBurstDur(P)
% MovNoiseBurstDur - extract BurstDur from moving noise parameters
%   P=EvalMovNoiseDurPanel(P) adds a P.BurstDur array to P for MOVN stimulus.
%   BurstDur is a [Ncond x 1] array calculated from interaural speeds:
%   Dur = (1-BinauralSpeed)*Dur + endITD - startITD
%   BurstDur = Dur + max(0,startITD) - min(0,endITD)
%
%   See EvalMoveNoiseDurPanel

P2 = []; % a premature return will result in []
if isempty(P), return; end

if ~isfield(P,'ITDSpeed'), return; end
if ~isfield(P,'ITD1'), return; end
if ~isfield(P,'ITD2'), return; end

% Compute begin and end delays ITD1 and ITD2 while taking Experiment info into account 
Delay = ITD2delay([P.ITD1; P.ITD2], P.Experiment);
ITD1 = Delay(1,2) - Delay(1,1);
ITD2 = Delay(2,2) - Delay(2,1);

% Reorder stimulus ITDs if necessary
% From now on, right with respect to left
if isequal(P.Experiment.RecordingSide,'Right')
    ITD = [ITD2, ITD1];
    ITD1 = ITD(1);
    ITD1 = ITD(2);
end
% If, due to Experiment info, ITD1 > ITD2, reorder ITDS
% and change ITDOrder
if (ITD1 > ITD2)
    P.ITD1 = ITD2;
    P.ITD2 = ITD1;
    if isequal(P.ITDOrder,'Backward')
        P.ITDOrder = 'Forward';
    else
        P.ITDOrder = 'Backward';
    end
else
    P.ITD1 = ITD1;
    P.ITD2 = ITD2;
end

% Calculate duration of left waveform
Dur = (P.ITD2 - P.ITD1)./P.ITDSpeed; % us per us/s gives BurstDur in s
P.Dur = 1000*Dur; % Dur Unit is actually ms 
P.DurUnit = 'ms';
% Calculate BurstDuration
P.BurstDur = P.Dur + max(0,P.ITD1) - min(0,P.ITD2);

P2 = P;