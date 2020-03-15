// File: mpi_utilities.h
/*
 * Utilities for MPI implementations of pjayci. The routines contained
 * herein modify global pjayci.x variables, and are responsible for
 * inter-node communication. Mostly interfaces for MPI Library routines.
 */

#ifndef mpi_utilities_h
#define mpi_utilities_h

/*
 * mpi_error_check_msg: check for error. Print message if error has
 * occured.
 * Input:
 *  error    = error flag
 *  fcn_name = calling function name
 *  message  = error message to print
 */
void mpi_error_check_msg (int error, char *fcn_name, char *message);

/*
 * mpi_split_work_array_1d: get first and last elements for partitioning
 * a 1d array amongst work processes.
 * Input:
 *  len  = length of vector (total)
 * Output:
 *  chunk = chunk size
 *  lo    = first element
 *  hi    = last  element
 */
void mpi_split_work_array_1d (int len, int *chunk, int *lo, int *hi);

/*
 * set_mpi_process_number_and_rank: set global variables $mpi_num_procs
 * and $mpi_proc_rank.
 */
void set_mpi_process_number_and_rank ();

/*
 * set_ga_process_number_and_rank: set global variables $mpi_num_procs
 * and $mpi_proc_rank with GA wrappers.
 */
void set_ga_process_number_and_rank ();

#endif