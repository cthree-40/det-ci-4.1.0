/* iminmax.c */
/* 
 * Subfunctions to return minimum and maximum integers. 
 */

/* int_min: return minimum */
int int_min(int a, int b)
{
	int min;
	if (a >= b) {
		min = a;
		return min;
	} else {
		min = b;
		return min;
	}
};
