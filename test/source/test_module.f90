module test_module
  ! Testing module for jayci.
  implicit none

contains
  !*
  !*
  subroutine test_citrunc()
    !===========================================================================
    ! test_citrunc()
    ! --------------
    ! Purpose: test citrunc() subroutine.
    !---------------------------------------------------------------------------
    use truncation, only: citrunc1
    implicit none

    ! .. CITRUNC1 INPUT arguments ..
    integer :: aelec, belec, orbitals, nfrozen, ndocc, nactive, xlevel

    ! .. CITRUNC1 OUTPUT arguments ..
    integer :: astr_len, bstr_len, dtrm_len, ierr

    ! .. LOCAL arrays ..
    character*25 :: inflnm = "test.in"

    ! .. LOCAL scalars ..
    integer :: influn = 9

    ! .. TESTCITRUNC namelist ..
    namelist /testcitrunc/ aelec,   belec, orbitals, &
                           nfrozen, ndocc,  nactive, xlevel

    ! open input file and read namelist
    open(file = inflnm, unit = influn, action = "read", status = "old", &
      iostat = ierr)
    if (ierr .ne. 0) stop "*** Error opening input file: test.in! ***"
    read(unit = influn, nml = testcitrunc)
    close(influn)
    
    ! write namelist input to output stream
    write(*, 10) "aelec", aelec, "belec", belec, "orbitals", orbitals, &
      "nfrozen", nfrozen, "ndocc", ndocc, "nactive", nactive, "xlevel",&
      xlevel
10  format(7(a15, " =", i5, /))

    ! call citrunc
    call citrunc1(aelec, belec, orbitals, nfrozen, ndocc, nactive, &
      xlevel, astr_len, bstr_len, dtrm_len, ierr)

    ! print output arguments
    write(*, "(a)") ""
    write(*, 11) "Alpha strings", astr_len, "Beta strings", bstr_len, &
      "Determinants", dtrm_len
11  format(3(a15, " =", i15, /))
    
    return
  end subroutine test_citrunc
  !*
  !*
end module test_module
    