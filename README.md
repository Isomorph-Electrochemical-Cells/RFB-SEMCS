# SEMCS

Simplified volume-averaged Electrode Model for the use in Continuum Scale RFB models.

The SEMCS model allows evaluating the effective transport parameters relevant for continuum-scale descriptions of porous electrodes in flow batteries. Specifically, SEMCS is a Kriging-based surrogate model for fast evaluations of the effective parameters. 

The model is constructed with numerically computed effective parameters using the volume averaging method.

SEMCS constructs a Kriging-based model that maps the dimensionless parameters
- porosity,
- Peclet number,
- kinetic number,
to the effective transport parameters
- permeability,
- effective total dispersion (including effective diffusion),
- effective kinetic number.

Main contributors: R. Schaerer & J. Wlodarczyk