;+
; NAME: RUN_EBTEL
;
; PURPOSE:
;  	This is just a wrapper for the EBTEL2 procedure.  The wrapper does nothing; its only
;		purpose is to be able to easily loop through many parameters without carrying around
;		much code.
;
; INPUT:	None.  All parameters are input as keywords.
;
; OUTPUT:
;		TIME:			Variable holding the time array in seconds.
;
; RETURN VALUE:	Time-averaged DEM in units of 
;
; KEYWORDS:
;		DURATION:		Duration in seconds.  Default 10k
;		NFLARES:		Number of flares in a train.  Only the last flare is analyzed.  Default 1
;		HEAT0:			Flare heating amplitude (erg cm^-3 s^-1).  Default 0.01
;		LENGTH:			Loop half length (cm).  Default 7.5e9 cm
;		HEAT_BKG		Low level constant background heating, in (erg cm^-3 s^-1).  Default 1.e-6
;		FLARE_DUR		Total duration of flare in seconds, with symmetric, triangular rise and decay.
;
;	KEYWORDS (OUTPUT) -- 
;		avg_dem_cm5_cor		Just like the return value but only for the corona.
;
;		Others are all outputs ferried straight from EBTEL output:

;   te = temperature array corresponding to time (note slight name difference)
;   dens = electron number density array (cm^-3) (note naming difference)
;   p = pressure array (dyn cm^-2)
;   v = velocity array (cm s^-1) (r4 * velocity at base of corona)
;   c11 = C1 (or r3 in this code)
;   logtdem = logT array corresponding to dem_tr and dem_cor
;		
; HISTORY:
;		2015-nov-12		LG	Wrote routine
;-


FUNCTION	RUN_EBTEL, time, duration=duration, t_heat=t_heat, nFlares=nFlares, $
										 heat0=heat0, heat_bkg, length, te=te, dens=dens, p=p, v=v, $
										 c11=c11, avg_dem_cm5_cor=avg_dem_cm5_cor, logtdem=logtdem, _extra = _extra
	
	default, duration, long(10000)
	default, t_heat, 500
	default, nflares, 1
	default, heat0, 0.01
	default, heat_bkg, 1.e-6
	default, length, 7.5e9

	nTime = duration*nFlares
	time = findgen(nTime)		;  define time array 
	heat = fltarr(duration)		;  define corresponding heating array
	for i = 0, t_heat/2 do heat(i) = heat0*time(i)/250.  ;  triangular profile rise
	for i = t_heat/2+1, t_heat do heat(i) = heat0*(t_heat - time(i))/t_heat/2  ;  decay
	heat = heat + heat_bkg

	resolve_routine, 'ebtel2', /compile
	ebtel2, time, heat, length, te, dens, p, v, ta, na, pa, c11, dem_tr, dem_cor, logtdem, _extra=_extra

	dem = dem_cor + dem_tr  ;  total differential emission measure (corona plus footpoint)
	avg_dem_cm5 = double( average( dem, 1 ) )			; time averaged DEM
	avg_dem_cm5_cor = double( average( dem_cor, 1 ) )			; time averaged DEM, CORONA ONLY!

	return, avg_dem_cm5
	
END
