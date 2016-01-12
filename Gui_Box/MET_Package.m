function [  ] = MET_Package()
%UNTITLED Summary of this function goes here
%  Wrapper function for MET project GUI
% Instruction manual steps one and two are performed by the function
% Step_One_Figure. See set up code for parameter definitions. 
% Step_Three_Figure follows step three from the manual, setting z-threshold
% parameters. Note: rows_per_day is set automatically. 
global guiStruct;
persistent settings
guiStruct = struct();
%Run figure to get parameters for caller
F = Step_One_Figure();
waitfor(F);
directory = [guiStruct.directory,'\'];
prefix = guiStruct.prefix;
datestart = guiStruct.datestart;
dateend = guiStruct.dateend;
suffix = guiStruct.suffix;
ukoln_toggle = guiStruct.ukoln_toggle
records_per_file = guiStruct.records_per_file;
if ukoln_toggle == 0
        MRR = caller_MRR_simp2matrix(directory, prefix, datestart,dateend, suffix, records_per_file);  
elseif ukoln_toggle == 1
        MRR = caller_MRR_read_ukoln_nc(directory, prefix, datestart,dateend, suffix, records_per_file);  
end
%*****************end step one/two*************

dummer='dummer';

%  call next fig to set up for MRR_Storm_Detection
F = Step_Three_Figure();
waitfor(F);
settings = struct();
settings.Z_threshhold = guiStruct.Z_threshhold;
settings.Z_threshhold_2 = guiStruct.Z_threshhold_2;
settings.rows_per_day = guiStruct.records_per_file;
[MRR_filtered dates] = MRR_Storm_Detection(MRR, settings);

%************end step three**************

% get parameters for call to  gen_metar2struct.
F = Step_Four_Figure();
waitfor(F);
metarfilepath = guiStruct.metarfilepath;
savefilepath = guiStruct.savefilepath;
metartype = guiStruct.metartype;
%minuteinterval = guiStruct.minuteinterval;
gen_metar2struct(metarfilepath, savefilepath); 
%*****************end step four************

%get parameters for  MRR_Add_Storms and calculate_avg, Steps Five and Six
F = Step_Five_Figure();
waitfor(F);
settings.frontpage_orig  = guiStruct.frontpg_filename;
settings.metarfile_mat = guiStruct.matFilePath;
settings.empty_stormpage = guiStruct.template_filename;
[fileName,filePath , ~] = uiputfile('.mat', 'Save As');
settings.frontpage_saveas = fileName;
MRR_Add_Storms(MRR_filtered, dates, settings);
calculate_avgs(settings.frontpage_savas,0,length(dates),0);
%***************end steps five/six*************

%So, we actually have all the data for this step, we can just run with it. 
htmlfile = guiStruct.frontpg_filename;
homelocation = guiStruct.home_filepath;
stormsummarypg = guiStruct.fronpg_filePath;
add_next_prev(htmlfile,homelocation , stormsummarypg, '');
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


