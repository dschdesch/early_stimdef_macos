function [newfreqs]= spectrum_masker(BF,notchW,freqs,type)

% lowf=BF-notchW/2;
% highf=BF+notchW/2;

iBF = find(freqs==BF);
lowf= ceil(BF/(2^(notchW/2)));
highf= floor(BF*(2^(notchW/2)));

newfreqs = [];
idx_kept=[];
for ifreq=1:length(freqs)
    if type == 'N'
        if (freqs(ifreq)<=lowf)|(freqs(ifreq)>=highf)
            newfreqs=[newfreqs,freqs(ifreq)];
        end
    elseif type=='B'
        if (freqs(ifreq)>=lowf)&(freqs(ifreq)<=highf)
            newfreqs=[newfreqs,freqs(ifreq)];
        end
    elseif type == 'T'
        
        if (freqs(ifreq)==lowf)|(freqs(ifreq)==highf)
            newfreqs=[newfreqs,freqs(ifreq)];
        end
        
    end
end