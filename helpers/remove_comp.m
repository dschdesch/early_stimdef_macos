
function [newfreqs,idx_kept,iBF]=remove_comp(BF,notchW,freqs)

% lowf=BF-notchW/2;
% highf=BF+notchW/2;

iBF = find(freqs==BF);
lowf= floor(BF/(2^(notchW/2)));
highf= ceil(BF*(2^(notchW/2)));

newfreqs = [];
idx_kept=[];
for ifreq=1:length(freqs)
    if (freqs(ifreq)<lowf)|(freqs(ifreq)>highf)|ifreq==iBF
    newfreqs=[newfreqs,freqs(ifreq)];
    idx_kept = [idx_kept,ifreq];
    end
end