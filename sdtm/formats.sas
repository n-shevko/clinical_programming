proc format;
  value sex 1 = 'M'
            2 = 'F'
            other = 'U';
  
  value race 1 = 'WHITE'
             3 = 'BLACK OR AFRICAN AMERICAN'
             4 = 'ASIAN'
             5 = 'AMERICAN INDIAN OR ALASKA NATIVE'
             other = 'UNKNOWN';
             
  value $armcd 'GBR12909' = 'VNX'
               'Placebo'  = 'PLACEBO';
               
  value $arm 'GBR12909' = 'Vanoxerine'
             'Placebo'  = 'Placebo';               

  value aesev 1 = 'MILD'
              2 = 'MODERATE'
              3 = 'SEVERE';
              
  value aeser 1 = 'Y'
              0 = 'N' 
              other = 'U';
              
  value aeacn 1,6 = 'UNKNOWN'
              2   = 'DRUG WITHDRAWN'
              3   = 'DRUG INTERRUPTED'
              4   = 'DOSE REDUCED'
              5   = 'DOSE INCREASED';     
              
  value aeacnoth 1 = 'None'
                 2 = 'Remedial Therapy-pharm'
                 3 = 'Remedial Therapy-nonpharm'
                 4 = 'Hospitalization';     
                 
  value aerel 1 = 'DEFINITELY'
              2 = 'PROBABLY'
              3 = 'POSSIBLY'
              4 = 'REMOTELY'
              5 = 'DEFINITELY NOT'
              6 = 'UNKNOWN';  
              
  value aeout 1   = 'RECOVERED/RESOLVED'
              2,3 = 'NOT RECOVERED/NOT RESOLVED'
              4,5 = 'RECOVERING/RESOLVING'
              6   = 'FATAL'
              7   = 'UNKNOWN';
run;
