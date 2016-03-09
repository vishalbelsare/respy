MODULE robufort_constants

	!/*	setup	*/

    IMPLICIT NONE
    
!------------------------------------------------------------------------------- 
!	Parameters and Types
!------------------------------------------------------------------------------- 

    INTEGER, PARAMETER :: our_int   = selected_int_kind(9)
    INTEGER, PARAMETER :: our_sgle  = selected_real_kind(6,37)
    INTEGER, PARAMETER :: our_dble  = selected_real_kind(15,307)

    INTEGER(our_int), PARAMETER :: zero_int     = 0_our_int
    INTEGER(our_int), PARAMETER :: one_int      = 1_our_int
    INTEGER(our_int), PARAMETER :: two_int      = 2_our_int
    INTEGER(our_int), PARAMETER :: three_int    = 3_our_int
    INTEGER(our_int), PARAMETER :: four_int     = 4_our_int

    REAL(our_dble), PARAMETER :: tiny_dble      = 1.0e-20_our_dble
    REAL(our_dble), PARAMETER :: zero_dble      = 0.00_our_dble
    REAL(our_dble), PARAMETER :: quarter_dble   = 0.25_our_dble
    REAL(our_dble), PARAMETER :: half_dble      = 0.50_our_dble
    REAL(our_dble), PARAMETER :: one_dble       = 1.00_our_dble
    REAL(our_dble), PARAMETER :: two_dble       = 2.00_our_dble
    REAL(our_dble), PARAMETER :: three_dble     = 3.00_our_dble
    REAL(our_dble), PARAMETER :: four_dble      = 4.00_our_dble

    REAL(our_dble), PARAMETER :: one_hundred_dble  = 100_our_dble
    REAL(our_dble), PARAMETER :: two_hundred_dble  = 200_our_dble
    REAL(our_dble), PARAMETER :: four_hundred_dble = 400_our_dble

    REAL(our_dble), PARAMETER :: pi        = 3.141592653589793238462643383279502884197_our_dble
    
    ! Variables that need to be aligned across FORTRAN and PYTHON 
    ! implementations.
    INTEGER(our_int), PARAMETER :: MISSING_INT  = -99_our_int

    REAL(our_dble), PARAMETER :: MISSING_FLOAT   = -99_our_dble

    REAL(our_dble), PARAMETER :: HUGE_FLOAT      = 1.0e10_our_dble
    REAL(our_dble), PARAMETER :: TINY_FLOAT      = 1e-20_our_dble

    ! Interpolation
    REAL(our_dble), PARAMETER :: interpolation_inadmissible_states = -50000.00_our_dble


!*******************************************************************************
!*******************************************************************************
END MODULE 