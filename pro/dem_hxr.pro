;+
; NAME: DEM_HXR
;
; PURPOSE:
;  	Compute X-ray thermal flux >2 keV for a differential emission measure vs temperature set.
;		The routine calls F_VTH, which uses the HXR emissions in the CHIANTI database.
;		F_VTH default provides both continuum and lines, but F_VTH keywords can be 
;		passed through if this is not desired.
;
; INPUT:
;		LOGTE:	log(T) temperature array (temperature measured in Kelvin)
;		DEM:		Differential emission measure in units of cm^-5 K^-1 corresponding logte array
;		AREA:		Area in cm^2 of the emitting region
;
;	OUTPUT:
;		ENERGY:	Midpoints of energy bins
;
; KEYWORDS:
;
; HISTORY:
;		2015-nov-12		LG	Wrote routine
;-

FUNCTION	DEM_HXR, logte, dem, area, energy, _extra=_extra

	; Various styles of energy arrays for use later
	energy_edges  = findgen(1000)/50.+2
	energy_edges2 = get_edges( energy_edges, /edges_2 )			; needed format for f_vth
	energy_mid    = get_edges( energy_edges, /mean )
	energy_wid		= average( get_edges( energy_edges, /width ) )
	nEn = n_elements( energy_mid )

	; Compute EM in cm^-3 by multiplying DEM by temperature bin width and emitting area.
	dlogt = average( get_edges( logte, /width ) )		; binwidth assuming evenly-spaced logT bins
	em_cm3 = dem * area  * alog(10.) * 10.^logte * dlogt		; EM in each T bin

	; Convert variables to units needed for F_VTH.  EM in 10^49 cm^-3, T in keV
	em_49 = em_cm3/1.d49
	t_keV = 10.^logte / 11.6 / 1.d6		; 1/11.6 is Boltzmann constant in keV/MK
	nT   = n_elements(logte)
	; Compute HXR flux for each T, EM pair.
	flux = fltarr( nT, nEn )
	for i=0, nT-1 do flux[i,*] = f_vth( energy_edges2, [em_49[i], t_keV[i], 1], _extra=_extra )
	flux[ where( finite(flux) eq 0 ) ] = 0.

	energy=energy_mid

	return, flux
	
END
