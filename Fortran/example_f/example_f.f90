module examples

use de
use detypes

implicit none

 integer, parameter :: param_dim = 5 !dimensions of parameter space

 integer, parameter :: NP=10, numgen=15, numciv=1, nDerived=2
 character (len=300) :: path='example_f/output/example'
 real(dp), parameter ::  Cr=0.9, tol = 1e-3, lambda=0.8		!0<=Cr<=1, 0<=lambda<=1
 real(dp), parameter, dimension(1) :: F=0.6			!recommend 0<F<1
 real(dp), parameter, dimension(param_dim) :: lowerbounds=(/-5.,-50.,1.,-50.,-1./)	!boundaries of parameter space
 real(dp), parameter, dimension(param_dim) :: upperbounds=(/-1.,50.,5.,50.,2./)
 real(dp), parameter, dimension(param_dim) :: ranges = upperbounds - lowerbounds

contains

!Functions to be minimized.  Assumed to be -ln(Likelihood)

real(dp) function constant(params, fcall, quit, validvector)

  real(dp), dimension(size(lowerbounds)+nDerived), intent(inout) :: params
  integer, intent(inout) :: fcall 
  logical, intent(out) :: quit
  logical, intent(in) :: validvector

  fcall = fcall + 1
  quit = .false.
  !-lnlike
  constant = 0.0_dp 
  if (.not. validvector) constant=huge(1.0_dp)
  !derived quantities (other functions of the parameters)
  params(size(lowerbounds)+1:) = [2.*params(1),params(1)+params(2)]

end function constant


real(dp) function step(params, fcall, quit, validvector)

  real(dp), dimension(size(lowerbounds)+nDerived), intent(inout) :: params
  integer, intent(inout) :: fcall
  logical, intent(out) :: quit
  logical, intent(in) :: validvector
  
  fcall = fcall + 1
  quit = .false.
  if (.not. validvector) then 
     step = huge(1.0_dp)
  else if (params(1) .gt. 0.0_dp) then
    step = 0.0_dp 
  else 
    step = 1.0_dp
  endif
  params(size(lowerbounds)+1:) = [2.0_dp*params(1),params(1)+params(2)]
  
end function step


real(dp) function linear(params, fcall, quit, validvector)

  real(dp), dimension(size(lowerbounds)+nDerived), intent(inout) :: params
  integer, intent(inout) :: fcall
  logical, intent(out) :: quit
  logical, intent(in) :: validvector
  
  fcall = fcall + 1
  quit = .false.
  if (.not. validvector) then 
     linear = huge(1.0_dp)
  else if (params(1) .gt. 0.0_dp) then
    linear = params(1) 
  else 
    linear = 0.0_dp
  endif
  params(size(lowerbounds)+1:) = [2.0_dp*params(1),params(1)+params(2)]
  
end function linear


!valid for any number of dimensions
real(dp) function gauss(params, fcall, quit, validvector)
  real(dp), dimension(size(lowerbounds)+nDerived), intent(inout) :: params
  integer, intent(inout) :: fcall
  logical, intent(out) :: quit
  logical, intent(in) :: validvector
  integer :: i

  fcall = fcall + 1
  quit = .false.

  gauss = 0.0_dp
  do i = 1, size(lowerbounds)
    gauss = gauss + params(i)*params(i)
  enddo

  if (.not. validvector) gauss = huge(1.0_dp)

  !derived quantities
  !params(size(lowerbounds)+1:) = [2.0_dp*params(1),params(1)+params(2)]

end function gauss


!valid for any number of dimensions, but with some (hard-coded) number discrete indices
real(dp) function manygauss(params, fcall, quit, validvector)
  real(dp), dimension(size(lowerbounds)+nDerived), intent(inout) :: params
  integer, intent(inout) :: fcall
  logical, intent(out) :: quit
  logical, intent(in) :: validvector
  integer, parameter, dimension(3) :: discrete = (/1,3,5/)
  integer :: i

  fcall = fcall + 1
  quit = .false.

  manygauss = 0.0_dp
  do i = 1, size(lowerbounds)
    if (.not. any(discrete .eq. i)) manygauss = manygauss + params(i)*params(i)
  enddo

  if (.not. validvector) manygauss = huge(1.0_dp)

  !derived quantities
  !params(size(lowerbounds)+1:) = [2.0_dp*params(1),params(1)+params(2)]

end function manygauss


real(dp) function spikygauss(params, fcall, quit, validvector)
  real(dp), dimension(size(lowerbounds)+nDerived), intent(inout) :: params
  integer, intent(inout) :: fcall
  logical, intent(out) :: quit
  logical, intent(in) :: validvector
  integer :: i
  real(dp) :: denominator

  fcall = fcall + 1
  quit = .false.

  spikygauss = 0.0_dp
  denominator = 0.0_dp
  do i = 1, size(lowerbounds)
    spikygauss = spikygauss + params(i)*params(i) + 1.e32*sin(params(i))*sin(params(i))
   ! denominator = denominator + sin(200*params(i)-1.)*sin(200*params(i)-1.)
  enddo

  !spikygauss = spikygauss/denominator

  if (.not. validvector) spikygauss = huge(1.0_dp)

end function spikygauss



!2-dimensional
real(dp) function rosenbrock(params, fcall, quit, validvector)
  real(dp), dimension(size(lowerbounds)+nDerived), intent(inout) :: params
  integer, intent(inout) :: fcall
  logical, intent(out) :: quit
  logical, intent(in) :: validvector

  fcall = fcall + 1
  quit = .false.
  
  rosenbrock = (1 - params(1))**2 + 100*(params(2) - params(1)**2)**2
  if (.not. validvector) rosenbrock = huge(1.0_dp)

  !derived quantities
  !params(size(lowerbounds)+1:) = [2.0_dp*params(1),params(1)+params(2)]

end function rosenbrock


!valid for any number of dimensions
real(dp) function rastrigin(params, fcall, quit, validvector)
  real(dp), dimension(size(lowerbounds)+nDerived), intent(inout) :: params
  integer, intent(inout) :: fcall
  logical, intent(out) :: quit
  logical, intent(in) :: validvector
  integer :: i
  real(dp), parameter :: pi = 4.0_dp*atan(1.0_dp)

  fcall = fcall + 1
  quit = .false.

  rastrigin = size(lowerbounds)*10 

  do i=1, size(lowerbounds)
     rastrigin = rastrigin + params(i)**2 - 10*cos(2*pi*params(i))
  end do

  if (.not. validvector) rastrigin = huge(1.0_dp)

  !derived quantities
  !params(size(lowerbounds)+1:) = [2.0_dp*params(1),params(1)+params(2)]

end function rastrigin


real(dp) function eggcarton(params, fcall, quit, validvector)
  real(dp), dimension(size(lowerbounds)+nDerived), intent(inout) :: params
  integer, intent(inout) :: fcall
  logical, intent(out) :: quit
  logical, intent(in) :: validvector
  integer :: D = size(lowerbounds)

  fcall = fcall + 1
  quit = .false.

  !slight dip at center. Needs smaller Ztolerance, tolerance in convergence (long run) or gets stuck in local minima
  !eggcarton =  0.001*(params(1)**2 + params(2)**2) - cos(params(1))*cos(params(2)) + 1

  !as used in MultiNest (-ln of formula given in paper). Parameter space should range from 0 to 10 pi
  eggcarton = -(2 + cos(0.5*params(1))*cos(0.5*params(2)))**5

  !flat. Set bndry=3 (reflective) to better explore edges
  !eggcarton = cos(params(1))*cos(params(2))

end function eggcarton



!Example prior distributions

!Flat prior distribution for all parameters
real(dp) function flatprior(X)

  real(dp), dimension(size(lowerbounds)), intent(in) :: X
  flatprior = 1.0_dp / product(ranges)

end function flatprior

end module examples


!Tester for general differential evolution
program dedriver 

  use examples

  implicit none

  call run_de(manygauss, lowerbounds, upperbounds, path, doBayesian=.false.,discrete=(/1,3,5/), &
        lambdajDE=.true., partitionDiscrete=.true., resume=.false., Ztolerance=0.1_dp, &
       removeDuplicates=.true., maxciv=1, NP=1000, bndry=3, prior=flatprior)

end program dedriver