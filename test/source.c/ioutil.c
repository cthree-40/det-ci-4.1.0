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
extern void _readmoints_(double *moints1, double *moints2,
			 long long int itype,
			 long long int orbitals,
			 long long int m1len,
			 long long int m2len,
			 double       *energy);

extern void _readnamelist_(long long int  nmlist,
			   unsigned char *nmlstr,
                           long long int *err);
/*************************/

int checkinputfiles()
/* checkinputfiles
 * ---------------
 * Check for the following input files:
 *  (1) = jayci.in    = input file containing &general and &diagalg namelists
 *  (2) = input.jayci = input file generated by jayci_exp.x
 *  (3) = moints      = molecular integral file
 *  (4) = det.list    = determinant input list
 * Returns integer value of missing input file.
 */
{
     /* local pointers 
      * fptr = file pointer */
     FILE *fptr;

     /* local scalars
      * err = error handling */
     int err;

     err = 0;
     
     fptr = fopen("jayci.in","r");
     if (fptr == NULL) {
	  err = 1;
	  return err;
     } else {
	  fclose(fptr);
     }

     fptr = fopen("input.jayci","r");
     if (fptr == NULL) {
	  err = 2;
	  return err;
     } else {
	  fclose(fptr);
     }

     fptr = fopen("moints", "r");
     if (fptr == NULL) {
	  err = 3;
	  return err;
     } else {
	  fclose(fptr);
     }

     fptr = fopen("det.list", "r");
     if (fptr == NULL) {
	  err = 4;
	  return err;
     } else {
	  fclose(fptr);
     }

     return err;
     
}
/* geninput: generate input for jayci.x 
 * -------------------------------------------------------------------
 * Input:
 *  dlen  = number of determinants
 *  alen  = number of alpha strings
 *  blen  = number of beta  strings
 *  aelec = number of alpha electrons
 *  belec = number of beta  electrons
 *  orbs  = number of orbitals
 *  nfrzc = number of frozen core orbitals
 *  nfrzv = number of frozen virtual orbitals */
int geninput(int dlen, int alen, int blen, int aelec, int belec, int orbs,
	     int nfrzc, int nfrzv)
{
     FILE *file;
     int err;
     
     err = 0;
     
     file = fopen("input.jayci","w");
     if (file == NULL) {
	  err = 1;
	  return err;
     }

     fprintf(file, "%15d\n", dlen);
     fprintf(file, "%15d\n", alen);
     fprintf(file, "%15d\n", blen);
     fprintf(file, "%15d\n", (aelec - nfrzc));
     fprintf(file, "%15d\n", (belec - nfrzc));
     fprintf(file, "%15d",   (orbs  - nfrzc - nfrzv));

     fclose(file);

     return err;
}
/* readgeninput: read general wavefunction input.
 * -------------------------------------------------------------------
 * Calls readnamelist which returns a character array
 *  nmlstr[0] = elec
 *  nmlstr[1] = orbs
 *  nmlist[2] = nfrozen
 *  nmlist[3] = ndocc
 *  nmlist[4] = nactive
 *  nmlist[5] = xlevel
 *  nmlist[6] = nfrzvirt
 *
 * Output:
 *  elec = number of electrons in system (alpha + beta)
 *  orbs = number of orbitals in system (including forzen core)
 *  nfrozen = number of frozen core orbitals
 *  ndocc = number of doubly-occupied orbitals
 *  nactive = number of active orbitals
 *  xlevel = excitaion level (Default is 2)
 *  nfrzvirt = number of frozen virtual orbitals
 *  err = error handling: n = missing variable n */
void readgeninput(int *elec,    int *orbs,   int *nfrozen,  int *ndocc,
	          int *nactive, int *xlevel, int *nfrzvirt, int *printlvl,
                  int *err)
{
     /* local scalars
      * gnml = namelist to read in */
     long long int gnml=1;

     /* local arrays
      * nmlstr = namelist character arrays */
     char nmlstr[MAX_NAMELIST_SIZE][MAX_LINE_SIZE];

     *err = 0;

     /* initialize variables */
     *elec     = 0;
     *orbs     = 0;
     *nfrozen  = 0;
     *ndocc    = 0;
     *nactive  = 0;
     *xlevel   = 2; 
     *nfrzvirt = 0;
     *printlvl = 0;

     /* read namelist 1 */
     readnamelist_(&gnml, nmlstr, &err);
     if (err != 0) return;

     /* stream the input into the proper variables */
     sscanf(nmlstr[0], "%d", elec);
     sscanf(nmlstr[1], "%d", orbs);
     sscanf(nmlstr[2], "%d", nfrozen);
     sscanf(nmlstr[3], "%d", ndocc);
     sscanf(nmlstr[4], "%d", nactive);
     sscanf(nmlstr[5], "%d", xlevel);
     sscanf(nmlstr[6], "%d", nfrzvirt);
     sscanf(nmlstr[7], "%d", printlvl);

     return;
     
}
void readmointegrals(double *moints1, double *moints2,         int itype,
		     int orbitals,    unsigned char *moflname, int m1len,
		     int m2len,       double *nuc_rep,
		     double *fcenergy)
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
