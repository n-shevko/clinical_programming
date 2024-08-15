I took open data from [National Institute on Drug Abuse](https://datashare.nida.nih.gov) 
and converted (partially) them into CDISC datasets.

**Study ID:** NIDA-CPU-0005  
**Study Title:** VANOXERINE IN COCAINE EXPERIENCED AFRICAN AMERICAN VOLUNTEERS  
**Data source:** https://datashare.nida.nih.gov/study/nida-cpu-0005  
**Protocol:** https://datashare.nida.nih.gov/sites/default/files/studydocs/14227/CPU0005-Protocol.pdf  
**CRF:** https://datashare.nida.nih.gov/sites/default/files/studydocs/14227/CPU0005-CRF.pdf  

The description of the project structure:
| Path | Comment |
|--|--|
|/source/*.sas7bdat| raw data|
|/sdtm/*.sas |source code used to generate sdtm datasets|
|/sdtm/data/*.xpt|generated sdtm datasets|
|/sdtm/report.xlsx|Pinnacle 21 validator report|
|/sdtm/define.xml|sdtm metadata in xml format|
|/sdtm/metadata.xlsx|sdtm metadata in xlsx format|

### Comments

Here are some comments about the data and some issues in the validation report.

Due to [de-identification](https://datashare.nida.nih.gov/sites/default/files/studydocs/14227/CPU0005-DeidentificationNotes_0.pdf) patients who failed screening will have missing values in date fields.

The raw data has 0 day in the date columns.
Day 0 isn't allowed in SDTM so the date columns were modified by the next logic:
```
if raw_data_study_day >= 0
  then study_day_in_sdtm = raw_data_study_day + 1
else
  study_day_in_sdtm = raw_data_study_day
```

#### DM dataset

41 subjects were screened for eligibility.
30 of them were ineligible due to the next reasons:
- subject lost to follow-up
- subject is a screen failure
- subject can no longer attend clinic
- subject withdraw

The rest of them (11 subjects) were randomized to Placebo (6 subjects) or Vanoxerine (5 subjects). 
The average age of the randomized subjects is 39 years. 2 of them are females and 9 are males.
The clinical trial was conducted at one medical center.

Due to de-identification: 
- I don't know exact randomization date (RFSTDTC) so I made the assumption that
all the subjects were randomized on 2003-10-25
- The variables endtrial.LASTVSDT (the source for RFPENDTC) and enroll.ENROLLDT (the source for RFICDTC) 
are empty for the subjects who failed screening so these variables are empty for these subjects.

#### AE dataset

I don't have access to the MedDRA dictionary so:
- Dictionary-derived text descriptions of the MedDRA variables (AEPTCD AEHLTCD etc.) aren't provided
- AEDECOD AEBODSYS aren't known for the study

There are some ae with AEENDTC date is after RFPENDTC. 
I don't know how to deal with this situation.
The possible soulution is to write the value of AEENDTC to RFPENDTC.

The subject with USUBJID = 93183 has empty AESTDTC/AEENDTC because she failed screening. 

#### SUPPAE dataset

An adverse event is considered treatment emergent if aerel in ('DEFINITELY', 'PROBABLY', 'POSSIBLY', 'REMOTELY')
and it was occured in treatment epoch.

#### EX dataset

All the subjects that were randomized to 75 mg of Vanoxerine or Placebo.
Vanoxerine was administered as one 50 mg and one 25 mg capsule.
The treatment was ingested once every 24 hours in the fasted state 
(nothing by mouth except water after midnight until two hours after dose).
The route of administration was oral.
The treatment epoch duration was 11 days.

#### TA dataset

The clinical trial has 6 epochs:
- SCREENING             (30 days)
- WASHOUT               (1 day)
- BASELINE              (3 days)
- TREATMENT             (11 days)
- INPATIENT FOLLOW-UP   (1 week)
- OUTPATIENT FOLLOW-UP  (4 weeks)

and 2 arms: Vanoxerine and Placebo

Subjects who demonstrate a significant decrease in WBC or ANC during the initial inpatient phase
will not be discharged but followed as in-patients until blood counts return within the normal range.
They will then be re-challenged with the same treatment as the one they received during the initial phase, 
i.e., study drug or placebo.
