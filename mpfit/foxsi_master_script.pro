PRO foxsi_master_script, tabulate=tabulate, aia_tab=aia_tab, interp=interp, aia_interp=aia_interp, $
aia_xrt_filter=aia_xrt_filter, display=display, histogram=histogram, alldets=alldets, stop=stop, $
chidiff=chidiff

default, alldets, 0
if keyword_set(alldets) then restore, '~/foxsi/ebtel-hxr-master/sav/foxsi2-alldets-spex.sav' else $
restore, '~/foxsi/ebtel-hxr-master/sav/foxsi2_det6_countspec.sav'
if keyword_set(alldets) then detstring='alldets' else detstring='det6'

; Tabulate FOXSI fluxes for the full parameter space 
if keyword_set(tabulate) then $
tabulate_ebtel_runs, inst='foxsi', length=6d9, heat_range=[0.005, 25], $
delay_range=[500,10000], dur_range = [5, 500], alldets=alldets, savefile='foxsi_'+detstring+'_obs_table.sav'

IF keyword_set(interp) THEN BEGIN
restore, 'foxsi_obs_table.sav' 
obs_table = obs_table[*,*,*,0:20]
; Interpolate to a finer grid 
interp_obs_table, obs_table_file='foxsi_'+detstring+'_obs_table.sav', inst='foxsi', /calc_stats, $
table=obs_table, /log, /normalize, alldets=alldets, savefile='foxsi_'+detstring+'_obs_table_interp_stats_log_norm.sav'
ENDIF

; Tabulate AIA & XRT flux values
if keyword_set(aia_tab) then $
tabulate_aia_xrt_flux, length=6d9, savefile='aia_xrt_table_60Mm.sav',$
delay_range=[500,10000], heat_range=[0.005, 25], dur_range = [5, 500], instr='foxsi'

; Interpolate to a finer grid 
if keyword_set(aia_interp) then $
interp_aia_xrt_table, 'aia_xrt_table_60Mm.sav', /log, $
savefile='aia_xrt_table_60Mm_interp_log.sav'

; Make filters
IF keyword_set(aia_xrt_filter) THEN BEGIN
restore, 'foxsi_'+detstring+'_obs_table_interp_stats_log_norm.sav'
make_aia_xrt_filter, 'aia_xrt_table_60Mm_interp_log.sav', $
savefile='aia_xrt_filters_60Mm_interp_log_norm.sav', instr='foxsi', norm_array=norm_array
ENDIF

; Make energy flux limit table 
make_flux_limit_table, obs_table_file='foxsi_'+detstring+'_obs_table_interp_stats_log_norm.sav', $
length=6d9, savefile='flux_limits_60Mm_log.sav'



; Load in FOXSI data, flux limits, and AIA limits
savefile = 'foxsi_'+detstring+'_obs_table_interp_stats_log_norm.sav'
aia_xrt_file = 'aia_xrt_filters_60Mm_interp_log_norm.sav'
flux_file = 'flux_limits_60Mm_log.sav'

restore, savefile 
restore, flux_file 
restore, aia_xrt_file

; Make plots with 3rd free parameter re-optimized
mx1 = max(alog10(obs_chisq_fill_interp))
mx2 = max(obs_likel_fill_interp)
plot_params_reopt_nofill, savefile=savefile, startstring='foxsi_'+detstring+'_', endstring='_log_norm', $
/setheat0, /setduration,  /setdelay, colormax1=mx1, colormax2=mx2, stop=stop

;; ;Plot histograms of different parameters at optimal values 
;; ;Heating
;; if keyword_set(histogram) then $
;;    plot_param_hist, heat0, duration, delay, savefile=savefile

;; ;Put energy flux limits in 
;; obs_chisq_flux = obs_chisq_fill_interp / flux_limit_interp
;; obs_likel_flux = obs_likel_fill_interp * flux_limit_interp
;; plot_params_reopt_nofill, savefile=savefile, startstring='foxsi_',
;; endstring='_log_norm_'+detstring+'_flux_limits',
;; chisq_table=obs_chisq_flux, likel_table=obs_likel_flux, $
;;colormax1=mx1, colormax2=mx2
;; IF keyword_set(display) THEN BEGIN
;;    spawn, 'evince foxsi_obs_likel_interp_heat0_duration_reopt_log_norm_flux_limits.eps &'
;;    spawn, 'evince foxsi_obs_likel_interp_heat0_delay_reopt_log_norm_flux_limits.eps &'
;;    spawn, 'evince foxsi_obs_likel_interp_delay_duration_reopt_log_norm_flux_limits.eps &'
;; END

;; ;Put AIA/XRT limits in 
;; obs_chisq_aia_xrt = obs_chisq_fill_interp / aia_filter / xrt_filter 
;; obs_likel_aia_xrt = obs_likel_fill_interp * aia_filter * xrt_filter
;; plot_params_reopt_nofill, savefile='foxsi_obs_table_interp_stats_log_norm_'+detstring+'.sav',$
;; startstring='foxsi_', endstring='_log_norm_'+detstring+'_aia_xrt_limits', chisq_table=obs_chisq_aia_xrt, $
;; likel_table=obs_likel_aia_xrt, colormax1=mx1, colormax2=mx2
;; IF keyword_set(display) THEN BEGIN
;;    spawn, 'evince foxsi_obs_likel_interp_heat0_duration_reopt_log_norm_aia_xrt_limits.eps &'
;;    spawn, 'evince foxsi_obs_likel_interp_heat0_delay_reopt_log_norm_aia_xrt_limits.eps &'
;;    spawn, 'evince foxsi_obs_likel_interp_delay_duration_reopt_log_norm_aia_xrt_limits.eps &'
;; ENDIF

; Put all limits in 
obs_chisq_all = obs_chisq_fill_interp / aia_filter / xrt_filter / flux_limit_interp
obs_likel_all = obs_likel_fill_interp * aia_filter * xrt_filter * flux_limit_interp
plot_params_reopt_nofill, savefile=savefile, startstring='foxsi_'+detstring+'_', endstring='_log_norm_all_limits', $
chisq_table=obs_chisq_all, likel_table=obs_likel_all, /setdelay, /setduration, /setheat0, colormax1=mx1, colormax2=mx2, $
stop=stop

IF keyword_set(display) THEN BEGIN
   spawn, 'evince foxsi_obs_likel_interp_heat0_duration_reopt_log_norm_all_limits.eps &'
   spawn, 'evince foxsi_obs_likel_interp_heat0_delay_reopt_log_norm_all_limits.eps &'
   spawn, 'evince foxsi_obs_likel_interp_delay_duration_reopt_log_norm_all_limits.eps &'
ENDIF

IF keyword_set(histogram) THEN BEGIN
; Plot chi-squared histogram for 3 cases (no limits, flux limits,
; AIA/XRT limits) 
   param_limits_hist, inst_file=savefile, aia_xrt_file=aia_xrt_file, $
     flux_file=flux_file, figfile='foxsi_'+detstring+'_chisq_hist_log_norm.eps'
; Reduced chi-squared
;   param_limits_hist, inst_file='foxsi_'+detstring+'obs_table_interp_stats_log_norm.sav', $
;                      aia_xrt_file=aia_xrt_file , flux_file=flux_file, $
;                      figfile='foxsi_'+detstring+'reduced_chisq_hist_norm.eps', /reduced

; Plot fill factor histogram for 3 cases (no limits, flux limits,
; AIA/XRT limits)
   norm_array_flux = norm_array * flux_limit_interp
   norm_array_aia_xrt = norm_array * aia_filter * xrt_filter
   hn = histogram(alog10(norm_array), min=-10, max=8, nbins=20, locations=nn)
   hf = histogram(alog10(norm_array_flux), min=-10, max=8, nbins=20, locations=nf)
   hax = histogram(alog10(norm_array_aia_xrt), min=-10, max=8, nbins=20, locations=nax)
   cgps_open, 'foxsi_'+detstring+'_fill_hist_log_norm.eps', /encaps
   plot, nn, hn, xr=[-10, 8], xtit='Log(Fill Factor)', ytit='Frequency', psy=10, thick=3, $
         tit='FOXSI AR 60 Mm'
   oplot, nf, hf, linest=1, color=150, psy=10, thick=3 
   oplot, nax, hax, linest=2, color=200, psy=10, thick=3 
   al_legend, ['No Limits', 'Energy Limit', 'AIA/XRT Limits'], linest=[0,1,2], thick=3, $
              color=[0,150,200], box=0, /top, /right, charsi=1.2, charthick=1.3
   cgps_close

ENDIF

; Plot two-panel plots with the 3rd parameter heat maps
mapstring='foxsi_'+detstring+'_reopt_maps_log_norm'

default, chidiff, 6.25  ; 90% confidence intervals

plot_params_reopt_twoframe_foxsi, savefile=savefile, mapstring=mapstring, startstring='foxsi_'+detstring+'_', $
display=display, chidiff=chidiff

plot_params_reopt_twoframe_foxsi, savefile=savefile, mapstring=mapstring, startstring='foxsi_'+detstring+'_', $
display=display, /all_limits, chidiff=chidiff

end
