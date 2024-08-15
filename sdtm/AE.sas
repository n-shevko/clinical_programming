/*
purpose: create Adverse Events data set
input: raw.ae sdtm.dm
output: ae.xpt
protocol: NIDA-CPU-0002A
sas version: 9.04
*/

%include "~/nida-cpu-0005/sdtm/includes.sas";

%make_aux_utils(metadatafile=&project_folder/sdtm/metadata.xlsx, dataset=AE);

data ae;
  set empty_ae raw.ae;
  studyid = studyid;
  domain = 'AE';
  usubjid = left(subjid);
  aeterm = aename;
  
  aelltcd = aellt;
  aeptcd = aept;
  aehltcd = aehlt;
  aehlgtcd = aehlgt;
  aesoccd = aesoc;
  
  aesev = put(aesevere, aesev.);
  aeser = put(aeserios, aeser.);
  
  
  aeacn = put(aeaction, aeacn.);
  if aeaction = 6 and aeother = 1  /* 'Delayed Dose' can't be coded in terms of the CDISC terminology so I moved this case to 'Other Action Taken'  */
    then aeacnoth = 'Delayed Dose';
  else aeacnoth = put(aeother, aeacnoth.);
  
  aerel = put(aerelate, aerel.);
  aeout = put(aeoutcom, aeout.);
  
  if aeout = 'FATAL' then aesdth = 'Y';
  else aesdth = 'N';
  
  if AEANYAE = 1;
  drop SUBJID SITEID;
run; 

proc sort data=ae;
  by usubjid;
run;

data ae;
  merge ae(in=in_ae) sdtm.dm(keep=usubjid rfstdtc);
  by usubjid;
  %zero_day_fix(aestdy, aestart);
  %zero_day_fix(aeendy, aestop);
  
  %study_day2date(aestdtc, aestdy, 0);
  %study_day2date(aeendtc, aeendy, 0);
  
  if in_ae;
  keep &ae_keepstring;
run;


data ae;
  retain cnt;
  set ae;
  by usubjid;
  if first.usubjid then cnt = 1;
  aeseq = cnt;
  cnt + 1;
  drop cnt;
run;  


%save_ds(ae, &project_folder/sdtm/data);  
 
proc print data=ae;
run;
