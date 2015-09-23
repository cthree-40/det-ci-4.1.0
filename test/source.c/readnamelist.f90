subroutine readnamelist(nmlist, nmlstr, err)
  ! readnamelist
  ! ------------
  ! Reads namelist.
  ! Input:
  !  nmlist = 1: general
  !           2:
  ! Output:
  !  nmlstr = namelist string
  implicit none

  ! .. input arguments ..
  integer, intent(in) :: nmlist

  ! .. output arguments ..
  character*300, dimension(30), intent(out) :: nmlstr
  integer, intent(out) :: err
  
  ! .. namelists ..
  integer :: gen_nml = 1, dai_nml = 2
  
  ! .. &general arguments ..
  integer :: electrons, orbitals
  integer :: nfrozen, ndocc, nactive, nfrzvirt
  integer :: xlevel, printlvl

  ! .. &dalginfo arguments ..
  integer :: maxiter, krymin, krymax, nroots
  integer :: prediagr, refdim
  real*8  :: restol

  namelist /general/ electrons, orbitals, nfrozen, ndocc, nactive, &
    nfrzvirt, xlevel, printlvl
  namelist /dalginfo/ maxiter, krymin, krymax, nroots, prediagr, &
    restol, refdim

  ! initialize error flag
  err = 0
  if (nmlist .eq. gen_nml) then
    electrons = 0
    orbitals  = 0
    nfrozen   = 0
    ndocc     = 0
    nfrzvirt  = 0
    xlevel    = 0
    printlvl  = 0
    open(file = "jayci.in", unit = 10, action = "read", status = "old", &
      iostat = err)
    if (err .ne. 0) return

    read(10, nml=general)

    ! write values to namelist array
    write(nmlstr(1),9) electrons
    write(nmlstr(2),9) orbitals
    write(nmlstr(3),9) nfrozen
    write(nmlstr(4),9) ndocc
    write(nmlstr(5),9) nactive
    write(nmlstr(6),9) xlevel
    write(nmlstr(7),9) nfrzvirt
    write(nmlstr(8),9) printlvl

    close(10)
    return
  else if (nmlist .eq. dai_nml) then
    ! dalginfo namelist
    maxiter   = 20
    krymin    =  3
    krymax    =  8
    nroots    =  1
    prediagr  =  1
    restol    = 1.0d-5
    refdim    =  3
    open(file = "jayci.in", unit = 10, action = "read", status = "old", &
      iostat = err)
    if (err .ne. 0) return

    read(10, nml=dalginfo)

    write(nmlstr(1),9) maxiter
    write(nmlstr(2),9) krymin
    write(nmlstr(3),9) krymax
    write(nmlstr(4),9) nroots
    write(nmlstr(5),9) prediagr
    write(nmlstr(6),8) restol
    write(nmlstr(7),9) refdim

    close(10)
    return
  else
    ! uknown namelist flag
    err = 99
    return
  endif
8 format(f10.5)
9 format(i10)
end subroutine readnamelist
