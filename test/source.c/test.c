#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "combinatorial.h"
#include "straddress.h"
#include "binary.h"
#include "moindex.h"
#include "ioutil.h"


void main()
{
     int orb = 23;
     int m1len, m2len;

     double *moints1, *moints2;
     double nrep, fce;
     unsigned char moflname[FLNMSIZE];
     int type;

     int elec, orbs;
     int nfrzc, nfrzv, ndocc, nactv;
     int xlvl, prtlvl;

     int err;
     int i;
     
     m1len = index1e(orb, orb);
     m2len = index2e(orb, orb, orb, orb);

     moints1 = malloc(m1len * sizeof(double));
     moints2 = malloc(m2len * sizeof(double));

     type = 1;
     strncpy(moflname,"moints", FLNMSIZE);

     printf(" Reading molecular integrals from file: %s\n", moflname);
     printf("  %5d 1-e integrals\n  %5d 2-e integrals\n", m1len, m2len);

     readmointegrals(moints1, moints2, type, orb,
		     moflname, m1len, m2len, &nrep, &fce);

     for (i=0; i<m1len; i++) {
	  printf(" %15.8lf\n", moints1[i]);
     }
     printf("Nuc Rep   = %15.8lf\n", nrep);
     printf("FC Energy = %15.8lf\n", fce);
     
     printf(" Reading namelist.\n");

     readgeninput(&elec, &orbs, &nfrzc, &ndocc, &nactv,
		  &xlvl, &nfrzv, &prtlvl, &err);
     printf("  electrons = %5d\n", elec);
     printf("  orbitals  = %5d\n", orbs);
     printf("  nfrzc     = %5d\n", nfrzc);
     printf("  ndocc     = %5d\n", ndocc);
     printf("  nactv     = %5d\n", nactv);
     printf("  nfrzv     = %5d\n", nfrzv);
     
     free(moints1);
     free(moints2);
}

	
