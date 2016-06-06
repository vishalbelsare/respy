MODULE bfgs_function


	USE shared_constants

	IMPLICIT NONE

CONTAINS
	

	FUNCTION vabs(v)
	REAL(our_dble), DIMENSION(:), INTENT(IN) :: v
	REAL(our_dble) :: vabs
	vabs=sqrt(dot_product(v,v))
	END FUNCTION vabs

	SUBROUTINE nrerror(string)
	CHARACTER(LEN=*), INTENT(IN) :: string
	write (*,*) 'nrerror: ',string
	STOP 'program terminated by nrerror'
	END SUBROUTINE nrerror


	FUNCTION outerprod(a,b)
	REAL(our_dble), DIMENSION(:), INTENT(IN) :: a,b
	REAL(our_dble), DIMENSION(size(a),size(b)) :: outerprod
	outerprod = spread(a,dim=2,ncopies=size(b)) * &
		spread(b,dim=1,ncopies=size(a))
	END FUNCTION outerprod







!BL
	SUBROUTINE unit_matrix(mat)
	REAL(our_dble), DIMENSION(:,:), INTENT(OUT) :: mat
	INTEGER(our_int) :: i,n
	n=min(size(mat,1),size(mat,2))
	mat(:,:)=0.0_our_dble
	do i=1,n
		mat(i,i)=1.0_our_dble
	end do
	END SUBROUTINE unit_matrix

	SUBROUTINE dfpmin(p,gtol,iter,fret,func,dfunc)
	INTEGER(our_int), INTENT(OUT) :: iter
	REAL(our_dble), INTENT(IN) :: gtol
	REAL(our_dble), INTENT(OUT) :: fret
	REAL(our_dble), DIMENSION(:), INTENT(INOUT) :: p
	INTERFACE
		FUNCTION func(p)
		USE shared_constants
		IMPLICIT NONE
		REAL(our_dble), DIMENSION(:), INTENT(IN) :: p
		REAL(our_dble) :: func
		END FUNCTION func
!BL
		FUNCTION dfunc(p)
		USE shared_constants
		IMPLICIT NONE
		REAL(our_dble), DIMENSION(:), INTENT(IN) :: p
		REAL(our_dble), DIMENSION(size(p)) :: dfunc
		END FUNCTION dfunc
	END INTERFACE
	INTEGER(our_int), PARAMETER :: ITMAX=200
	REAL(our_dble), PARAMETER :: STPMX=100.0_our_dble,EPS=epsilon(p),TOLX=4.0_our_dble*EPS
	INTEGER(our_int) :: its
	LOGICAL :: check
	REAL(our_dble) :: den,fac,fad,fae,fp,stpmax,sumdg,sumxi
	REAL(our_dble), DIMENSION(size(p)) :: dg,g,hdg,pnew,xi
	REAL(our_dble), DIMENSION(size(p),size(p)) :: hessin
	fp=func(p)
	g=dfunc(p)
	call unit_matrix(hessin)
	xi=-g
	stpmax=STPMX*max(vabs(p),real(size(p),our_dble))
	do its=1,ITMAX
		iter=its
		call lnsrch(p,fp,g,xi,pnew,fret,stpmax,check,func)
		fp=fret
		xi=pnew-p
		p=pnew

		if (maxval(abs(xi)/max(abs(p),1.0_our_dble)) < TOLX) RETURN
		dg=g
		g=dfunc(p)
		den=max(fret,1.0_our_dble)
		if (maxval(abs(g)*max(abs(p),1.0_our_dble)/den) < gtol) RETURN
		dg=g-dg
		hdg=matmul(hessin,dg)
		fac=dot_product(dg,xi)
		fae=dot_product(dg,hdg)
		sumdg=dot_product(dg,dg)
		sumxi=dot_product(xi,xi)
		if (fac**2 > EPS*sumdg*sumxi) then
			fac=1.0_our_dble/fac
			fad=1.0_our_dble/fae
			dg=fac*xi-fad*hdg
			hessin=hessin+fac*outerprod(xi,xi)-&
				fad*outerprod(hdg,hdg)+fae*outerprod(dg,dg)
		end if
		xi=-matmul(hessin,g)
	end do
	call nrerror('dfpmin: too many iterations')
	END SUBROUTINE dfpmin

	SUBROUTINE lnsrch(xold,fold,g,p,x,f,stpmax,check,func)
	REAL(our_dble), DIMENSION(:), INTENT(IN) :: xold,g
	REAL(our_dble), DIMENSION(:), INTENT(INOUT) :: p
	REAL(our_dble), INTENT(IN) :: fold,stpmax
	REAL(our_dble), DIMENSION(:), INTENT(OUT) :: x
	REAL(our_dble), INTENT(OUT) :: f
	LOGICAL, INTENT(OUT) :: check
	INTERFACE
		FUNCTION func(x)
		USE shared_constants
		IMPLICIT NONE
		REAL(our_dble) :: func
		REAL(our_dble), DIMENSION(:), INTENT(IN) :: x
		END FUNCTION func
	END INTERFACE
	REAL(our_dble), PARAMETER :: ALF=1.0e-4_our_dble,TOLX=epsilon(x)
	INTEGER(our_int) :: ndum
	REAL(our_dble) :: a,alam,alam2,alamin,b,disc,f2,fold2,pabs,rhs1,rhs2,slope,&
		tmplam
	ndum=size(g)
	check=.false.
	pabs=vabs(p(:))
	if (pabs > stpmax) p(:)=p(:)*stpmax/pabs
	slope=dot_product(g,p)
	alamin=TOLX/maxval(abs(p(:))/max(abs(xold(:)),1.0_our_dble))
	alam=1.0
	do
		x(:)=xold(:)+alam*p(:)
		f=func(x)
		if (alam < alamin) then
			x(:)=xold(:)
			check=.true.
			RETURN
		else if (f <= fold+ALF*alam*slope) then
			RETURN
		else
			if (alam == 1.0) then
				tmplam=-slope/(2.0_our_dble*(f-fold-slope))
			else
				rhs1=f-fold-alam*slope
				rhs2=f2-fold2-alam2*slope
				a=(rhs1/alam**2-rhs2/alam2**2)/(alam-alam2)
				b=(-alam2*rhs1/alam**2+alam*rhs2/alam2**2)/&
					(alam-alam2)
				if (a == 0.0) then
					tmplam=-slope/(2.0_our_dble*b)
				else
					disc=b*b-3.0_our_dble*a*slope
					if (disc < 0.0) THEN
disc = 0.001

END IF

					tmplam=(-b+sqrt(disc))/(3.0_our_dble*a)
				end if
				if (tmplam > 0.5_our_dble*alam) tmplam=0.5_our_dble*alam
			end if
		end if
		alam2=alam
		f2=f
		fold2=fold
		alam=max(tmplam,0.1_our_dble*alam)
	end do
	END SUBROUTINE lnsrch

END MODULE