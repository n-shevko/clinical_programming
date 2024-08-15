%macro add_perfix(ds=, prefix=, exclude=);
  %let src_lib = %upcase(%scan(&ds, 1, "."));
  %let src_ds = %upcase(%scan(&ds, 2, "."));
  
  %if &src_ds = %then %do;
    data _null_;
      put "ERROR: specify lib for ds_vars arguments";
    run;
  %end; %else %do;
		proc sql noprint;
		  select cats("&prefix._", name) into :new_names separated by "|" from dictionary.columns where 
		    memname = "%upcase(&src_ds)" and 
		    libname = "%upcase(&src_lib)";
		  select name into :old_names separated by "|" from dictionary.columns where 
		    memname = "%upcase(&src_ds)" and 
		    libname = "%upcase(&src_lib)";
		run;  
		
		data &src_ds;
		  set &ds(rename=(%do i=1 %to %sysfunc(countw(%quote(&old_names), |));
		    %let old = %scan(%quote(&old_names), &i, |);
		    %let new = %scan(%quote(&new_names), &i, |);
		    %if &exclude ^= &old %then &old=&new;
		  %end;));
		run;
  %end;
%mend;


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


%macro save_ds(src, path);
  /* 
    - .xpt and .sas7bdat files will be created from src dataset
    - src dataset should be in the work library
    - <domain>_sortstring macrovariable should exist to sort the output dataset
    - all character variables will be left aligned
    - sizes of all character variables will be modified so that it will be equal to the max value in the column
    - all character variables which contain only point as a value '.' will be rewriten to a missing value
  */
  
  /* We determine number of character variables */
  data _null_;
    set &src;
    array chars{*} _CHARACTER_;
    call symputx('vars_num', dim(chars));
    stop;
  run;
  
  
  data &src;
    set &src end=last;
    array chars{*} _CHARACTER_;
    array value_size{&vars_num}; 
    retain value_size1-value_size&vars_num;
    
    do i=1 to dim(chars);
      chars[i] = left(chars[i]);  /* left aligning char values */
      if chars[i] = '.' then chars[i] = ' ';
      if length(chars[i]) > value_size[i] then value_size[i] = length(chars[i]);
    end;
    
    if last then do;
      do i=1 to dim(chars);  /* Create of macrovars for each character variable with its name and maximal value size */
        call symput(catt('name', i), vname(chars[i]));
        call symput(catt('max_val', i), value_size[i]); 
      end;
    end;
    drop i value_size1-value_size&vars_num;
  run;
  
  
  proc sql noprint;
	  select name
	    into :names separated by " "
	        from dictionary.columns
	          where libname="WORK" and
	            memname="%upcase(&src)";
  quit;
  
  
  data &src;
    retain &names;  /* To keep the order of vars. The length statement may change the original order. */
    length %do i = 1 %to &vars_num;  /* Redefining the length of variables */
             &&name&i $ &&max_val&i
           %end;
           ;
    set &src;
  run;

  proc sort data=&src;
    by &&&src._sortstring;
  run; 

  libname &src xport "&path/&src..xpt";
  libname perm "&path";
  
  proc copy in=work out=&src;
    select &src;
  run;
  
  proc copy in=work out=perm;
    select &src;
  run;
  
  libname perm clear;
  libname &src clear;
%mend;
