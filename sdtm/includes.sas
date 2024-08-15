%let project_folder = ~/nida-cpu-0005;

%include "&project_folder/macroses/make_aux_utils.sas";
%include "&project_folder/macroses/common.sas";
%include "&project_folder/sdtm/formats.sas";

libname raw "&project_folder/raw_data";
libname sdtm "&project_folder/sdtm/data";