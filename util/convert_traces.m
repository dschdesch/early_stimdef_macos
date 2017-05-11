%%% Convert data from the Early format to matlab .mat files
%%% This script only deals with analog traces
%%% It saves the spike times and the stimulus parameters to a .mat file


clear all
animal_ID = 'H16570'; %name of the directory where the data is
pathtofile = 'C:\ExpData\Exp\'; %path to the folder where the data folders are located

list_dir = dir([pathtofile,animal_ID]); %list everything in the folder pathtofile/animal_ID
pattern = 'EarlyDS';  % the script is going to care only about the files with that pattern in their name

for idir=1:length(list_dir) %for every file in the directory
    if (length(strfind(list_dir(idir).name, pattern))~=0) %if the name contains the pattern
        name = list_dir(idir).name; %name of the file
        EarlyID = name(end-12:end-8) %take the index of the file in the experiment
        idx=str2num(EarlyID); %convert the index from string to number
        
        new_name = [animal_ID,'_',EarlyID]; %name of the converted file
     
        newfolder = [pathtofile,animal_ID,'\',new_name]; %the traces are put in a folder specific for that stimulus presentation
        if ~exist(newfolder) %if the folder doesn't exist, create it
            mkdir(newfolder)
        end

        D = read(dataset,animal_ID,idx); %read the Early data
        stim_param =  D.stimparam; %retrieve the stimulus parameters
        Nconds =stim_param.Presentation.Ncond; %total number of stimulus conditions
        Nreps = stim_param.Nrep; %number of repetations per stimulus
   
        if isfield(D.data(1),'RX6_analog_1') %if analog recordings were made, this flag will be one
            %anadata(DS, Chan, iCond, iRep) returns the trace from the
            %channel Chan, condition with index iCond and repetation index
            %iRep
            trace = anadata(D, 1, 1, 1); 
            nsamples = length(trace); %number of samples of a trace
            for icond=1:Nconds
                traces=zeros(Nreps,nsamples); %for every condition, a matrix traces is creates with NrepXnsamples
                for irep=1:Nreps
                    try
                        tmp = anadata(D, 1, icond, irep);
                        if size(tmp,2)>1
                            'there is a problem' %it seems that a single trial has all repetitions in matrix
                        end
                    catch err %throws an error if interupeted in middle
                        'interrupted'
                        
                    end
                    traces(irep,:)=tmp(:,1);
                    
                end
                %a matrix is saved for each condition
                save([newfolder,'\',new_name,num2str(icond),'.mat'],'traces','stim_param')
            end
            
            
            
        end
        
    end
end
