How to get all consecutive subsets of a vector?

  Two solutions

     1. WPS/PROC R
     2. SAS base

https://goo.gl/rPhuvA
https://stackoverflow.com/questions/48240868/how-to-get-all-consecutive-subsets-of-a-vector

Akrun profile
https://stackoverflow.com/users/3732271/akrun


INPUT
=====
                           | RULES  alls subsets with consecutive elements
 SD1.HAVE total obs=1      |
                           |
    V1 V2 V3 V4 V5         |  C1    C2    C3    C4
                           |
    A1 A2 A3 A4 A5         |  A1    A2
                           |  A2    A3
                           |  A3    A4
                           |  A4    A5
                           |
                           |  A1    A2    A3
                           |  A2    A3    A4
                           |  A3    A4    A5
                           |
                           |  A1    A2    A3    A4
                           |  A2    A3    A4    A5


PROCESS
=======

   WPS/PROC R WORKING CODE
   =======================

   R has a wealth of specialized functions but who knows all of them?

     lst<-lapply(seq_along(have), function(i) embed(have, i)[, i:1, drop = FALSE]);


   SAS  ( all the code)
   =====================

   I use lexcombi to get all combinations. I then  select just the
   consecutive indexes (eliminate 3-2-4 but keep 2-3-4)

      * create null dataset;
      data want;
      run;quit;

      data _null_;

       do rol=2 to 4;
        call symputx("rol",rol);
        * number of consecutive indexes ie k in n choose k;

        rc=dosubl('
          data m&rol(keep=c:);
          array x[5] $3 ("A1" "A2" "A3" "A4" "A5");
          array c[&rol.] $3 c1-c&rol;
          array i[&rol.] ;
          n=dim(x);
          k=dim(i);
          i[1]=0;
          ncomb=comb(n,k); * n choose k;
          do j=1 to ncomb+1;
             rc=lexcombi(n, k, of i[*]);
             if i[&rol]-i[1]=(&rol -1) and rc ne -1 then do; * selects consecutive indexes;
                do h=1 to k;
                  c[h]=x[i[h]];
                end;
                output;
             end;
          end;
          run;quit;
          data want;
            set want m&rol;  * append;
          run;quit;
        ');
       end;
       stop;
      run;quit;

OUTPUT
======

SAS

 WORK.WANT  total obs=10

  Obs    C1    C2    C3    C4

    1
    2    A1    A2
    3    A2    A3
    4    A3    A4
    5    A4    A5
    6    A1    A2    A3
    7    A2    A3    A4
    8    A3    A4    A5
    9    A1    A2    A3    A4
   10    A2    A3    A4    A5


R

  WORK.WANT total obs=9

  Obs      FRO      V1    V2    V3    V4

   1     WORK.M1    A1    A2
   2     WORK.M1    A2    A3
   3     WORK.M1    A3    A4
   4     WORK.M1    A4    A5
   5     WORK.M2    A1    A2    A3
   6     WORK.M2    A2    A3    A4
   7     WORK.M2    A3    A4    A5
   8     WORK.M3    A1    A2    A3    A4
   9     WORK.M3    A2    A3    A4    A5

*                _              _       _
 _ __ ___   __ _| | _____    __| | __ _| |_ __ _
| '_ ` _ \ / _` | |/ / _ \  / _` |/ _` | __/ _` |
| | | | | | (_| |   <  __/ | (_| | (_| | || (_| |
|_| |_| |_|\__,_|_|\_\___|  \__,_|\__,_|\__\__,_|

;


options validvarname=upcase;
libname sd1 "d:/sd1";
data sd1.have;
  v1='A1';
  v2='A2';
  v3='A3';
  v4='A4';
  v5='A5';
  output;
run;quit;
*          _       _   _
 ___  ___ | |_   _| |_(_) ___  _ __  ___
/ __|/ _ \| | | | | __| |/ _ \| '_ \/ __|
\__ \ (_) | | |_| | |_| | (_) | | | \__ \
|___/\___/|_|\__,_|\__|_|\___/|_| |_|___/

;
*
 ___  __ _ ___
/ __|/ _` / __|
\__ \ (_| \__ \
|___/\__,_|___/

;

 * create null dataset;
 data m;
 run;quit;

 data want;

  do rol=2 to 4;
   call symputx("rol",rol);

   rc=dosubl('
     data m&rol(keep=c:);
     array x[5] $3 ("A1" "A2" "A3" "A4" "A5");
     array c[&rol.] $3 c1-c&rol;
     array i[&rol.] ;
     n=dim(x);
     k=dim(i);
     i[1]=0;
     ncomb=comb(n,k);
     do j=1 to ncomb+1;
        rc=lexcombi(n, k, of i[*]);
        if i[&rol]-i[1]=(&rol -1) and rc ne -1 then do;
           do h=1 to k;
             c[h]=x[i[h]];
           end;
           output;
        end;
     end;
     run;quit;
     data m;
       set m m&rol;
     run;quit;
   ');
  end;
  stop;
 run;quit;

*____
|  _ \
| |_) |
|  _ <
|_| \_\

;


%utl_submit_wps64('
libname sd1 sas7bdat "d:/sd1";
options set=R_HOME "C:/Program Files/R/R-3.3.2";
libname wrk sas7bdat "%sysfunc(pathname(work))";
libname hlp sas7bdat "C:\Program Files\SASHome\SASFoundation\9.4\core\sashelp";
proc r;
submit;
source("C:/Program Files/R/R-3.3.2/etc/Rprofile.site", echo=T);
library(haven);
library(zoo);
have<-t(read_sas("d:/sd1/have.sas7bdat"));
lst<-lapply(seq_along(have), function(i) embed(have, i)[, i:1, drop = FALSE]);
lst;
m1<-lst[[2]];
m2<-lst[[3]];
m3<-lst[[4]];
endsubmit;
import r=m1  data=wrk.m1;
import r=m2  data=wrk.m2;
import r=m3  data=wrk.m3;
run;quit;
');


data want;
  retain fro;
  set
    m1-m3 indsname=indsn;
  fro=indsn;
run;quit;


