/*
purpose: create Trial Arms data set
input: TA.csv
output: ta.xpt
protocol: NIDA-CPU-0002A
sas version: 9.04
*/

%include "~/nida-cpu-0005/sdtm/includes.sas";

proc import datafile="&project_folder/sdtm/TA.csv"
            dbms=csv
            out=ta
            replace;
run;            

%make_aux_utils(metadatafile=&project_folder/sdtm/metadata.xlsx, dataset=TA);  

data ta;
  set empty_ta ta;
run;

proc print data=ta;
run;

%save_ds(ta, &project_folder/sdtm/data);  
  