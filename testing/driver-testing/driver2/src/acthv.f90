! Subroutine to compute the action of H on some vector V
! This subroutine follows closely:
!  Theor. Chem. Acc. (2001) 106:339-351
!====================================================================
! By Christopher L. Malbon
! Yarkony Group
! Dept. of Chem., The Johns Hopkins University
!
! Last edit: 11-20-13
!====================================================================
!Input:
! vector1         = input vector                            real*8 array
! moints1         = 1-e integrals                           real*8 array
! moints2         = 2-e integrals                           real*8 array
! moints1len      = length of moints1                       integer scalar
! moints2len      = length of moints2                       integer scalar
! pstring         = determinant string pairs ( p-leading)   integer array
! pstep           = p string step array                     integer array
! plocate         = location of p in pstring                integer array
! pxreflist       = pstring determinant list                integer array
! qstring         = determinant string pairs ( q-leading)   integer array
! qstep           = q string step array                     integer array
! qlocate         = location of q in qstring                integer array
! qxreflist       = qstring determinant list                integer array
! cidim           = dimension of CI space                   integer scalar
! pdetstrunc      = truncated alpha strings                 integer scalar
! qdetstrunc      = truncated beta  strings                 integer scalar
! adets           = non-truncated alpha strings             integer scalar
! bdets           = non-truncated beta strings              integer scalar
! aelec           = alpha electrons                         integer scalar
! belec           = beta electrons                          integer scalar
! orbitals        = number of MO's                          integer scalar
! diagonals       = < K | H | K >                           real*8 array
!Output:              
! vector2         = Hv                                      real*8 array
!====================================================================
subroutine acthv( vector1, moints1, moints2, moints1len, moints2len,     &
  pstring, pstep, plocate, qstring, qstep, qlocate, xreflist,            &
  cidim, pdets, qdets, pdetstrunc, qdetstrunc, adets, bdets, aelec, belec, orbitals,  &
  diagonals, vector2 )
  use actionutil
  implicit none
! ...input integer scalars...
  integer, intent(in) :: moints1len, moints2len, cidim, pdetstrunc,       &
                         qdetstrunc, adets, bdets, aelec, belec, orbitals 
! ...input integer arrays...
  integer, dimension(cidim,2), intent(in)    :: pstring, qstring
  integer, dimension(pdetstrunc), intent(in) :: pstep, plocate, pdets
  integer, dimension(qdetstrunc), intent(in) :: qstep, qlocate, qdets
  integer, dimension(cidim),      intent(in) :: xreflist
! ...input real*8 arrays...
  real*8, dimension(moints1len), intent(in) :: moints1
  real*8, dimension(moints2len), intent(in) :: moints2
  real*8, dimension(cidim), intent(in)      :: diagonals, vector1
! ...output real*8 arrays...
  real*8, dimension(cidim), intent(inout)   :: vector2
! ...loop integer scalars...
  integer :: i, j, k, l
#ifdef HVACTION
  integer :: openstat
  real*8, dimension(cidim) :: vector3, vector4, vector5, vector6
#endif
!--------------------------------------------------------------------
! Zero out vector2
  vector2 = 0d0
! Diagonal contribution
!*****************
 call acthv_diag( vector1, diagonals, cidim, vector2 )

#ifdef HVACTION
!  open(unit=30,file='diag.cont',status='new',iostat=openstat)
!  if ( openstat .ne. 0 ) stop "*** COULD NOT OPEN diag.cont ****"
!  do i=1, cidim
!    write( unit=30,fmt=1) vector2(i)
!  end do
!  close(unit=30)
1 format(1x,F10.6)
#endif

! Single, double and single single(beta) in alpha strings
  call acthv_alpha( vector1, moints1, moints2, moints1len, moints2len,       &
                    pstring, pstep, plocate, pdets, qstring,      &
                    qstep, qlocate, qdets, cidim, pdetstrunc,     &
                    qdetstrunc, adets, bdets, aelec, belec, orbitals, vector2 )
#ifdef HVACTION
  vector3 = 0d0
  vector3(755) = 1d0
  vector4 = 0d0
  call acthv_diag( vector3, diagonals, cidim, vector4)
  print *, " Diagonal contribution: vector4(755) = ", vector4(755)
  call acthv_alpha( vector3, moints1, moints2, moints1len, moints2len,       &
                    pstring, pstep, plocate, pdets, qstring,      &
                    qstep, qlocate, qdets, cidim, pdetstrunc,     &
                    qdetstrunc, adets, bdets, aelec, belec, orbitals, vector4 )
  print *, " Alpha contribution: vector4(755) = ", vector4(755)
  call acthv_beta( vector3, moints1, moints2, moints2len, moints2len, pstring, &
                   pstep, plocate, pdets, qstring, qstep, qlocate, qdets, xreflist,&
                   cidim, pdetstrunc, qdetstrunc, adets, bdets, aelec, belec,      &
                   orbitals, vector4 )
  print *, " Beta contribution: vector4(755) = ", vector4(755)
!  open(unit=20,file='alpha.cont',status='new',iostat=openstat)
!  if ( openstat .ne. 0 ) stop "*** COULD NOT OPEN alpha.cont ***"
!  do i=1, cidim
!    write( unit=20, fmt=1 ) vector4(i)
!  end do
!  close(unit=20)
!  open(unit=20,file='alpha.cont',status='new',iostat=openstat)
!  if ( openstat .ne. 0 ) stop "*** COULD NOT OPEN alpha.cont ***"
!!  do i=1, cidim
!    write( unit=20, fmt=1 ) vector4(i)
!  end do
!  close(unit=20)
#endif
! Single, double excitations in beta strings
  call acthv_beta( vector1, moints1, moints2, moints2len, moints2len, pstring, &
                   pstep, plocate, pdets, qstring, qstep, qlocate, qdets, xreflist,&
                   cidim, pdetstrunc, qdetstrunc, adets, bdets, aelec, belec,      &
                   orbitals, vector2 )

! Return vector2
  
  return
end subroutine
