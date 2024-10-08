*---------------------------------------------------------------*;
* make_aux_utils.sas creates a zero record dataset based on a 
* dataset metadata spreadsheet.  The dataset created is called
* EMPTY_** where "**" is the name of the dataset.  This macro also
* creates a global macro variable called **KEEPSTRING that holds 
* the dataset variables desired and listed in the order they  
* should appear.  [The variable order is dictated by VARNUM in the 
* metadata spreadsheet.]
*
* MACRO PARAMETERS:
* metadatafile = the MS Excel file containing the dataset metadata
* dataset = the dataset or domain name you want to extract
*---------------------------------------------------------------*;
%macro make_aux_utils(metadatafile=,dataset=);
    
	proc import 
	    datafile="&metadatafile"
	    out=datasets 
	    dbms=XLSX
	    replace;
	    sheet="Datasets";
	run;   
	
	proc import 
	    datafile="&metadatafile"
	    out=_temp 
	    dbms=XLSX
	    replace;
	    sheet="Variables";
	run;
	
	** sort the dataset by expected specified variable order;
	proc sort
	  data=_temp;
	where dataset = "&dataset";
	    by order;	  
	run;
	
	data _null_;
	  set datasets;
	  if dataset = "&dataset" then do; 
	    call symput("ds_label", label);
	    call symputx("&dataset._SORTSTRING", compress('Key Variables'n, ","), "G");
	  end;
	run;
	
	
	** create keepstring macro variable and load metadata 
	** information into macro variables;
	%global &dataset._KEEPSTRING;
	data _null_;
	  set _temp nobs=nobs end=eof;
	
	    if _n_=1 then
	      call symput("vars", compress(put(nobs,3.)));
	
	    call symputx('var'    || compress(put(_n_, 3.)), variable);
	    call symputx('label'  || compress(put(_n_, 3.)), label);
	    call symputx('length' || compress(put(_n_, 3.)), put(length, 3.));
	
	
	    ** valid ODM types include TEXT, INTEGER, FLOAT, DATETIME, 
	    ** DATE, TIME and map to SAS numeric or character;
	    if upcase('Data Type'n) in ("INTEGER", "FLOAT") then
	      call symputx('type' || compress(put(_n_, 3.)), "");
	    else if upcase('Data Type'n) in ("TEXT", "DATE", "DATETIME", "TIME") then
	      call symputx('type' || compress(put(_n_, 3.)), "$");
	    else
	      put "ERR" "OR: not using a valid ODM type.  " type=;
	
	
	    ** create **KEEPSTRING macro variable;
	    length keepstring $ 32767;	 
	    retain keepstring;		
	    keepstring = compress(keepstring) || "|" || left(variable); 
	    if eof then
	      call symputx(upcase(compress("&dataset" || '_KEEPSTRING')), 
	                   left(trim(translate(keepstring," ","|"))));
	run;
	 
	
	** create a 0-observation template data set used for assigning 
	** variable attributes to the actual data sets;
	data EMPTY_&dataset(label="&ds_label");
	    %do i=1 %to &vars;           
	       attrib &&var&i label="&&label&i" 
	         %if "&&length&i" ne "" %then
	           length=&&type&i.&&length&i... ;
	       ;
	       %if &&type&i=$ %then
	         retain &&var&i '';
	       %else
	         retain &&var&i .;
	       ;
	    %end;
	    if 0;
	run;
  
  proc delete data=_temp;
  run;

  proc delete data=datasets;
  run;
%mend;
