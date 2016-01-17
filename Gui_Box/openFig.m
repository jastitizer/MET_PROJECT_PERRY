function [ guiStruct,settings ] = openFig( guiStruct, guiState, settings )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

switch guiState
    case 0
        [parameters] = Step_One_Figure();
        dummer = 0;
        guiStruct.directory = [parameters.directory,'\'];
        guiStruct.prefix = parameters.prefix;
        guiStruct.datestart = parameters.datestart;
        guiStruct.dateend = parameters.dateend;
        guiStruct.suffix = parameters.suffix;
        guiStruct.ukoln_toggle = parameters.ukoln_toggle
        guiStruct.records_per_file = parameters.records_per_file;
        guiStruct.guiFlow = parameters.guiFlow;
%*****************end step one/two*************

dummer='dummer';
    case 1
%  call next fig to set up for MRR_Storm_Detection
        parameters = Step_Three_Figure();
        settings.Z_threshhold = parameters.Z_threshhold;
        settings.Z_threshhold_2 = parameters.Z_threshhold_2;
        guiStruct.skip4 = parameters.skip4;
        guiStruct.guiFlow = parameters.guiFlow;
            %************end step three**************
    case 2
            % get parameters for call to  gen_metar2struct.
        parameters = Step_Four_Figure();
        guiStruct.metarfilepath = parameters.metarfilepath;
        guiStruct.savefilepath = parameters.savefilepath;
        guiStruct.metartype = parameters.metartype;
        guiStruct.guiFlow = parameters.guiFlow;
        %minuteinterval = guiStruct.minuteinterval;

        %*****************end step four************

    case 3
        %get parameters for  MRR_Add_Storms and calculate_avg, Steps Five and Six
        parameters = Step_Five_Figure();
        settings.frontpage_orig  = parameters.frontpg_filename;
        settings.metarfile_mat = parameters.matFilePath;
        settings.empty_stormpage = parameters.template_filename;
        [fileName,filePath , ~] = uiputfile('.mat', 'Save As');
        settings.frontpage_saveas = fileName;
        guiStruct.guiFlow = parameters.guiFlow;
        %***************end steps five/six*************

        %So, we actually have all the data for step 7, we can just run with it. 
        
        htmlfile = parameters.frontpg_filename;
        homelocation = settings.home_filepath;
        stormsummarypg = parameters.fronpg_filePath;

end

