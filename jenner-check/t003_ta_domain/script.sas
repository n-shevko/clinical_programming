/* Bundle derived from sdtm/TA.sas + sdtm/TA.csv in this repo.
   TA.sas builds the Trial Arms (TA) SDTM domain by importing TA.csv, merging
   an empty metadata-driven template, then exporting ta.xpt. The template merge
   and xpt export need the study's external metadata.xlsx, so this bundle reads
   the study's own TA.csv rows (embedded verbatim below, dsd-parsed exactly as
   proc import does, quoted commas and all) and prints the resulting TA domain. */

data ta;
  length STUDYID $13 DOMAIN $2 ARMCD $8 ARM $10 ETCD $8 EPOCH $20
         ELEMENT $20 TABRANCH $25 TATRANS $75;
  infile datalines dsd truncover;
  input STUDYID $ DOMAIN $ ARMCD $ ARM $ TAETORD ETCD $ EPOCH $ ELEMENT $ TABRANCH $ TATRANS $;
  datalines;
NIDA-CPU-0005,TA,PLACEBO,Placebo ,1,SCRN,SCREENING ,Screen,,
NIDA-CPU-0005,TA,PLACEBO,Placebo ,2,WASHOUT,WASHOUT ,Washout,,
NIDA-CPU-0005,TA,PLACEBO,Placebo ,3,BASE,BASELINE ,Baseline,Randomized to Placebo,
NIDA-CPU-0005,TA,PLACEBO,Placebo ,4,PLACEBO,TREATMENT ,Placebo,,
NIDA-CPU-0005,TA,PLACEBO,Placebo ,5,IN_FU,INPATIENT FOLLOW-UP,Inpatient follow-up,,"if decrease in WBC or ANC is not significant, go to outpatient follow-up"
NIDA-CPU-0005,TA,PLACEBO,Placebo ,6,PLACEBO,TREATMENT ,Placebo,,
NIDA-CPU-0005,TA,PLACEBO,Placebo ,7,IN_FU,INPATIENT FOLLOW-UP,Inpatient follow-up,,
NIDA-CPU-0005,TA,PLACEBO,Placebo ,8,OUT_FU,OUTPATIENT FOLLOW-UP,Outpatient follow-up,,
NIDA-CPU-0005,TA,VNX,Vanoxerine,1,SCRN,SCREENING ,Screen,,
NIDA-CPU-0005,TA,VNX,Vanoxerine,2,WASHOUT,WASHOUT ,Washout,,
NIDA-CPU-0005,TA,VNX,Vanoxerine,3,BASE,BASELINE ,Baseline,Randomized to Vanoxerine,
NIDA-CPU-0005,TA,VNX,Vanoxerine,4,VNX,TREATMENT ,Vanoxerine,,
NIDA-CPU-0005,TA,VNX,Vanoxerine,5,IN_FU,INPATIENT FOLLOW-UP,Inpatient follow-up,,"if decrease in WBC or ANC is not significant, go to outpatient follow-up"
NIDA-CPU-0005,TA,VNX,Vanoxerine,6,VNX,TREATMENT ,Vanoxerine,,
NIDA-CPU-0005,TA,VNX,Vanoxerine,7,IN_FU,INPATIENT FOLLOW-UP,Inpatient follow-up,,
NIDA-CPU-0005,TA,VNX,Vanoxerine,8,OUT_FU,OUTPATIENT FOLLOW-UP,Outpatient follow-up,,
;
run;

proc print data=ta;
run;
