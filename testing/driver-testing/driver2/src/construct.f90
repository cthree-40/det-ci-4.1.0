module construct
  implicit none
contains
!  subroutine hv_construct( spdim, actstrlen,  moints1, &
!  moints2, max1e, max2e, actstr, aelec, belec, totels,  &
!  orbitals, adets, bdets, dgls, nfrzn, ndocc, ncas )
!==========================================================
! Explicitly construct hamiltonian
!==========================================================
!
!  implicit none
!  integer, intent(in) :: spdim, actstrlen, max1e, max2e,&
!    aelec, belec, totels, orbitals, adets, bdets, &
!    nfrzn, ndocc, ncas
!  integer, dimension(actstrlen),intent(in) :: actstr
!  real*8, dimension(max1e),intent(in)      :: moints1
!  real*8, dimension(max2e),intent(in)      :: moints2
!  real*8, dimension(actstrlen),intent(in)  :: dgls
!
!
!  real*8, dimension(:,:), allocatable :: unitmat, hammat
!
!  integer :: i, j, k
!
!
!  character*1 :: uplo, jobz, rnge
!  real*8 :: abstol, ddot, dlamch
!  integer :: lwork, liwork, il, iu, info, m, vu, vl
!  integer,dimension(:),allocatable :: isuppz
!  real*8, dimension(:),allocatable :: work
!  real*8, dimension(:),allocatable :: iwork
!  real*8, dimension(:,:), allocatable :: eigvec
!  real*8, dimension(:), allocatable :: eigval
!
!  interface
!    subroutine acthv( vector1, moints1, moints2, moints1len, &
!                      moints2len,pstring, pstep, plocate,    &
!                      qstring, qstep, qlocate, cidim, pdets, &
!                      qdets, pdetstrunc, qdetstrunc, adets,  &
!                      bdets, aelec, belec, orbitals,diagonals, vector2 )
!      integer, intent(in) :: moints1len, moints2len, cidim, pdetstrunc,       &
!                             qdetstrunc, adets, bdets, aelec, belec, orbitals 
!      integer, dimension(cidim,2), intent(in)    :: pstring, qstring
!      integer, dimension(pdetstrunc), intent(in) :: pstep, plocate, pdets
!      integer, dimension(qdetstrunc), intent(in) :: qstep, qlocate, qdets
!      real*8, dimension(moints1len), intent(in)  :: moints1
!      real*8, dimension(moints2len), intent(in)  :: moints2
!      real*8, dimension(cidim), intent(in)       :: diagonals, vector1
!      real*8, dimension(cidim), intent(inout)    :: vector2
!    end subroutine
!  end interface
 

!----------------------------------------------------------
! Allocate arrays
!  allocate( unitmat( actstrlen, actstrlen ) )
!  allocate( hammat( actstrlen, actstrlen ) )
!  do i=1, actstrlen
!    do j=1, actstrlen
!      if ( i .eq. j ) then
!        unitmat(i,j) = 1d+0
!      else
!        unitmat(i,j) = 0d+0
!      end if
!    end do
!  end do
!
!  hammat = 0d0
!
!  do i=1, actstrlen
!    call acthv( unitmat(1,i), moints1, moints2, max1e, max2e, &
!      actstr, actstrlen, aelec, belec, totels, orbitals, adets,&
!      bdets, dgls, nfrzn, ndocc, ncas, hammat(1,i) )
!  end do
!
!  jobz = 'v'
!  rnge = 'a'
!  uplo = 'u'
!  abstol = dlamch( 'safe minimum' )
!  liwork = 12*actstrlen
!  lwork = 27*actstrlen
!  allocate(isuppz(2*actstrlen))
!  allocate(work(lwork))
!  allocate(iwork(liwork))
!  allocate(eigvec( actstrlen, actstrlen ))
!  allocate(eigval( actstrlen ))
!
!  call dsyevr( jobz, rnge, uplo, actstrlen, hammat, actstrlen, vl, vu, il, &
!    iu, abstol, m, eigval, eigvec, actstrlen, isuppz, work, lwork, iwork, liwork, &
!    info )
!  print *, eigval(1)
!
!  print *, "Finished"
!! Deallocate arrays
!  deallocate( unitmat, hammat, isuppz, work, iwork, eigvec, eigval )
!  return
!end subroutine hv_construct
!====================================================================
!====================================================================

!> orbdiffs
! 
! Subroutine to compute the differences between two determinants
!--------------------------------------------------------------------
  subroutine orbdiffs( pstring1, pstring2, qstring1, qstring2, aelec, belec, &
    diffs )
    implicit none
    integer, intent(in)  :: aelec, belec
    integer, dimension( aelec ), intent(in) :: pstring1, pstring2
    integer, dimension( belec ), intent(in) :: qstring1, qstring2
    integer, intent(out) :: diffs

    integer :: pstdiff, qstdiff
!--------------------------------------------------------------------
! Compare pstrings
    call compstrings( pstring1, pstring2, aelec, pstdiff )
    call compstrings( qstring1, qstring2, belec, qstdiff )
! Compute diffs
    diffs = pstdiff+qstdiff
    return
  end subroutine
!====================================================================
!====================================================================
!> compstrings
!
! Subroutine to compute differences in strings
!--------------------------------------------------------------------
  subroutine compstrings( string1, string2, length, diff )
    implicit none
    integer, intent(in) :: length
    integer, dimension( length), intent(in) :: string1, string2
    integer, intent(out):: diff
    integer :: i, j, test
!--------------------------------------------------------------------
! Loop through strings
    diff = 0
    loop1: do i=1, length
      test = 0
      loop2: do j=1, length
        if ( string1(i) .eq. string2(j) ) then
          test = test + 1
        end if
      end do loop2
      if ( test .eq. 0 ) then
        diff = diff + 1
      end if
    end do loop1
    return
  end subroutine
!====================================================================
!====================================================================
!> dblexcitations
!
! real*8 function to compute matrix elements between determinants with
!  2 diff orbitals
!--------------------------------------------------------------------
  real*8 function dblexcitations( pstring1, pstring2, qstring1, qstring2, &
    aelec, belec, moints1, moints1len, moints2, moints2len )
    use detci5
    implicit none
    integer, intent(in) :: aelec, belec, moints1len, moints2len
    integer, dimension( aelec ),     intent(in) :: pstring1, pstring2
    integer, dimension( belec ),     intent(in) :: qstring1, qstring2
    real*8, dimension( moints1len ), intent(in) :: moints1
    real*8, dimension( moints2len ), intent(in) :: moints2
    integer, dimension(2,2) :: pdiffs, qdiffs
    integer :: pd, qd, PermInd1, PermInd2
!--------------------------------------------------------------------
! Find orbitals differing in alpha strings
    call stringdiffs( pstring1, pstring2, aelec, pdiffs, pd, PermInd1 )
! Find orbitals differing in beta strings
    call stringdiffs( qstring1, qstring2, belec, qdiffs, qd, PermInd2 )
    if ( pd .eq. 2 ) then
!    dblexcitations = moints2( index2e2(pstring1(pdiffs(1,1)),pstring1(pdiffs(2,1)),&
!                              pstring2(pdiffs(1,2)),pstring2(pdiffs(2,2)))) - &
!                     moints2( index2e2(pstring1(pdiffs(1,1)),pstring1(pdiffs(2,1)),&
!                              pstring2(pdiffs(2,2)),pstring2(pdiffs(1,2))))
      dblexcitations = PermInd1*(moints2( index2e2( pstring1(pdiffs(1,1)), pstring2(pdiffs(1,2)),&
                              pstring1(pdiffs(2,1)), pstring2(pdiffs(2,2)))) - &
                       moints2( index2e2( pstring1(pdiffs(1,1)), pstring2(pdiffs(2,2)),&
                              pstring1(pdiffs(2,1)), pstring2(pdiffs(1,2)))))
    else if ( qd .eq. 2 ) then
!    dblexcitations = moints2( index2e2(qstring1(qdiffs(1,1)),qstring1(qdiffs(2,1)),&
!                              qstring2(qdiffs(1,2)),qstring2(qdiffs(2,2)))) - &
!                     moints2( index2e2(qstring1(qdiffs(1,1)),qstring1(qdiffs(2,1)),&
!                              qstring2(qdiffs(2,2)),qstring2(qdiffs(1,2))))
      dblexcitations =PermInd2*( moints2( index2e2( qstring1(qdiffs(1,1)), qstring2(qdiffs(1,2)),&
                                qstring1(qdiffs(2,1)), qstring2(qdiffs(2,2)))) - &
                       moints2( index2e2( qstring1(qdiffs(1,1)), qstring2(qdiffs(2,2)),&
                              qstring1(qdiffs(2,1)), qstring2(qdiffs(1,2)))))
    else
!     dblexcitations = moints2( index2e2(pstring1(pdiffs(1,1)),qstring1(qdiffs(1,1)),&
!                              pstring2(pdiffs(1,2)),qstring2(qdiffs(1,2))))
!     dblexcitations = moints2( index2e2(pstring1(pdiffs(1,1)),qstring1(qdiffs(1,1)),&
!                              pstring2(pdiffs(1,2)),qstring2(qdiffs(1,2))))  - &
!                      moints2( index2e2(pstring1(pdiffs(1,1)),qstring1(qdiffs(1,1)),&
!                              qstring2(qdiffs(1,2)),pstring2(pdiffs(1,2))))
!    dblexcitations = moints2( index2e2(pstring1(pdiffs(1,1)),pstring2(pdiffs(1,2)),&
!                              qstring1(qdiffs(1,1)),qstring2(qdiffs(1,2)))) - &
!                     moints2( index2e2(pstring1(pdiffs(1,1)),qstring2(qdiffs(1,2)),&
!
      dblexcitations = PermInd1*PermInd2*( moints2( index2e2( pstring1(pdiffs(1,1)),pstring2(pdiffs(1,2)), &
                                qstring1(qdiffs(1,1)), qstring2(qdiffs(1,2)))))
    end if
  end function
!====================================================================
!====================================================================
!> stringdiffs
!
! Subroutine to find difference between two strings and return the 
!  differing orbitals
!--------------------------------------------------------------------
  subroutine stringdiffs( string1, string2, length, diff_mat, diff_num, PermInd )
    implicit none
    integer, intent(in)                       :: length
    integer, dimension( length ), intent(in)  :: string1, string2
    integer, dimension( length )              :: TempString
    integer, dimension(2,2), intent(out)      :: diff_mat
    integer, intent(out)                      :: diff_num , PermInd
    integer                                   :: i, j, l
    integer                                   :: test, eps1, esp2, DUMMY
!--------------------------------------------------------------------
    diff_num = 0
    l = 1
    loopa: do i=1, length
      test = 0
      loopb: do j=1, length
        if ( string1(i) .eq. string2(j) ) then
          test = test + 1
        end if
      end do loopb
      if ( test .eq. 0 ) then
        diff_mat(l,1) = i
        l = l + 1
        diff_num = diff_num + 1
      end if
    end do loopa
    l=1
    do i=1, length
      test = 0
      do j=1, length
        if ( string2(i) .eq. string1(j) ) then
          test = test + 1
        end if
      end do
      if ( test .eq. 0 ) then
        diff_mat(l,2) = i
        l=l+1
      end if
    end do
    ! Replace orbital with excitation to get permutation index
    TempString = string1
    if ( diff_num .eq. 1 ) then
            call singrepinfo( TempString, length, string2( diff_mat(1,2) ), &
                    diff_mat(1,1), 0, PermInd, DUMMY ) 
    else if ( diff_num .eq. 2 ) then ! Should not be necessary to test again
            call doublerepinfo( TempString, length, string2(diff_mat(1,2) ),&
                    diff_mat(1,1), string2(diff_mat(2,2)), diff_mat(2,1), &
                    0, PermInd, DUMMY )
    end if
    
    return
  end subroutine
!====================================================================
!====================================================================
!> singlexcitations
!
! real*8 function to compute single excitations
!--------------------------------------------------------------------
  real*8 function singlexcitations( pstring1, pstring2, qstring1, qstring2, &
    aelec, belec, moints1, moints1len, moints2, moints2len )
    use detci5
    implicit none
    integer, intent(in)   :: aelec, belec, moints1len, moints2len
    integer, dimension( aelec ),    intent(in) :: pstring1, pstring2     
    integer, dimension( belec ),    intent(in) :: qstring1, qstring2
    real*8,  dimension(moints1len), intent(in) :: moints1
    real*8,  dimension(moints2len), intent(in) :: moints2
    real*8 :: val
    integer :: i
    integer :: pd, qd
    integer :: PermInd1, PermInd2
    integer, dimension( 2, 2 ) :: pdiffs, qdiffs
!--------------------------------------------------------------------
! Find orbitals differing in alpha strings
    call stringdiffs( pstring1, pstring2, aelec, pdiffs, pd , PermInd1)
! Find orbitals differing in beta strings
    call stringdiffs( qstring1, qstring2, belec, qdiffs, qd , PermInd2)
! Test which string has excitation
    val = 0d0
    if ( pd .eq. 1 ) then
      val = moints1( ind2val(pstring1(pdiffs(1,1)), pstring2(pdiffs(1,2))))
    !  print *, "val=",val
      do i=1, aelec
        if ( pstring1(i) .ne. pstring1(pdiffs(1,1)) ) then
          val = val + moints2( index2e2( pstring1(i), pstring1(i),           &
                      pstring1(pdiffs(1,1)), pstring2(pdiffs(1,2)) ) ) -     &
                      moints2( index2e2( pstring1(i), pstring1(pdiffs(1,1)), &
                      pstring1(i), pstring2(pdiffs(1,2))))
        end if
      end do
    !  print *, "val=",val
      do i=1, belec
        val = val + moints2( index2e2( qstring1(i), qstring1(i), &
                    pstring1(pdiffs(1,1)), pstring2(pdiffs(1,2)) ) ) !-       &
!                  moints2( index2e2( qstring1(i), pstring1(pdiffs(1,1)),   &
!                  qstring1(i), pstring2(pdiffs(1,2)) ) )
      end do
      val = PermInd1*val
    !  print *, "val=",val
    else if ( qd .eq. 1 ) then
      val = moints1( ind2val(qstring1(qdiffs(1,1)), qstring2(qdiffs(1,2))))
      do i=1, belec
        if ( qstring1(i) .ne. qstring1(qdiffs(1,1)) ) then
          val = val + moints2( index2e2( qstring1(i), qstring1(i),           &
                      qstring1(qdiffs(1,1)), qstring2(qdiffs(1,2)))) -       &
                      moints2( index2e2( qstring1(i), qstring1(qdiffs(1,1)), &
                      qstring1(i), qstring2(qdiffs(1,2))))
        end if
      end do
      do i=1, aelec
        val = val + moints2( index2e2( pstring1(i), pstring1(i), &
                  qstring1(qdiffs(1,1)), qstring2(qdiffs(1,2)) ) ) !-       &
!                  moints2( index2e2( pstring1(i), qstring1(qdiffs(1,1)),   &
!                  pstring1(i), qstring2(qdiffs(1,2)) ) )
      end do
      val = PermInd2*val
    end if
    singlexcitations = val
  end function
!====================================================================
!====================================================================
!>
!
!
!--------------------------------------------------------------------
  real*8 function diagonal_mat( pstring1, qstring1,  aelec, &
                       belec, moints1, moints1len, moints2, moints2len )
    use detci5
    implicit none
    integer, intent(in) :: belec, aelec, moints1len, moints2len
    integer, dimension( aelec ),    intent(in) :: pstring1
    integer, dimension( belec ),    intent(in) :: qstring1
    real*8,  dimension(moints1len), intent(in) :: moints1
    real*8,  dimension(moints2len), intent(in) :: moints2
    integer :: i, j
    real*8  :: val
!--------------------------------------------------------------------
! Loop over alpha string
    val = 0d0
! 1-e contribution
    do i=1, aelec
      val = val + moints1(ind2val(pstring1(i),pstring1(i)))
    end do
! 2-e contribution
    do i=1, aelec
      do j=i, aelec
        val = val + moints2( index2e2( pstring1(i), pstring1(i), &
                    pstring1(j), pstring1(j))) -                 &
                    moints2( index2e2( pstring1(i), pstring1(j), &
                    pstring1(i), pstring1(j)))
      end do
    end do
! Loop over beta string
! 1-e contribution
    do i=1, belec
      val = val + moints1(ind2val(qstring1(i), qstring1(i)))
    end do
! 2-e contribution
    do i=1, belec
      do j=i, belec
        val = val + moints2( index2e2( qstring1(i), qstring1(i), &
                    qstring1(j), qstring1(j))) -                 &
                    moints2( index2e2( qstring1(i), qstring1(j), &
                    qstring1(i), qstring1(j)))
      end do
    end do
! Alpha and beta 2-e contribution
    do i=1, aelec
      do j=1, belec
        val = val + moints2( index2e2( pstring1(i), pstring1(i), &
                    qstring1(j), qstring1(j)))
      end do
    end do
    diagonal_mat = val
  end function
!====================================================================
!====================================================================
!====================================================================
!> exp_construct
!
! Subroutine to explicitly construct H by finding value of each matrix
!  element.
!--------------------------------------------------------------------
  subroutine exp_construct( moints1, moints1len, moints2, moints2len, & 
    cidim, aelec, belec, orbitals, determs, hamiltonian )
    implicit none
    integer, intent(in) :: moints1len, moints2len, cidim, aelec, belec, &
                         orbitals
    real*8,  dimension( moints1len ), intent(in) :: moints1
    real*8,  dimension( moints2len ), intent(in) :: moints2
    integer, dimension( cidim ), intent(in)      :: determs
    real*8,  dimension( cidim, cidim ), intent(out) :: hamiltonian
    integer :: i, j

!--------------------------------------------------------------------
! Construct hamiltonian
    do i=1, cidim
      do j=1, cidim
     !   if ( i .eq. 1 .and. j .eq. 211 ) then
     !     print *, " **************** HERE ************"
     !   end if
        hamiltonian(j,i) = ham_element( determs(j), determs(i), moints1,    &
                           moints1len, moints2, moints2len, aelec,   &
                           belec, orbitals)
      end do
    end do
    return
  end subroutine exp_construct
!======================================================================
!======================================================================
!> ham_element
!
! real*8 function to compute hamiltonian element(i,j)
!--------------------------------------------------------------------
  real*8 function ham_element( ind1, ind2, moints1, moints1len, moints2, &
    moints2len, aelec, belec, orbitals)
    use detci1
    use detci2
    implicit none
    integer, intent(in) :: ind1, ind2, moints1len, moints2len, &
                           aelec, belec, orbitals
    real*8, dimension( moints1len ), intent(in) :: moints1
    real*8, dimension( moints2len ), intent(in) :: moints2
    integer :: p1, q1, p2, q2
    integer, dimension( aelec ) :: pstring1, pstring2
    integer, dimension( belec ) :: qstring1, qstring2

    integer :: diffs, adets, bdets
!--------------------------------------------------------------------
    adets = binom( orbitals, aelec )
    bdets = binom( orbitals, belec )
! Find determinant string indices for ind1 and ind2
    call k2indc( ind1, belec, orbitals, p1, q1 )
    call k2indc( ind2, belec, orbitals, p2, q2 )
! Find respective strings for p1, q1, p2, q2
    call genorbstring( p1, aelec, orbitals, adets, pstring1 )
    call genorbstring( p2, aelec, orbitals, adets, pstring2 )
    call genorbstring( q1, belec, orbitals, bdets, qstring1 )
    call genorbstring( q2, belec, orbitals, bdets, qstring2 )
! Test differences in strings. If > 2 orbitals, element is 0
    call orbdiffs( pstring1, pstring2, qstring1, qstring2, aelec, belec, &
                   diffs )
    if ( diffs .gt. 2 ) then
      ham_element = 0d0
    else if ( diffs .eq. 2 ) then
      ham_element = dblexcitations( pstring1, pstring2, qstring1, qstring2, aelec, &
                           belec, moints1, moints1len, moints2, moints2len )
    else if ( diffs .eq. 1 ) then
      ham_element =  singlexcitations( pstring1, pstring2, qstring1, qstring2, aelec, &
                           belec, moints1, moints1len, moints2, moints2len )
    else 
      ham_element =  diagonal_mat( pstring1, qstring1, aelec, &
                           belec, moints1, moints1len, moints2, moints2len )
    end if
  end function
!======================================================================
!======================================================================

!====================================================================
!====================================================================
!>ham_element_diag
!
! Subroutine to compute diagonal elements...see above for input details
!--------------------------------------------------------------------
  real*8 function ham_element_diag( ind1, moints1, moints1len, moints2, &
    moints2len, aelec, belec, orbitals)
    use detci1
    use detci2
    implicit none
    integer, intent(in) :: ind1, moints1len, moints2len, &
                         aelec, belec, orbitals
    real*8, dimension( moints1len ), intent(in) :: moints1
    real*8, dimension( moints2len ), intent(in) :: moints2
    integer :: p1, q1, p2, q2
    integer, dimension( aelec ) :: pstring1, pstring2
    integer, dimension( belec ) :: qstring1, qstring2

    integer :: diffs, adets, bdets
!--------------------------------------------------------------------
    adets = binom( orbitals, aelec )
    bdets = binom( orbitals, belec )
! Find determinant string indices for ind1 and ind2
    call k2indc( ind1, belec, orbitals, p1, q1 )
    call k2indc( ind1, belec, orbitals, p2, q2 )
! Find respective strings for p1, q1, p2, q2
    call genorbstring( p1, aelec, orbitals, adets, pstring1 )
    call genorbstring( p2, aelec, orbitals, adets, pstring2 )
    call genorbstring( q1, belec, orbitals, bdets, qstring1 )
    call genorbstring( q2, belec, orbitals, bdets, qstring2 )
! Test differences in strings. If > 2 orbitals, element is 0
    ham_element_diag = diagonal_mat( pstring1, qstring1, aelec, &
                           belec, moints1, moints1len, moints2, moints2len )
  end function ham_element_diag
!====================================================================
!====================================================================
end module
