function foxsi_testfunction, fit_energy, params

;stop

; Params that can be fit are [heat0, fill, flare_dur].  Could also add loop length.
heat0 = params[0]
fill  = params[1]
flare_dur = params[2]
length = params[3]

default, scale_height,  5d9
inst = 'foxsi2'
main_dir = '~/foxsi/ebtel-hxr-master/'

solar_dx_arcsec = 100.		; Diameter of solar area of interest.
; Examples: FOXSI FWHM (5"), NuSTAR pixel (12"), AR size (~60")
solar_dx_cm  = solar_dx_arcsec*0.725d8		; Instrument resolution, centimeters
area = solar_dx_cm^2 * scale_height / 2 / length	; "effective" area of emitting plasma

dem_cm5 = run_ebtel( time, heat0=heat0, length=length, t_heat=flare_dur, te=te, dens=dens, logtdem=logtdem, $
		 avg_dem_cm5_cor=avg_dem_cm5_cor )
dem_cm5 *= fill[0]
hxr = dem_hxr( logtdem, dem_cm5, area, energy )

; Instrument-specific stuff goes here.
integration = 38.5	; duration of observation

count_rate = hxr_counts( energy, hxr, inst=inst, effarea=effarea, main_dir=main_dir )
; Main_dir is the home directory of the ebtel-hxr scripts from github,
; and will likely be different on your machine
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
	
;stop

end	
