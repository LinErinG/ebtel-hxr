PRO interp_obs_table, obs_table_file=obs_table_file, obs_table=obs_table, inst=inst, $
ninds=ninds, calc_stats=calc_stats, savefile=savefile, log=log, _extra=_extra

;restore, 'foxsi_obs_table_stats_nfill.sav', /v
;obs_table = obs_table_fill[*,*,*,*,0]  ; Fill = 1.0
if keyword_set(obs_table_file) then restore, obs_table_file
IF ~keyword_set(obs_table_file) and ~keyword_set(obs_table) THEN BEGIN
   print, 'Error: Array or save file required'
   return
ENDIF

default, ninds, 100
interp_inds = findgen(ninds+1) * 0.1  ; Indices 0.0, 0.1, ... , 9.9, 10.0
obs_table_interp = fltarr(ninds+1, ninds+1, ninds+1, n_elements(obs_table[0,0,0,*]))

FOR ebin=0, n_elements(obs_table[0,0,0,*])-1 DO BEGIN
   IF keyword_set(log) THEN BEGIN
      print, 'Logarithmic interpolation'
      obs_table_interp[*,*,*,ebin] = interpolate(alog10(obs_table[*,*,*,ebin]), interp_inds, interp_inds, interp_inds, /grid)
   ENDIF ELSE $
   obs_table_interp[*,*,*,ebin] = interpolate(obs_table[*,*,*,ebin], interp_inds, interp_inds, interp_inds, /grid)
ENDFOR
if keyword_set(log) then obs_table_interp = 10^obs_table_interp

heat0_interp_log = findgen(ninds+1) * alog10(max(heat0)/min(heat0)) / ninds + alog10(min(heat0))
heat0_interp =  10^heat0_interp_log
flare_dur_interp_log = findgen(ninds+1) * alog10(max(flare_dur)/min(flare_dur)) /ninds + alog10(min(flare_dur))
flare_dur_interp = 10^flare_dur_interp_log
delay_interp_log = findgen(ninds+1) * alog10(max(delay)/min(delay)) /ninds + alog10(min(delay))
delay_interp = 10^delay_interp_log

if keyword_set(calc_stats) then $
calc_stats_obs_table, obs_table_interp, obs_chisq=obs_chisq_fill_interp, obs_likel=obs_likel_fill_interp, $
/dofill, obs_table_fill=obs_table_fill_interp, fill=fill, inst=inst, _extra=_extra

if keyword_set(calc_stats) then save, heat0_interp, flare_dur_interp, delay_interp, fill, obs_table_fill_interp, $
obs_chisq_fill_interp, obs_likel_fill_interp, file=savefile else $
save, heat0_interp, flare_dur_interp, delay_interp, obs_table_interp, file=savefile


END
