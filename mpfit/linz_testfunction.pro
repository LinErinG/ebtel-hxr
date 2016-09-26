function linz_testfunction, fit_energy, params, instr=instr, scale_height=scale_height

default, instr, 'foxsi2'	; Must specify if you want NuSTAR.

; Params that can be fit are [heat0, fill, flare_dur].  Could also add loop length.
	
heat0 = params[0]
fill  = params[1]
flare_dur = params[2]
length = params[3]

; defaults, for reference
;heat0 = 0.01       	; amplitude of (nano)flare [erg cm^-3 s^-1]
;length = 6.0e9			; loop half-length
scale_height = 5.e9		; coronal scale height (or any desired height)
;flare_dur = 500.		; duration of heating event [seconds]

; NOTE TO LINDSAY: NEED TO UPDATE AREA BASED ON FOXSI-2 OBSERVATION!
solar_dx_arcsec = 100.		; Diameter of solar area of interest.
; Examples: FOXSI FWHM (5"), NuSTAR pixel (12"), AR size (~60")
solar_dx_cm  = solar_dx_arcsec*0.725d8		; Instrument measurement length, centimeters

dem_cm5 = run_ebtel( time, heat0=heat0, length=length, t_heat=flare_dur, te=te, dens=dens, $
					 logtdem=logtdem, dem_cm5_cor=dem_cm5_cor, dem_cm5_tr=dem_cm5_tr)
dem_cm5 *= fill[0]
hxr = dem_hxr( logtdem, solar_dx_cm, length, energy, dem_cor=dem_cm5_cor, dem_tr=dem_cm5_tr )

; Set observation duration depending on instrument.
if instr eq 'FOXSI2' or instr eq 'foxsi2' then integration = 38.5
if instr eq 'NUSTAR' or instr eq 'nustar' then integration = 3.10

count_rate = hxr_counts( energy, hxr, instr=instr, effarea=effarea )
counts = total( count_rate, 1 )*integration
obs = keep_it_real( energy, counts, coarse )
obs[ where(obs lt 0)] = 0.

obs = interpol( obs, coarse, fit_energy )
	
	
print
print
print, 'DIAGNOSTICS: '
print, '  params: ',  params
print, '  heat0: ', heat0
print, '  fill: ', fill
print, '  flare_dur: ', flare_dur
print, '  length: ', length
print
print
	
return, obs
	
end	
