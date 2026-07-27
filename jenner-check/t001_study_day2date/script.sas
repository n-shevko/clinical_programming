/* Bundle derived from macroses/common.sas in this repo.
   Two macros are reproduced verbatim from that file:
     - %zero_day_fix   (SDTM disallows study day 0)
     - %study_day2date (converts a study day to a yymmdd10 date relative to RFSTDTC)
   A small caller exercises them against mock study-day data, the same way
   AE.sas / DM.sas call them to derive *STDTC / *ENDTC. No data file is read. */

%macro zero_day_fix(result, study_day);
  /* sdtm doesn't allow 0 day */
  if &study_day >= 0 then &result = &study_day + 1;
  else &result = &study_day;
%mend;

%macro study_day2date(result, study_day, zero_day_fix);
  /* dm.rfstdtc should be available when this macros is used
     The following rule is used:

     If date is before RFSTDTC day, then *DY=(RFSTDTC - *DTC)
     If observation date is on the same day as RFSTDTC or later, then *DY=(*DTC-RFSTDTC)+1

     if zero_day_fix = 1 then this means that study_day may be equal to 0 and we should avoid this situation.
     The formula above can't give 0 study day as the result.
  */

  tmp_&study_day = &study_day;
  %if &zero_day_fix %then %do;
    if &study_day >= 0 then tmp_&study_day = &study_day + 1;
  %end;

  if tmp_&study_day >= 1 then &result = put(tmp_&study_day - 1 + input(rfstdtc, yymmdd10.), yymmdd10.);
  else &result = put(tmp_&study_day + input(rfstdtc, yymmdd10.), yymmdd10.);

  drop tmp_&study_day;
%mend;

/* Caller: derive AE start/stop calendar dates from study days, exactly as AE.sas does. */
data derived;
  length rfstdtc $10 aestdtc aeendtc $10;
  rfstdtc = "2003-10-25";  /* reference start date, as in DM.sas */
  input subjid aestart aestop;
  %zero_day_fix(aestdy, aestart);
  %zero_day_fix(aeendy, aestop);
  %study_day2date(aestdtc, aestdy, 0);
  %study_day2date(aeendtc, aeendy, 0);
  datalines;
101 -2 3
102 0 5
103 1 11
104 -5 -1
105 7 14
;
run;

proc print data=derived;
  var subjid aestart aestop aestdy aeendy aestdtc aeendtc;
run;
