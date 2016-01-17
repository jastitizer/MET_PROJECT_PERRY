function [  ] = MET_Package()
%UNTITLED Summary of this function goes here
%  Wrapper function for MET project GUI
% Instruction manual steps one and two are performed by the function
% Step_One_Figure. See set up code for parameter definitions. 
% Step_Three_Figure follows step three from the manual, setting z-threshold
% parameters. Note: rows_per_day is set automatically. 
guiStruct = struct();
settings = struct();
guiState = 0
guiStruct.guiFlow = 1;
while guiState < 4
    [guiStruct,settings] = openFig(guiStruct, guiState,settings);
    guiState = guiState + guiStruct.guiFlow;
end
% - htmlfile: File name of your frontpage html file.
% - homelocation: Relative path you want to set for the “Home” button in each storm.  
% I always make the “Home” button go back to the index of the directory the front
% page html file is in, so my relative path is “../” because each stormpage html file is
% in the storms folder.  You are free to make your own Home page though. 
% - stormsummarypg: The relative path to your frontpage html file from the storms
% folder. 
% - is_cat: For your purposes, always set this input to an empty string.  This input is
% used by another function to determine what type of html file is being read. 
% here are no outputs for this function.  Similar to the last step, this function will overwrite
% our frontpage html file.  Again, it is a good idea to make a backup of your frontpage
% ml file somewhere else. 
% xample:
        %CALL ERROR CHECK FXN HERE%
      %  [flag,errorList] = parse_fxn(guiStruct,settings);
        %if flag == 1
            %do some sort of reporting here
            %Print list of bad parameters and call figure five
            display('Unable to parse the following parameters');
            errorList
  %      else
            if ukoln_toggle == 0
                    MRR = caller_MRR_simp2matrix(directory, prefix, datestart,dateend, suffix, records_per_file);  
            elseif ukoln_toggle == 1
                    MRR = caller_MRR_read_ukoln_nc(directory, prefix, datestart,dateend, suffix, records_per_file);  
            end

            [MRR_filtered dates] = MRR_Storm_Detection(MRR, settings);

            gen_metar2struct(metarfilepath, savefilepath); 

            MRR_Add_Storms(MRR_filtered, dates, settings);
            calculate_avgs(settings.frontpage_savas,0,length(dates),0);

            add_next_prev(htmlfile,homelocation , stormsummarypg, '');
    %    end