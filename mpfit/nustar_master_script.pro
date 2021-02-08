PRO nustar_master_script, tabulate=tabulate, aia_tab=aia_tab, interp=interp, aia_interp=aia_interp, $
aia_filter=aia_filter, regmin=regmin, regmax=regmax, display=display, histogram=histogram, $
alldets=alldets, chidiff=chidiff

cd, '~/foxsi/ebtel-hxr-master/mpfit/'
if keyword_set(alldets) then restore, '../sav/O4P1G0_alldets.dat' else $
restore, '../sav/O4P1G0_FPMA.dat'
if keyword_set(alldets) then detstr='alldets' else detstr='fpma'

default, regmin, 0
default, regmax, 4
default, display, 0

; Tabulate NuSTAR fluxes for the full parameter space 
FOR reg=regmin, regmax DO BEGIN
   IF reg eq 3 THEN BEGIN
      length=1d10 
      lstr='100Mm' 
   ENDIF ELSE BEGIN
      length=7d9
      lstr='70Mm'
   ENDELSE
   IF reg ge 2 THEN BEGIN
      coronal=1
      addstr='_coronal'
   ENDIF ELSE BEGIN
      coronal=0
      addstr=''
   ENDELSE

   if keyword_set(tabulate) then $
      tabulate_ebtel_runs, inst='nustar', length=length, delay_range=[500,10000], $
        heat_range=[0.005, 25], dur_range=[5, 500], savefile='nustar'+ids[reg]+'_'+detstr+$
        '_obs_table_'+lstr+''+addstr+'.sav', reg=reg, coronal=coronal, alldets=alldets

; Use log interpolation and normalize spectra 
   IF keyword_set(interp) THEN BEGIN
      restore, 'nustar'+ids[reg]+'_'+detstr+'_obs_table_'+lstr+''+addstr+'.sav'
      obs_table = obs_table[*,*,*,0:25]
      interp_obs_table, obs_table_file='nustar'+ids[reg]+'_'+detstr+'_obs_table_'+lstr+$
        ''+addstr+'.sav', table=obs_table, inst='nustar', /calc_stats, $
        savefile='nustar'+ids[reg]+'_'+detstr+'_obs_table_'+lstr+'_interp_stats'+addstr+$
        '_log_norm.sav', /log, /normalize, reg=reg, alldets=alldets
   ENDIF

ENDFOR

; Tabulate AIA & XRT flux values
IF keyword_set(aia_tab) THEN BEGIN
   tabulate_aia_xrt_flux, length=7d9, delay_range=[500,10000], heat_range=[0.005, 25], $
                            dur_range=[5, 500], instr='nustar', reg=0, savefile='aia_table_70Mm.sav'
   tabulate_aia_xrt_flux, length=1d10, delay_range=[500,10000], heat_range=[0.005, 25], $
                            dur_range=[5, 500], instr='nustar', reg=0, savefile='aia_table_100Mm.sav'
   tabulate_aia_xrt_flux, length=7d9, delay_range=[500,10000], heat_range=[0.005, 25], $
                             dur_range=[5, 500],  instr='nustar', reg=0, savefile='aia_table_70Mm_coronal.sav', /coronal
   tabulate_aia_xrt_flux, length=1d10, delay_range=[500,10000], heat_range=[0.005, 25], $
                            dur_range=[5, 500], instr='nustar', reg=0, savefile='aia_table_100Mm_coronal.sav', /coronal
ENDIF

; Interpolate to a finer grid 
IF keyword_set(aia_interp) THEN BEGIN
   interp_aia_xrt_table, 'aia_table_70Mm.sav', /log, savefile='aia_table_70Mm_interp_log.sav'
   interp_aia_xrt_table, 'aia_table_100Mm.sav', /log, savefile='aia_table_100Mm_interp_log.sav'
   interp_aia_xrt_table, 'aia_table_70Mm_coronal.sav', /log, savefile='aia_table_70Mm_coronal_interp_log.sav'
   interp_aia_xrt_table, 'aia_table_100Mm_coronal.sav', /log, savefile='aia_table_100Mm_coronal_interp_log.sav'
ENDIF

; Make filters from AIA & XRT data
; Different filter for each active reg, b/c norm_array is different 

FOR reg=regmin, regmax DO BEGIN

if reg eq 3 then lstr='100Mm' else lstr='70Mm'
if reg ge 2 then addstr='_coronal' else addstr=''

IF keyword_set(aia_filter) THEN BEGIN
   restore, 'nustar'+ids[reg]+'_'+detstr+'_obs_table_'+lstr+'_interp_stats'+addstr+'_log_norm.sav'
   make_aia_xrt_filter, 'aia_table_'+lstr+''+addstr+'_interp_log.sav', $
    savefile='aia_filters_'+lstr+''+addstr+'_interp_log_'+ids[reg]+'.sav', norm_array=norm_array, $
    nfill=0, instr='nustar', reg=reg
ENDIF

; Make flux limit tables for 70Mm and 100Mm
make_flux_limit_table, obs_table_file='nustarD2_'+detstr+'_obs_table_70Mm_interp_stats_log_norm.sav', $
   length=7d9, savefile='flux_limits_70Mm.sav'
make_flux_limit_table, obs_table_file='nustarL2_'+detstr+'_obs_table_100Mm_interp_stats_coronal_log_norm.sav', $
   length=1d10, savefile='flux_limits_100Mm.sav'


; Load in NuSTAR data, flux limits, and AIA limits
savefile = 'nustar'+ids[reg]+'_'+detstr+'_obs_table_'+lstr+'_interp_stats'+addstr+'_log_norm.sav'
flux_file = 'flux_limits_'+lstr+'.sav'
aia_file = 'aia_filters_'+lstr+''+addstr+'_interp_log_'+ids[reg]+'.sav'
restore, savefile
restore, flux_file 
restore, aia_file


; Make plots with 3rd free parameter re-optimized
mx1 = max(alog10(obs_chisq_fill_interp))
mx2 = max(obs_likel_fill_interp)
plot_params_reopt_nofill, savefile=savefile, startstr='nustar'+ids[reg]+'_'+detstr+'_', endstr=''+addstr+'_log_norm',$
  heat0=heat0, delay=delay, duration=duration, /setheat0, /setdelay, /setduration, colormax1=mx1, colormax2=mx2
IF display THEN BEGIN
   spawn, 'evince nustar'+ids[reg]+'_'+detstr+'_obs_likel_interp_heat0_duration_reopt'+addstr+'_log_norm.eps &'
   spawn, 'evince nustar'+ids[reg]+'_'+detstr+'_obs_likel_interp_heat0_delay_reopt'+addstr+'_log_norm.eps &'
   spawn, 'evince nustar'+ids[reg]+'_'+detstr+'_obs_likel_interp_delay_duration_reopt'+addstr+'_log_norm.eps &'
ENDIF

; Plot histograms of different parameters at optimal values
;if keyword_set(histogram) then plot_param_hist, heat0, duration, delay, savefile='nustar'+ids[reg]+'_'+detstr+'_obs_table'+$
;lstr+'_interp_stats'+addstr+'_log_norm.sav'

; Put energy flux limits in 
;obs_chisq_flux = obs_chisq_fill_interp / flux_limit_interp
;obs_likel_flux = obs_likel_fill_interp * flux_limit_interp
;plot_params_reopt_nofill, savefile='nustar'+ids[reg]+'_'+detstr+'_obs_table_'+lstr+'_interp_stats'+addstr+$
;'_log_norm.sav', startstr='nustar'+ids[reg]+'_'+detstr+'_', endstr=''+addstr+'_log_norm_flux_limits', $
;chisq_table=obs_chisq_flux, likel_table=obs_likel_flux, colormax1=mx1, colormax2=mx2
;IF display THEN BEGIN
;   spawn, 'evince nustar'+ids[reg]+'_'+detstr+'_obs_likel_interp_heat0_duration_reopt'+addstr+'_log_norm_flux_limits.eps &'
;   spawn, 'evince nustar'+ids[reg]+'_'+detstr+'_obs_likel_interp_heat0_delay_reopt'+addstr+'_log_norm_flux_limits.eps &'
;   spawn, 'evince nustar'+ids[reg]+'_'+detstr+'_obs_likel_interp_delay_duration_reopt'+addstr+'_log_norm_flux_limits.eps &'
;ENDIF


; Put AIA/XRT limits in 
;obs_chisq_aia = obs_chisq_fill_interp / aia_filter 
;obs_likel_aia = obs_likel_fill_interp * aia_filter 
;plot_params_reopt_nofill, savefile='nustar'+ids[reg]+'_'+detstr+'_obs_table_'+lstr+'_interp_stats'+addstr+$
;'_log_norm.sav', startstr='nustar'+ids[reg]+'_'+detstr+'_', endstr=''+addstr+'_log_norm_aia_limits', $
;chisq_table=obs_chisq_aia, likel_table=obs_likel_aia, colormax1=mx1, colormax2=mx2
;IF display THEN BEGIN
;   spawn, 'evince nustar'+ids[reg]+'_'+detstr+'_obs_likel_interp_heat0_duration_reopt'+addstr+'_log_norm_aia_limits.eps &'
;   spawn, 'evince nustar'+ids[reg]+'_'+detstr+'_obs_likel_interp_heat0_delay_reopt'+addstr+'_log_norm_aia_limits.eps &'
;   spawn, 'evince nustar'+ids[reg]+'_'+detstr+'_obs_likel_interp_delay_duration_reopt'+addstr+'_log_norm_aia_limits.eps &'
;ENDIF


; Put in all the limits 
obs_chisq_all = obs_chisq_fill_interp / aia_filter / flux_limit_interp
obs_likel_all = obs_likel_fill_interp * aia_filter * flux_limit_interp
plot_params_reopt_nofill, savefile='nustar'+ids[reg]+'_'+detstr+'_obs_table_'+lstr+'_interp_stats'+addstr+$
'_log_norm.sav', startstr='nustar'+ids[reg]+'_'+detstr+'_', endstr=''+addstr+'_log_norm_all_limits', $
chisq_table=obs_chisq_all, likel_table=obs_likel_all, delay=delay, duration=duration, heat0=heat0, $
colormax1=mx1, colormax2=mx2, /setdelay, /setduration, /setheat0
IF display THEN BEGIN
   spawn, 'evince nustar'+ids[reg]+'_'+detstr+'_obs_likel_interp_heat0_duration_reopt'+addstr+'_log_norm_all_limits.eps &'
   spawn, 'evince nustar'+ids[reg]+'_'+detstr+'_obs_likel_interp_heat0_delay_reopt'+addstr+'_log_norm_all_limits.eps &'
   spawn, 'evince nustar'+ids[reg]+'_'+detstr+'_obs_likel_interp_delay_duration_reopt'+addstr+'_log_norm_all_limits.eps &'
ENDIF

; Plot two-panel plots with the 3rd parameter heat maps
mapstring = 'nustar'+ids[reg]+'_'+detstr+'_reopt_maps'+addstr+'_log_norm'

default, chidiff, 6.25  ; 90% confidence intervals

plot_params_reopt_twoframe_nustar, savefile=savefile, mapstring=mapstring, startstr='nustar'+ids[reg]+'_'+detstr+'_', $
   endstr=addstr+'_log_norm', reg=reg, display=display, stop=stop, chidiff=chidiff

plot_params_reopt_twoframe_nustar, savefile=savefile, mapstring=mapstring, startstr='nustar'+ids[reg]+'_'+detstr+'_', $
   endstr=addstr+'_log_norm', reg=reg, display=display, stop=stop, /all_limits, chidiff=chidiff
  

IF keyword_set(histogram) THEN BEGIN
; Plot chi-squared histogram for 3 cases (no limits, flux limits,
; AIA/XRT limits) 
   param_limits_hist, inst_file=savefile, aia_xrt_file=aia_file, flux_file=flux_file, $
      figfile='nustar'+ids[reg]+'_'+detstr+'_chisq_hist'+addstr+'_norm.eps', figtitle='NuSTAR AR '+ids[reg]+' '+lstr, $
      max=100, instr='nustar'
; Reduced chi-squared 
   param_limits_hist, inst_file=savefile, aia_xrt_file=aia_file, flux_file=flux_file, $
      figfile='nustar'+ids[reg]+'_'+detstr+'_reduced_chisq_hist'+addstr+'_norm.eps', $
      figtitle='NuSTAR AR '+ids[reg]+' '+lstr, /reduced


; Plot fill factor histogram for 3 cases (no limits, flux limits,
; AIA/XRT limits)
   norm_array_flux = norm_array * flux_limit_interp
   norm_array_aia = norm_array * aia_filter 
   hn = histogram(alog10(norm_array), min=-10, max=8, nbins=20, locations=nn)
   hf = histogram(alog10(norm_array_flux), min=-10, max=8, nbins=20, locations=nf)
   hax = histogram(alog10(norm_array_aia), min=-10, max=8, nbins=20, locations=nax)
   !p.multi=0
   cgps_open, 'nustar'+ids[reg]+'_'+detstr+'_fill_hist'+addstr+'_norm.eps', /encaps
   plot, nn, hn, xr=[-10, 8], xtit='Log(Fill Factor)', ytit='Frequency', psy=10, thick=3, $
         tit='NuSTAR AR '+ids[reg]+' '+lstr
   oplot, nf, hf, linest=1, color=150, psy=10, thick=3 
   oplot, nax, hax, linest=2, color=200, psy=10, thick=3 
   al_legend, ['No Limits', 'Energy Limit', 'AIA Limits'], linest=[0,1,2], thick=3, $
              color=[0,150,200], box=0, /top, /right, charsi=1.2, charthick=1.3
   cgps_close

   IF display THEN BEGIN
      spawn, 'evince nustar'+ids[reg]+'_'+detstr+'_chisq_hist'+addstr+'_norm.eps &'
      spawn, 'evince nustar'+ids[reg]+'_'+detstr+'_reduced_chisq_hist'+addstr+'_norm.eps &'
      spawn, 'evince nustar'+ids[reg]+'_'+detstr+'_fill_hist'+addstr+'_norm.eps &'
   ENDIF

ENDIF

ENDFOR



end

