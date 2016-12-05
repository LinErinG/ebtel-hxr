function nustar_testfunction, fit_energy, params, real=real, logtdem=logtdem, $
                              dem_cm5=dem_cm5, delay=delay

default, real, 1
; Params that can be fit are [heat0, fill, flare_dur].  Could also add loop length.
heat0 = params[0]
fill  = params[1]
flare_dur = params[2]
length = params[3]

default, scale_height,  5d9
inst = 'nustar'
main_dir = '~/foxsi/ebtel-hxr-master/'

solar_dx_arcsec = 120.		; Diameter of solar area of interest.
; Examples: FOXSI FWHM (5"), NuSTAR pixel (12"), AR size (~60")
pix_cm  = solar_dx_arcsec*0.725d8	; Instrument resolution, centimeters

if keyword_set(delay) then $
   nano_repeat, delay=delay, heat0=heat0, length=length, tau=flare_dur, $
                dem_cor_avg=dem_cm5_cor, dem_tot_avg=dem_cm5, logtdem=logtdem else $
dem_cm5 = run_ebtel( time, heat0=heat0, length=length, t_heat=flare_dur,$
                     logtdem=logtdem, dem_cm5_cor=dem_cm5_cor )

dem_cm5 *= fill
dem_cm5_cor *= fill
hxr = dem_hxr( logtdem, dem_cor=dem_cm5_cor, pix_cm, length, energy )

count_rate = hxr_counts( energy, hxr, inst=inst, effarea=effarea, main_dir=main_dir )
counts = total( count_rate, 1 )  ; count spectrum in counts/s/keV

if keyword_set(real) then begin
   obs = keep_it_real( energy, counts, coarse, fwhm=0.4, binsize=(fit_energy[1]-fit_energy[0]) )
   obs[ where(obs lt 0)] = 0.
   obs = interpol( obs, coarse, fit_energy )
endif else obs = interpol( counts, energy, fit_energy)
	
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
