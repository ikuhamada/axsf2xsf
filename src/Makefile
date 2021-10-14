.SUFFIXES:.o .f .f90

F90=gfortran
F90FLAGS=-O2

OBJS=axsf2xsf.o

PROG=axsf2xsf

$(PROG): $(OBJS)
	$(F90) $(F90FLAGS) $(OBJS) -o $@

.f90.o:
	$(F90) $(F90FLAGS) -c $<
clean:
	rm *.o *.mod

cleanup:
	rm -f *.o *.mod $(PROG)
