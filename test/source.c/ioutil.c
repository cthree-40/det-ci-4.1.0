// FILE: ioutil.c
/*********************************************************************
 * ioutil.c
 * --------
 * Contains routines for reading user input, molecular orbital input,
 * and writing output.
 *
 *
 * By Christopher L Malbon
 * Dept of Chemistry, The Johns Hopkins University
 ********************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include "ioutil.h"

/** fortran subroutines **/
extern void _readmoints_(double *moints1, double *moints2, long long int itype,
			 long long int orbitals,
			 long long int m1len, long long int m2len,
			 double *energy);
/*************************/

void readmointegrals(double *moints1, double *moints2, int itype,
		     int orbitals, unsigned char *moflname, int m1len,
		     int m2len, double *nuc_rep, double *fcenergy)
/* readmointegrals
 * ---------------
 * Subroutine to read 1 and 2 electron integrals.
 * Calls fortran subroutine readmoints()
 *
 * Input:
 *  itype     = type of integrals to read
 *  orbitals = MO's in system
 *  mofile   = name of molecular orbital file
 *  m1len    = length of moints1
 *  m2len    = length of moints2
 * Output:
 *  moints1  = 1-e integrals
 *  moints2  = 2-e integrals
 *  nuc_rep  = nuclear repulsion energy
 *  fcenergy = frozen-core energy
 */
{
     long long int itype8, orbitals8, m1len8, m2len8;
     double energy[2];
     
     itype8 = (long long int) itype;
     orbitals8 = (long long int) orbitals;
     m1len8 = (long long int) m1len;
     m2len8 = (long long int) m2len;
     
     printf("Calling readmoints_\n");
     printf(" Molecular integral file: %s\n", moflname);
     printf(" Type of integrals: %d\n", itype8);
     printf(" 1-e integrals: %d\n", m1len8);
     printf(" 2-e integrals: %d\n", m2len8);
     
     /* call fortran subroutine */
     readmoints_(moints1, moints2, &itype8, &orbitals8, &m1len8,
		&m2len8, energy);

     printf("%lf", energy[0]);
     printf("%lf", energy[1]);

     *nuc_rep = energy[0];
     *fcenergy = energy[1];
     return;
}
