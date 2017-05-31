PRO param_limits_hist, inst_file=inst_file, aia_xrt_file=aia_xrt_file, flux_file=flux_file,$
obs_chisq_limit=obs_chisq_limit, obs_likel_limit=obs_likel_limit, figfile=figfile, instr=instr, $
obs_chisq_elimit=obs_chisq_elimit, obs_likel_elimit=obs_likel_elimit, figtitle=figtitle, $
min=min, max=max, nbins=nbins, reduced=reduced, stop=stop

default, inst_file, 'foxsi_obs_table_interp_stats_nfill.sav' 
default, aia_xrt_file, 'aia_xrt_filters_60Mm_interp_nfill.sav'
default, flux_file, 'flux_limits_60Mm.sav'
default, instr, 'foxsi'

restore, inst_file
restore, aia_xrt_file
restore, flux_file

if instr eq 'nustar' then xrt_filter = fltarr(size(aia_filter,/dim))+1
obs_chisq_limit = obs_chisq_fill_interp / aia_filter / xrt_filter
obs_likel_limit = obs_likel_fill_interp * aia_filter * xrt_filter
reduced_chisq_limit = reduced_chisq / aia_filter / xrt_filter
obs_chisq_elimit = obs_chisq_limit
obs_likel_elimit = obs_likel_limit
reduced_chisq_elimit = reduced_chisq_limit

IF n_elements(size(obs_chisq_fill_interp, /dim)) gt 3 THEN BEGIN
   FOR i=0, (size(obs_chisq_fill_interp, /dim))[3]-1 DO BEGIN
      obs_chisq_elimit[*,*,*,i] = obs_chisq_fill_interp[*,*,*,i] / flux_limit_interp
      obs_likel_elimit[*,*,*,i] = obs_likel_fill_interp[*,*,*,i] * flux_limit_interp
      reduced_chisq_elimit[*,*,*,i] = reduced_chisq[*,*,*,i] / flux_limit_interp
   ENDFOR
ENDIF ELSE BEGIN
      obs_chisq_elimit = obs_chisq_fill_interp / flux_limit_interp
      obs_likel_elimit = obs_likel_fill_interp * flux_limit_interp
      reduced_chisq_elimit = reduced_chisq / flux_limit_interp
ENDELSE

default, figfile, instr+'_chisq_hist.eps'
default, figtitle, 'FOXSI AR 60 Mm'
default, min, 0 
if keyword_set(reduced) then default, max, 10 else default, max, 40
default, nbins, 12

IF keyword_set(reduced) THEN BEGIN
h = histogram(reduced_chisq, nbins=nbins, min=min, max=max, locations=n)
hel = histogram(reduced_chisq_elimit[where(reduced_chisq_elimit gt 0)], nbins=nbins, $
min=min, max=max, locations=nel)
hl = histogram(reduced_chisq_limit[where(reduced_chisq_limit gt 0)], nbins=nbins, $
min=min, max=max, locations=nl)
xtit='Reduced Chi-Squared'
ENDIF ELSE BEGIN
h = histogram(obs_chisq_fill_interp, nbins=nbins, min=min, max=max, locations=n)
hel = histogram(obs_chisq_elimit[where(obs_chisq_elimit gt 0)], nbins=nbins, $
min=min, max=max, locations=nel)
hl = histogram(obs_chisq_limit[where(obs_chisq_limit gt 0)], nbins=nbins, $
min=min, max=max, locations=nl)
xtit='Chi-Squared'
ENDELSE

if keyword_set(stop) then STOP

cgps_open, figfile, /encaps
cgloadct, 1
plot, n, h, psy=10, thick=4, xr=[min, max], /ylog, yr=[1d2, 1d8], $
xtit=xtit, ytit='Frequency', charsi=1.5, charthick=1.8, $
tit=figtitle
oplot, nel, hel, psy=10, thick=5, linest=1, color=150
oplot, nl, hl, psy=10, thick=5, linest=2, color=200
if instr eq 'foxsi' then limstring='AIA+XRT Limits' else limstring='AIA Limits'
al_legend, ['No Limits', 'Energy Limit', limstring], linest=[0,1,2], thick=3, $
color=[0,150,200], box=0, /top, /right, charsi=1.2, charthick=1.3
cgps_close


end
