;+
; NAME: DEM_HXR
;
; PURPOSE:
;Compute X-ray thermal flux >2 keV for a differential emission measure
;vs temperature set. The routine calls F_VTH, which uses the HXR
;emissions in the CHIANTI database. _VTH default provides both continuum and lines, but F_VTH keywords can be passed through if this is not desired.
;
; INPUT:
;   LOGTE:	log(T) temperature array (temperature measured in Kelvin)
;   DEM:		Differential emission measure in units of cm^-5 K^-1 corresponding logte array
;   AREA:		Area in cm^2 of the emitting region
;
;OUTPUT:
;   ENERGY:	Midpoints of energy bins
;
; KEYWORDS:
;
; HISTORY:
;2015-nov-12		LG	Wrote routine
;2016-sep-24            AJM     Correct treatment of coronal and TR DEMs
;-

FUNCTION DEM_HXR, logte, dem_cor=dem_cor, dem_tr=dem_tr, pix_cm, length, $
                  scale_height=scale_height, energy, _extra=_extra

default, scale_height, 5.e9
if ~keyword_set(dem_cor) and ~keyword_set(dem_tr) then begin
   print, "DEM input required."
   return, 0
endif

; Various styles of energy arrays for use later
energy_edges  = findgen(1000)/50.+2
energy_edges2 = get_edges( energy_edges, /edges_2 )	; needed format for f_vth
energy_mid = get_edges( energy_edges, /mean )
energy_wid = average( get_edges( energy_edges, /width ) )
nEn = n_elements( energy_mid )

; Compute EM in cm^-3 by multiplying DEM by temperature bin width and emitting area.
dlogt = average( get_edges( logte, /width ) )	; binwidth assuming evenly-spaced logT bins
; Ensure time averaged DEM
if keyword_set(dem_cor) then if size(dem_cor, /n_dimensions) gt 1 then dem_cor = double( average( dem_cor, 1 ) ) else dem_cor = dem_cor
if keyword_set(dem_tr) then if size(dem_tr, /n_dimensions) gt 1 then dem_tr = double( average( dem_tr, 1 ) ) else dem_tr = dem_tr

if keyword_set(dem_tr) then begin
   if ~keyword_set(dem_cor) then em_cm3 = 0.5 * dem_tr * pix_cm^2
   if keyword_set(dem_cor) then $
      em_cm3 = dem_cor * pix_cm^2 * scale_height / (2 * length) + 0.5 * dem_tr * pix_cm^2
endif else em_cm3 = dem_cor * pix_cm^2 * scale_height / (2 * length)

em_cm3_bin = em_cm3 * alog(10.) * 10.^logte * dlogt	; EM in each T bin

; Convert variables to units needed for F_VTH.  EM in 10^49 cm^-3, T in keV
em_49 = em_cm3_bin/1.d49
t_keV = 10.^logte / 11.6 / 1.d6		; 1/11.6 is Boltzmann constant in keV/MK
nT   = n_elements(logte)

; Compute HXR flux for each T, EM pair.
flux = fltarr( nT, nEn )
fvth_low = 0.0870317   ; lower temperature limit for f_vth 
fvth_hi = 86.0         ; upper temperature limit for f_vth

for i=0, nT-1 do begin
   if (t_keV[i] lt fvth_low) or (t_keV[i] gt fvth_hi) then continue
   flux[i,*] = f_vth( energy_edges2, [em_49[i], t_keV[i], 1], _extra=_extra )
endfor
flux[ where( finite(flux) eq 0 ) ] = 0.

energy=energy_mid

return, flux
	
END
