function [  ] = MET_Package()
%UNTITLED Summary of this function goes here
%  Wrapper function for MET project GUI
% Instruction manual steps one and two are performed by the function
% Step_One_Figure. See set up code for parameter definitions. 
% Step_Three_Figure follows step three from the manual, setting z-threshold
% parameters. Note: rows_per_day is set automatically. 
global guiStruct;
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
end
%*****************end step four************

%get parameters for  MRR_Add_Storms
- frontpage_orig: File name of the frontpage html file to which you are addistorms (e.g. ‘frontpage.html’). 
- frontpage_saveas: File name of the frontpage html file after the new storbeen added.  This should be not the same as frontpage_orig, so you can sthe old html file the way it was as a backup (e.g. ‘myfrontpage.html’). 
- metarfile_mat: File name of the Matlab struct of surface observations.  Incthe .mat extension. 
- empty_stormpage: File name of the template stormpage.html file.
 MRR_Add_Storms(MRR_filtered, dates, settings) 