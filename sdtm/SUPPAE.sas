/*
purpose: create SUPPAE data set
input: sdtm.dm sdtm.ae
output: suppae.xpt
protocol: NIDA-CPU-0002A
sas version: 9.04
*/

%include "~/nida-cpu-0005/sdtm/includes.sas";

%make_aux_utils(metadatafile=&project_folder/sdtm/metadata.xlsx, dataset=SUPPAE);

data suppae;
  set empty_suppae sdtm.ae;
	rdomain = 'AE';
	
	idvar = 'AESEQ';
	idvarval = aeseq;
	
  qnam = 'AETRTEM';
  qlabel = 'Treatment Emergent Flag';
  qorig = 'Derived';
  qeval = 'CLINICAL RESEARCH ASSOCIATE';
run;	

data suppae;
  merge suppae(in=in_supae) sdtm.dm;
  by usubjid; 
  
  trtsdt = input(rfxstdtc, yymmdd10.);
  trtedt = input(rfxendtc, yymmdd10.);
  
  if aerel in ('DEFINITELY', 'PROBABLY', 'POSSIBLY', 'REMOTELY') and 
     ((astdt >= trtsdt and astdt <= trtedt) or missing(astdt)) then qval = 'Y';
  else qval = 'N';
  keep &suppae_keepstring;
  if in_supae;
run;

%save_ds(suppae, &project_folder/sdtm/data);

proc print data=suppae;
run;