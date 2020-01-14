%%% Convert data from the Early format to matlab .mat files
%%% This script only deals with spike times
%%% It saves the spike times and the stimulus parameters to a .mat file
function [] = convert_data_early2mat (animal_ID)
% animal_ID = 'H16568'; %name of the directory where the data is
pathtofile = 'C:\ExpData\Mark\'; %path to the folder where the data folders are located

list_dir = dir([pathtofile,animal_ID]); %list everything in the folder pathtofile/animal_ID
pattern = 'EarlyDS';  % the script is going to care only about the files with that pattern in their name

for idir=1:length(list_dir) %for every file in the directory
    if (length(strfind(list_dir(idir).name, pattern))~=0) %if the name contains the pattern
        name = list_dir(idir).name; %name of the file
        EarlyID = name(end-12:end-8); %take the index of the file in the experiment
        idx=str2num(EarlyID); %convert the index from string to number
        
        new_name = [animal_ID,'_',EarlyID]; %name of the converted file
        newname = [pathtofile,animal_ID,'\',new_name,'.mat']; %path and name of the converted file
        
        D = read(dataset,animal_ID,idx); %read the Early data
        stim_param =  D.stimparam; %retrieve the stimulus parameters
        
        %set the waveform to zero to save up space (comment three next line
        %if you don't want)
        a = struct(stim_param.Waveform); 
        [a.Samples]=deal(0);
        stim_param.Waveform=a;
        
        if (length(strfind(stim_param.StimType, 'THR'))~=0) & (~isobject(D.Data)) %for the tuning curve
            thr = D.Data.Thr; %thresholds
            freq = stim_param.Presentation.X.PlotVal; %frequencies
            save(newname,'thr','freq','stim_param') %just save that
            newname
        else %for the other stimulus
            spikes = D.spiketimes; %spike timing
            save(newname,'stim_param','spikes') %save both stimulus parameters and spike timing
            newname
        end
        
    end
end
end
