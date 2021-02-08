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
;		TIME:		Variable holding the time array in seconds.
;
; RETURN VALUE:	Time-averaged DEM in units of 
;
; KEYWORDS:
;		DURATION:	Duration in seconds.  Default 10k
;		NFLARES:	Number of flares in a train.  Average over last flare only.  Default 1
;		HEAT0:		Flare heating amplitude (erg cm^-3 s^-1).  Default 0.01
;		LENGTH:		Loop half length (cm).  Default 7.5e9 cm
;		HEAT_BKG:	Low level constant background heating, in (erg cm^-3 s^-1).  Default 1.e-6
;		FLARE_DUR:	Total duration of flare in seconds; symmetric triangular profile.
;
;	KEYWORDS (OUTPUT) -- 
;		dem_cm5_cor		Coronal DEM
;               dem_cm5_tr              Transition Region DEM
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
;2015-nov-12	LG	Wrote routine
;2016-aug-10    AJM     Put in correct use of length keyword
;2016-sep-24    AJM     Added TR keyword. Changed keyword names 
;2017-feb-02    AJM     Changed time keyword, code description
;-


FUNCTION RUN_EBTEL, time=time, duration=duration, t_heat=t_heat, nFlares=nFlares, $
                    heat0=heat0, heat_bkg=heat_bkg, heat_array=heat, length=length, te=te, $
                    dens=dens, p=p, v=v, c11=c11, logtdem=logtdem, stop=stop, $
                    dem_cm5_cor=dem_cm5_cor, dem_cm5_tr=dem_cm5_tr, _extra=_extra
	
	default, duration, long(10000)
	default, t_heat, 500
	default, nflares, 1
	default, heat0, 0.01
	default, heat_bkg, 1.e-6
	default, length, 7.5e9

	nTime = duration*nFlares
	time = findgen(nTime)		;  define time array 
	heat = fltarr(duration)		;  define corresponding heating array
	for i = 0, t_heat/2 do heat(i) = heat0*time(i)/(t_heat/2)  ;  triangular profile rise
	for i = t_heat/2+1, t_heat do heat(i) = heat0*(t_heat - time(i))/(t_heat/2)  ;  decay
	heat = heat + heat_bkg
	
	if keyword_set(stop) then stop

	resolve_routine, 'ebtel2', /compile
	ebtel2, time, heat, length, te, dens, p, v, ta, na, pa, c11, dem_tr, dem_cor, logtdem, _extra=_extra

	dem = dem_cor + dem_tr  ;  total differential emission measure (corona plus footpoint)
	dem_cm5 = double( average( dem, 1 ) )		; time averaged DEM
	dem_cm5_cor = double( average( dem_cor, 1 ) )	; time averaged DEM, CORONA ONLY!
        dem_cm5_tr = double ( average( dem_tr, 1 ) )    ; time averaged DEM, TR ONLY!

	return, dem_cm5
	
END
