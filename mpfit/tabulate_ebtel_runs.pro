PRO tabulate_ebtel_runs, inst=inst, length=length, npix=npix, heat_range=heat_range, $
dur_range=dur_range, delay_range = delay_range, savefile=savefile, region=region, _extra=_extra

IF inst eq 'foxsi' THEN BEGIN
restore, '~/foxsi/ebtel-hxr-master/sav/foxsi2-d6-spex.sav'
ebins = n_elements(spec.energy_kev)
ENDIF ELSE IF inst eq 'nustar' THEN BEGIN
restore, '/home/andrew/foxsi/ebtel-hxr-master/sav/O4P1G0_FPMA.dat'
ebins = n_elements(engs)
ENDIF

default, length, 6d9
default, npix, 10
default, heat_range, [0.005, 0.5]
default, dur_range, [50, 500]
default, delay_range, [500, 5000]

heat0_log = [findgen(npix+1)]*alog10(max(heat_range)/min(heat_range))/npix + alog10(min(heat_range))
heat0 = 10^heat0_log 
flare_dur_log = [findgen(npix+1)]*alog10(max(dur_range)/min(dur_range))/npix + alog10(min(dur_range))
flare_dur = round(10^flare_dur_log)
delay_log = [findgen(npix+1)]*alog10(max(delay_range)/min(delay_range))/npix + alog10(min(delay_range))
delay = round(10^delay_log)

obs_table = fltarr(npix+1, npix+1, npix+1, ebins)

FOR i=0, n_elements(heat0)-1 DO BEGIN
   FOR j=0, n_elements(flare_dur)-1 DO BEGIN
      FOR k=0, n_elements(delay)-1 DO BEGIN

         param = [heat0[i], 1.0, flare_dur[j], delay[k]]
;         print, param
         
         if delay[k] lt 5000 then ebtelplus=1 else ebtelplus=0
         if inst eq 'foxsi' then obs = foxsi_testfunction(spec.energy_kev, param, $
                                                          length=length, ebtelplus=ebtelplus, _extra=_extra)
         if inst eq 'nustar' then obs = nustar_testfunction(engs, param, ebtelplus=ebtelplus, region=region, $
                                                            length=length, _extra=_extra)
         obs_table[i,j,k,*] = obs
         
      ENDFOR
   ENDFOR
ENDFOR

if keyword_set(savefile) then save, heat0, flare_dur, delay, obs_table, file=savefile


END
