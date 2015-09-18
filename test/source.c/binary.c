// File: binary.c
/********************************************************************
 * binary.c
 * --------
 * Operations for binary digit computation.
 *
 * By Christopher L Malbon
 * Dept. of Chemistry, The Johns Hopkins University
 ********************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "binary.h"

/* subfunctions
 * ------------
 * int  binary2dec(int *binstr, int bsdim);
 * void dec2binary(int decdigit, int *binstr, int bsdim);
 */

int binary2dec(int *binstr, int bsdim)
/* binary2dec
 * ----------
 * Computes decimal digit given a binary digit stream
 *
 * Input:
 *  binstr = binary digit stream
 *  bsdim  = dimension of binary digit stream
 */
{
     int result = 0;
     int i;

     printf(" binstr = ");
     for (i = 0; i < bsdim; i++) {
	  printf("%d ", binstr[i]);
     }
     printf("\n");
     
     /* loop over binary digit stream */
     for (i = 0; i < bsdim; i++) {
	  result = result + binstr[i] * pow(2, i);
     }

     return result;
}

void dec2binary(int decdigit, int *binstr, int bsdim)
/* dec2binary
 * ----------
 * Computes binary digit stream given decimal input
 *
 * Input:
 *  decdigit = decimal digit to convert
 *  binstr   = output binary digit stream
 *  bsdim    = length 0f binary digit stream
 */
{
     int i, k;
     int *ptr; /* pointer to element on binstr */

     ptr = binstr+(bsdim-1);
     
     /* initialize binstr */
     for (i = 0; i < bsdim; i++) {
	  binstr[i] = 0;
     }

     /* use right-shift to compute binary digits */
     for (i = (bsdim-1); i >= 0; i--) {
	  k = decdigit >> i;

	  if (k & 1) {
	       *ptr = 1;
	       ptr--;
	  } else {
	       *ptr = 0;
	       ptr--;
	  }
	  
     }

     return;
}
