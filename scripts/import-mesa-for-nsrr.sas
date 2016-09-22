*import-mesa-for-nsrr.sas;

*set library name and options;
libname mesacc "\\rfawin\bwh-sleepepi-mesa\nsrr-prep\_datasets";
options nofmterr;

*set dataset version number;
%let release = 0.1.0.beta1;

*import sas datasets from mesa coordinating center;
data mesa_bridge;
  set mesacc.mesabiolincc_bridgeid_20160815;

  *create exam number variable for later graph generation;
  examnumber = 5;
run;

data mesa_e1;
  set mesacc.mesae1finallabel02092016;

  keep idno race1c gender1;
run;

data mesa_e5;
  set mesacc.mesae5_finallabel_20160520;

  keep idno age5c;
run;

data mesa_sleepq;
  set mesacc.mesae5_sleepq_20140617;
run;

data mesa_polysomnography;
  set mesacc.mesae5_sleeppolysomn_20150630;
run;

data mesa_actigraphy;
  set mesacc.mesae5_sleepactigraphy_20140617;
run;

*merge datasets;
data mesa_nsrr;
  merge mesa_bridge
    mesa_e1
    mesa_e5
    mesa_sleepq (in=a)
    mesa_polysomnography (in=b)
    mesa_actigraphy (in=c);
  by idno;

  *only keep subjects with sleep-related data;
  if a or b or c;

  *recode values for clarity;
  if inhomepsgyn5 = -9 then inhomepsgyn5 = .; /* missing code, set to nil */

  *drop 'idno' in favor of using 'mesaid' for dataset and files;
  drop idno;
run;

proc sort data=mesa_nsrr;
  by mesaid;
run;

*export to csv for depositing on nsrr;
proc export 
  data=mesa_nsrr 
  outfile="\\rfawin\bwh-sleepepi-mesa\nsrr-prep\_releases\&release\mesa-sleep-dataset-&release..csv" 
  dbms=csv 
  replace; 
run;