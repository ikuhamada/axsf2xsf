 program main
!***********************************************************************
!
! A program to convert animated xsf (axsf) file into separate xsf files
! Written by Ikutaro Hamada
!
!***********************************************************************
 implicit none
! ... Number of atoms ...
 integer :: natom
! ... Number of steps ...
 integer :: nstep
! ... Fortran I/O ...
 integer :: stdin = 05, stdout = 06, stderr = 00
 integer :: input, iout, ios, ierr
 character(len=256) :: input_file, output_file
! ... Command line arguments ...
 integer :: iarg, iargc, narg, marg
 character(len=256) :: arg
! ... Control parameters ...
 integer :: idebug = 0
! ... Counter ...
 integer :: ii, jj, kk, iatom, istep, jstep
! ... Structural information ...
 integer :: is_crystal = 0, is_prim = 0, is_conv = 0
! ... Variables
 integer            :: len
 integer            :: nline
 integer            :: idummy
 character(len=3)   :: c3
 character(len=256) :: str, str2
 character(len=256) :: prefix, suffix
 logical            :: fexist
!***********************************************************************
!
!... set default values ...
!
 input = stdin
 iout  = 10
 prefix = ''
!
!... read arguments ...
!
 narg = iargc()
 iarg = 0
 if( narg == 0 )then
   write( stderr, '(a)' )'No arguments.'
   stop
 endif
 do while( iarg < narg )
   iarg = iarg + 1
   call getarg( iarg, arg )
   select case( trim(arg) )
     case( '-i', '-inp', '--input' )
       iarg = iarg + 1
       call getarg( iarg, arg )
       input_file = arg
     case( '-p', '--prefix' )
       iarg = iarg + 1
       call getarg( iarg, arg )
       prefix = arg
     case( '-v', '--verbose', '--debug' )
       idebug = 1
     case( '-h', '--help' )
       write( stderr, '(a,a)' ) &
&      'Usage: axsf2xsf',&
&      ' (-i|-inp|--input) [AXSF FILE] (-p|--prefix) [PREFIX]'
     case default
       input_file = arg
   end select
 enddo
!
! ... Set the input file and prefix ...
!
 input_file = arg
 len = 0
 len = index( arg, '.axsf' )
 if( len == 0 )then
   write( stderr, '(a)' ) "Suffix for the input file should be '.axsf'."
   stop
 endif 
 if( prefix == '' )then
   prefix = arg( 1 : len - 1 )
 endif
 if( idebug > 0 )then
   write( stderr, '(a,a)' ) ' input file : ', trim(input_file)
   write( stderr, '(a,a)' ) ' prefix     : ', trim(prefix)
 endif
!
! ... Check the input file ...
!
 inquire( file = input_file, exist=fexist )
 if( .not. fexist )then
   write( stderr, '(a,a)' ) trim( input_file ), ' not found.'
   stop
 endif
!
! ... Open the input file ...
!
 open( input, file=input_file, status='old' )
!
! ... Read the input file ...
!
 read( input, '(a)' ) str
 len = index( str, ' ' )
 str = str( len : ); str = adjustl( str )
 read( str, * ) nstep
 read( input, '(a)' )str
 if( trim(str) == 'CRYSTAL' )then
   is_crystal = 1
 else
   is_crystal = 0
   backspace( input )
 endif
 read(input,'(a)')str
 if( trim(str) == 'PRIMVEC' )then
   is_prim = 1
   do ii = 1, 3
     read( input, '(a)' )str
   enddo
 else
   backspace( input )
 endif
 read( input, '(a)' )str
 if(trim(str) == 'CONVVEC')then
   is_conv = 1
   do ii = 1, 3
     read( input, '(a)' )str
   enddo
 else
   backspace( input )
 endif
 if( is_crystal == 1 )then
   do istep = 1, nstep
     read( input, '(a)' ) str
     read( input, * ) natom, idummy
     do iatom = 1, natom
       read( input, '(a)' ) str
     enddo
   enddo
 else
   nline = 0
   do
     read( input, '(a)', iostat = ios ) str
     if( ios /= 0 )then
       exit
     endif
     nline = nline + 1
   enddo 
   natom = ( nline / nstep ) - 1
 endif
 if( idebug > 0 )then
   if( is_crystal == 1 )then
     write( stderr, '(a)')' system is crystal.'
   endif
   if( is_prim == 1 )then
     write( stderr, '(a)')' primitive lattice vectors'
   endif
   if( is_conv == 1 )then
     write( stderr, '(a)')' conventional lattice vectors'
   endif
 endif
!
! ... Read the input file again ...
!
 do istep = 1, nstep
   rewind( input )
   write( c3, '(i3.3)' )istep
   output_file = trim(prefix)//'_'//trim(c3)//'.xsf'
   if( idebug > 0 )then
     write( stderr, '(a)' )' generating ',trim(output_file)
   endif
   open( iout, file = output_file, status = 'unknown')
   read( input, '(a)' ) str ! # of steps
   read( input, '(a)' ) str ! "CRYSTAL"
   str = adjustl( str )
   if( trim( str ) == 'CRYSTAL' )then
     write( iout, '(a)' ) trim(str)
   else
     backspace( input )
   endif
   if( is_prim == 1 )then
     do ii = 1, 4
       read( input, '(a)' ) str
       write( iout, '(a)' ) trim(str)
     enddo
   endif
   if( is_conv == 1 )then
     do ii = 1, 4
       read( input, '(a)' ) str
       write( iout, '(a)' ) trim( str )
     enddo
   endif
   do jstep = 1, nstep
     if( jstep == istep )then
       if( is_crystal == 0 )then
         read( input, '(a)' ) str
         write( iout, '(a)' ) trim( str )
         do iatom = 1, natom
           read( input, '(a)' ) str
           write( iout, '(a)' ) trim( str )
         enddo
       elseif( is_crystal == 1 )then
         do ii = 1, 2
           read( input, '(a)' ) str
           write( iout, '(a)' ) trim( str )
         enddo
         do iatom = 1, natom
           read( input, '(a)' ) str
           write( iout, '(a)' ) trim( str )
         enddo
       endif
     else
       if( is_crystal == 0 )then
         read( input, '(a)' ) str
         do iatom = 1, natom
           read( input, '(a)' ) str
         enddo
       elseif( is_crystal == 1 )then
         do ii = 1, 2
           read( input, '(a)' ) str
         enddo
         do iatom = 1, natom
           read( input, '(a)' ) str
         enddo
       endif
     endif
   enddo
   close( iout )
 enddo
 close(iout)
!***********************************************************************
 stop
 end
