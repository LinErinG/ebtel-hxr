function nustar_testfunction, fit_energy, params, length=length, real=real, $
logtdem=logtdem, dem_cm5_cor=dem_cm5_cor, dem_cm5_tr=dem_cm5_tr, $
resp_dim=resp_dim, ebtelplus=ebtelplus, silent=silent, region=region, _extra=_extra

; Params that can be fit are [heat0, fill, flare_dur, delay].  Loop
; length fixed.
heat0 = params[0]
fill  = params[1]
flare_dur = params[2]
delay = params[3]
default, length, 7d9

default, scale_height,  5d9
inst = 'nustar'
main_dir = '~/foxsi/ebtel-hxr-master/mpfit/'

solar_dx_arcsec = 120.		; Diameter of solar area of interest.
; Examples: FOXSI FWHM (5"), NuSTAR pixel (12"), AR size (~60")
pix_cm  = solar_dx_arcsec*0.725d8	; Instrument resolution, centimeters

IF keyword_set(ebtelplus) THEN BEGIN
   prefix='ebtelplus/heat'+strtrim(string(heat0,format='(F11.5)'),2)+'dur'+$
   strtrim(round(flare_dur),2)+'delay'+strtrim(round(delay),2)+'length'+$
   strtrim(string(length, FORMAT='(E11.1)'),2)
; Choose prefix configuration
   if file_test(main_dir+prefix) eq 0 then $
   spawn, 'python write_run_ebtel_config.py '+string(heat0)+' '+$
   string(flare_dur)+' '+string(delay)+' '+string(length)+' '+prefix 
   read_ebtel_txt, prefix, logtdem=logtdem, dem_cor_avg=dem_cm5_cor, $
      dem_tr_avg=dem_cm5_tr, delay=delay
   spawn, 'rm '+main_dir+prefix+'*'
ENDIF ELSE BEGIN
if keyword_set(delay) then $
   nano_repeat, delay=delay, heat0=heat0, length=length, tau=flare_dur, $
   dem_cor_avg=dem_cm5_cor, dem_tr_avg=dem_cm5_tr, logtdem=logtdem, $
   _extra=_extra else $
   dem_cm5_tot = run_ebtel( time, heat0=heat0, length=length, t_heat=flare_dur,$
   logtdem=logtdem, dem_cm5_cor=dem_cm5_cor, dem_cm5_tr=dem_cm5_tr, $
   _extra=_extra)
ENDELSE 

dem_cm5_tr *= fill
dem_cm5_cor *= fill
hxr = dem_hxr( logtdem, dem_cor=dem_cm5_cor, dem_tr=dem_cm5_tr, pix_cm, $
length, energy, inst=inst)

default, resp_dim, 2
if resp_dim eq 1 then $
count_rate = hxr_counts( energy, hxr, inst=inst, effarea=effarea) else $
count_rate = hxr_counts_2d( energy, hxr, inst=inst, response=response, $
                            region=region, _extra=_extra)
counts = total( count_rate, 1 )  ; count spectrum in counts/s/keV

IF keyword_set(real) THEN BEGIN
   obs = keep_it_real( energy, counts, coarse, fwhm=0.4, binsize=(fit_energy[1]-fit_energy[0]) )
   obs[ where(obs lt 0)] = 0.
   obs = interpol( obs, coarse, fit_energy )
ENDIF ELSE obs = interpol( counts, energy, fit_energy)

if ~keyword_set(silent) then begin	
print
print
print, 'DIAGNOSTICS: '
print, '  params: ',  params
print, '  heat0: ', heat0
print, '  fill: ', fill
print, '  flare_dur: ', flare_dur
print, '  delay: ', delay
print
print
endif

	
return, obs
	
end	
