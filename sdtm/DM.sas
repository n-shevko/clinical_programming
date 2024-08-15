/*
purpose: create Demographics data set
input: raw.demog raw.invagt raw.endtrial raw.rdmcode
output: dm.xpt
protocol: NIDA-CPU-0002A
sas version: 9.04
*/

%include "~/nida-cpu-0005/sdtm/includes.sas";

proc sort data=raw.invagt out=invagt;
  by subjid DAYDATE;
run;

/*
selecting first and last treatment days for each subject
*/
data treatment_days;
  retain first;
  set invagt;
  by subjid;
  if first.subjid then first = DAYDATE;
  if last.subjid then do;
    last = DAYDATE;
    output;
  end;  
  keep subjid first last;
run;

%make_aux_utils(metadatafile=&project_folder/sdtm/metadata.xlsx, dataset=DM);  
            

/* adding prefix to all variables in the raw dataset to avoid type collisions with sdtm variables */
%add_perfix(ds=raw.demog, prefix=src);

/* 
Remain only one record per subject.
The removed records describe material status, employment status, etc for subject. 
This information will be placed in SC domain.
*/
proc sort data=demog nodupkey;
  by src_subjid;
run;

proc sort data=raw.endtrial out=endtrial(rename=(subjid=src_subjid siteid=src_siteid));
  by subjid;
run;  

proc sort data=raw.rdmcode out=rdmcode(keep=subjid XTRTMT);
  by subjid;
run;

proc sort data=raw.enroll out=enroll(keep=subjid ENROLLDT);
  by subjid;
run;  

%let rfstdtc=2003-10-25; /*  I don't know the exact randomization date (rfstdtc) due to de-identification
    so I made the assumption that the all of the subjects were randomized on 2003-10-25 */

options mprint;

data demog;
  length armcd $ 200 arm $ 200;
  merge demog treatment_days(rename=(subjid=src_subjid)) endtrial rdmcode(rename=(subjid=src_subjid)) enroll(rename=(subjid=src_subjid));
  by src_subjid;
  rfstdtc = "&rfstdtc";
  %study_day2date(rfpendtc, LASTVSDT, 1);
  %study_day2date(rficdtc, ENROLLDT, 1);
  
  rfstdtc = ' ';
  rfendtc = ' ';
  rfxstdtc = ' ';
  rfxendtc = ' ';

  if SCRNFAIL then do;
    armcd = 'SCRNFAIL';
    arm = 'Screen Failure';
  end; else if missing(XTRTMT) then do;
    armcd = 'NOTASSGN';
    arm = 'Not Assigned';
  end; else do;
    armcd = put(XTRTMT, $armcd.);
    arm = put(XTRTMT, $arm.);
  end; 
  actarm = arm;
  actarmcd = armcd; 
run;

options mprint;

data dm;
  set empty_dm demog;
  studyid = src_studyid;
  domain = "DM";
  subjid = put(src_subjid, $6.);
  usubjid = subjid;
  siteid = put(src_siteid, $3.);
  sex = put(src_gender, sex.);
  country = "USA";
  if not missing(first) and not missing(last) then do;
    rfstdtc = "&rfstdtc";
  	%study_day2date(rfendtc, last, 1);
  	%study_day2date(rfxstdtc, first, 1);
  	rfxendtc = rfendtc;
 	end;
 	dthfl = ' ';
 	if missing(src_BIRTHDT) then do;
 	  age = .;
 	  ageu = ' ';
 	end; else do;
 	  age = src_BIRTHDT; /* age values, computed as of randomization date (RFSTDTC). */
 	  ageu = 'YEARS';
 	end;

  race = put(src_MAJRRACE, race.);
  if src_hispanic = 1 then ethnic = 'HISPANIC OR LATINO';
  else ethnic = 'NOT HISPANIC OR LATINO';
  
  visitnum = src_VISSEQ;
  visit = src_VISID;
  %zero_day_fix(visitdy, src_VISITDT);
  keep &dm_keepstring;
run;

%save_ds(dm, &project_folder/sdtm/data);

proc print data=dm;
run;  
