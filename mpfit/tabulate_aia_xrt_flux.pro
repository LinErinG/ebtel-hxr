PRO tabulate_aia_xrt_flux, length=length, npix=npix, heat_range=heat_range, instr=instr, $
dur_range=dur_range, delay_range = delay_range, savefile=savefile, region=region, _extra=_extra

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

aia_filter = fltarr(npix+1, npix+1, npix+1)
xrt_filter = aia_filter
aia_table = fltarr(npix+1, npix+1, npix+1, 6)
xrt_table = fltarr(npix+1, npix+1, npix+1, 10)
main_dir = '~/foxsi/ebtel-hxr-master/mpfit/'

FOR i=0, n_elements(heat0)-1 DO BEGIN
   FOR j=0, n_elements(flare_dur)-1 DO BEGIN
      FOR k=0, n_elements(delay)-1 DO BEGIN
         prefix='ebtelplus/heat'+strtrim(string(heat0[i],format='(F11.5)'),2)+'dur'+$
             strtrim(round(flare_dur[j]),2)+'delay'+strtrim(round(delay[k]),2)+'length'+$
             strtrim(string(length, FORMAT='(E11.1)'),2)
         if file_test(main_dir+prefix) eq 0 then $
             spawn, 'python write_run_ebtel_config.py '+string(heat0[i])+' '+$
             string(flare_dur[j])+' '+string(delay[k])+' '+string(length)+' '+prefix
 
            read_ebtel_txt, prefix, logtdem=logtdem, dem_cor_avg=dem_cor_avg, dem_tr_avg=dem_tr_avg

            spawn, 'rm '+main_dir+prefix+'*'

            aia_filter[i,j,k] = aia_predict(logtdem, dem_cor_avg, dem_tr_avg, length=length, fill=1.0, $
                                   dns_pred_aia=dns_pred_aia, instr=instr, region=region, _extra=_extra)
            aia_table[i,j,k,*] = dns_pred_aia
            IF instr eq 'foxsi' THEN BEGIN
            xrt_filter[i,j,k] = xrt_predict(logtdem, dem_cor_avg, dem_tr_avg, length=length, fill=1.0, $
                                   dns_pred_xrt=dns_pred_xrt, _extra=_extra)
            xrt_table[i,j,k,*] = dns_pred_xrt
            ENDIF
         ENDFOR
   ENDFOR
ENDFOR

save, heat0, flare_dur, delay, aia_filter, xrt_filter, aia_table, xrt_table, file=savefile

END
