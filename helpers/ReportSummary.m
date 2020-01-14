function ReportSummary(figh, P);
% ReportSummary - compute total play time and report it to Summary panel 
%     T=ReportSummary(figh, Ncond, Nrep, ISI, totBaseline) computes total 
%     play time T (in seconds) from the number of conditions Ncond, the number of 
%     reps Nrep, the inter-stimulus-interval ISI (in ms) and the sum of
%     pre- and post-stimulus baselines, totBaseline. ReportSummary reports
%     T to the Summary messenger of the stimulus GUI having handle figh.
%
%     ReportSummary(figh, nan) resets the string of the Summary messenger 
%     to its TestLine value (see Messenger).
%
%     [T, Tstr]=ReportSummary(figh, ...) also returns the string
%     displayed in the Summary panel.
%
%   
%   See StimGUI, DurPanel, Summary, makestimFS, Messenger.

% remove duplicates because of repetitions
iCond = P.Presentation.iCond;
[dum I dum] = unique(iCond,'first');
iCond = iCond(sort(I));

x = P.Presentation.x;
Tstr=[x.ParName, ' in ' x.ParUnit, '\n'];
% add unit of x
if ~isempty(x.ParUnit)
    Tstr=[Tstr,' in ' x.ParUnit, '\n'];
end

if ~isempty(P.Presentation.Y)
    y = P.Presentation.Y;
    Tstr=[Tstr,'/ ', y.ParName];
    % add unit of y
    if ~isempty(y.ParUnit)
        Tstr=[Tstr,' in ' y.ParUnit, '\n'];
    end
end


Tstr = [Tstr,'-- L -------------------- R ------------------ \n'];

if ~isempty(P.Presentation.Y)
    Tstr=[Tstr,tablePrint(P.DAC,iCond,P.(x.FieldName),P.(y.FieldName))];
else
    Tstr=[Tstr,tablePrint(P.DAC,iCond,P.(x.FieldName))];
end

% report
M = GUImessenger(figh, 'Summary');
report(M,sprintf(Tstr));
end

function Tstr=tablePrint(DAC,iCond,xValues,yValues)
[k, l] = size(xValues);
xValues = sortValues(xValues,iCond);

if nargin==4
    yValues = sortValues(yValues,iCond);
end
Tstr = '';

% Very ugly way to align all numbers correctly
for i=1:k+2
    
    if nargin==4
        leftString = addPadding(num2str(xValues(i,1),5),6);
        rightString = addPadding(num2str(xValues(i,2),5),6);
        leftString = [leftString, '/ ', addPadding(num2str(yValues(i,1),5),6)];
        rightString = [rightString, '/ ', addPadding(num2str(yValues(i,2),5),6)];
    else
        leftString = addPadding(num2str(xValues(i,1),5),14);
        rightString = addPadding(num2str(xValues(i,2),5),13);
    end
    % Insert - for inactive channel
    switch DAC(1)
        case 'L'
            rightString = '-';
        case 'R'
            leftString = '            -                ';
    end

    if ~isempty(strfind(leftString,'NaN')) || ~isempty(strfind(rightString,'NaN'))
        leftString = '                    BASELINE';
        rightString = '';
    end
    % Append leftmost string
    Tstr = [Tstr,leftString];
    
    Tstr = [Tstr,'   '];
    
    % Append rightmost string
    Tstr = [Tstr,rightString,'\n'];
end
end

function Tstr=addPadding(Tstr,totalLength)
    % Add spaces for alignment
    for j=0:(totalLength-length(Tstr))
        Tstr=[Tstr,'  '];
    end
    % Add one extra space if leftmost string contains dot
    if ~isempty(strfind(Tstr,'.'))
        Tstr=[Tstr,' '];
    end
end

function values=sortValues(values,iCond)
[k, l] = size(values);
% Expand when only one channel
if l==1
    values(:,2) = values(:,1);
end

% Sort by iCond
values(k+1:k+2,:) = NaN;
values = values(iCond,:);
end