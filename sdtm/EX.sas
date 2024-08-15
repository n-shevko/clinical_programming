/*
purpose: create Exposure data set
input: raw.invagt sdtm.dm
output: ex.xpt
protocol: NIDA-CPU-0002A
sas version: 9.04
*/

%include "~/nida-cpu-0005/sdtm/includes.sas";

proc sort data=raw.invagt out=invagt;
  by subjid DAYDATE;
run;

/* spliting the recods by dosing periods */
data exposure_by_periods;
  retain first_date previous_dose previous_date;
  set invagt(where=(NUMTAB > 0));
  by subjid;
  if first.subjid then do;
     first_date = DAYDATE;
     previous_dose = NUMTAB;
  end;
  
  if previous_dose ^= NUMTAB  then do;
    dose = previous_dose;
    last_date = previous_date;
    output;
    first_date = DAYDATE;
  end; else if last.subjid then do;
    dose = NUMTAB;
    last_date = DAYDATE;
    output;
  end; 
  previous_dose = NUMTAB;
  previous_date = DAYDATE;
  keep subjid studyid siteid dose first_date last_date;
run; 

proc print data=exposure_by_periods;
run; 

%make_aux_utils(metadatafile=&project_folder/sdtm/metadata.xlsx, dataset=EX);  

data ex;
  set empty_ex exposure_by_periods;
  domain = 'EX';
  usubjid = put(subjid, best.);
  select (dose);
    when (1) exdose = 50; /* this value is assumed. I can't clarify this. */
    when (2) exdose = 75;
  end;  
  exdosu = 'mg';
  exdosfrm = 'CAPSULE, COATED';
  exdosfrq = 'Q24H';
  exroute = 'ORAL';
  exfast = 'Y';
  epoch = 'TREATMENT';

  %zero_day_fix(exstdy, first_date);
  %zero_day_fix(exendy, last_date);
run;

data dm;
  set sdtm.dm(keep=subjid rfstdtc actarmcd rename=subjid=subjid_char);
  subjid=input(subjid_char, 6.);
  drop subjid_char;
run;  

proc sort data=dm;
  by subjid;
run;

data ex;
  merge ex(in=in_ex) dm;
  by subjid;
  
  %study_day2date(exstdtc, exstdy, 0);
  %study_day2date(exendtc, exendy, 0);
  
  extrt = actarmcd;
  if extrt = 'PLACEBO' then exdose = 0;
  if in_ex;
run;

data ex;
  retain exseq_cnt;
  set ex;
  by subjid;
  if first.subjid then exseq_cnt = 0;
  exseq_cnt + 1;
  exseq = exseq_cnt;
  keep &ex_keepstring;
run;

proc print data=ex;
run;

%save_ds(ex, &project_folder/sdtm/data);