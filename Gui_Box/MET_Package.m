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
minuteinterval = guiStruct.minuteinterval;
gen_metar2struct(metarfilepath, savefilepath, 0,minuteinterval); 
%*****************end step four************

%get parameters for  MRR_Add_Storms and calculate_avg, Steps Five and Six
settings.frontpage_orig  = guiStruct.frontpg_filename;
settings.metarfile_mat = guiStruct.matFilePath;
settings.empty_stormpage = guiStruct.template_filename;
[fileName,filePath , ~] = uigetfile('.mat', 'Save As');
settings.frontpage_saveas = fileName;
MRR_Add_Storms(MRR_filtered, dates, settings);
calculate_avgs(settings.frontpage_savas,0,length(dates),0);


