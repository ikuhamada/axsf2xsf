# AXSF2XSF

`axsf2xsf` is a program/script to split an animated XSF (AXSF) file into separate XSF files

## Build

To build the fortran program, go to the `src` directory, edit Makefile according to the user's environment, and type `make`

The script `axsf2xsf.sh` can be used as is.

## Usage

First, set an appropriate command line search path to `axsf2xsf` and/or `axsf2xsf.sh`.
To use the fortran version of ``axsf2xsf``, after setting an appropriate command line search path to `axsf2xsf`, type

```
axsf2xsf [AXSF file]
```

For more options, type

```
axsf2xsf -h
```

To use the bash version of `axsf2xsf`, type

```
axsf2xsf.sh [AXSF file]
```

## Author
Ikutaro Hamada
