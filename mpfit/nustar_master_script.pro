cd, '~/foxsi/ebtel-hxr-master/mpfit/'
restore,'../sav/O4P1G0_FPMA.dat'

; Tabulate NuSTAR fluxes for the full parameter space 
.r
FOR region=0, 4 DO BEGIN
if region eq 3 then length=1d10 else length=7d9
if region ge 2 then coronal=1 else coronal=0
tabulate_ebtel_runs, inst='nustar', length=length, delay_range=[500,10000], $
savefile='nustar'+ids[region]+'_obs_table_100Mm_delay10000.sav', region=region,$
coronal=coronal
ENDFOR
end

; Use log interpolation and normalize spectra 
.r
FOR region=0, 4 DO BEGIN
if region eq 3 then lengthstr='100Mm' else lengthstr='70Mm'
restore, 'nustar'+ids[region]+'_obs_table_'+lengthstr+'_delay10000.sav', /v
obs_table = obs_table[*,*,*,0:25]
interp_obs_table, obs_table_file='nustar'+ids[region]+'_obs_table_'+lengthstr+'_delay10000.sav', table=obs_table, inst='nustar', $
/calc_stats, savefile='nustar'+ids[region]+'_obs_table_'+lengthstr+'_interp_stats_delay10000_log_norm.sav', $
/log, /normalize, region=region
ENDFOR
end

; Tabulate AIA & XRT flux values
tabulate_aia_xrt_flux, length=7d9, delay_range=[500,10000], instr='nustar', $
savefile='aia_table_70Mm_delay10000.sav'
; Interpolate to a finer grid 
interp_aia_xrt_table, 'aia_table_70Mm_delay10000.sav', /log, savefile='aia_table_70Mm_delay10000_interp_log.sav'
; Make filters from AIA & XRT data
; Different filter for each active region, b/c norm_array is different 
.r
FOR region=0, 4 DO BEGIN
print, 'Region = '
print, region
if region eq 3 then lengthstr='100Mm' else lengthstr='70Mm'
restore, 'nustar'+ids[region]+'_obs_table_'+lengthstr+'_interp_stats_delay10000_log_norm.sav', /v
make_aia_xrt_filter, 'aia_table_'+lengthstr+'_delay10000_interp_log.sav', $
savefile='aia_filters_'+lengthstr+'_delay10000_interp_log_'+ids[region]+'.sav', norm_array=norm_array, nfill=0, instr='nustar', region=region
ENDFOR
end

; Make flux limit tables for 70Mm and 100Mm
make_flux_limit_table, obs_table_file='nustarL2_obs_table_100Mm_interp_stats_delay10000_log_norm.sav', $
length=1d10, savefile='flux_limits_100Mm_delay10000.sav'

; Make plots with 3rd free parameter re-optimized
!p.multi=0
.r
FOR region=0, 4 DO BEGIN
if region eq 3 then lengthstr='100Mm' else lengthstr='70Mm'
restore, 'nustar'+ids[region]+'_obs_table_'+lengthstr+'_interp_stats_delay10000_log_norm.sav' , /v 
mx1 = max(alog10(obs_chisq_fill_interp))
mx2 = max(obs_likel_fill_interp)
plot_params_reopt_nofill, savefile='nustar'+ids[region]+'_obs_table_'+lengthstr+'_interp_stats_delay10000_log_norm.sav', $
startstring='nustar'+ids[region]+'_', endstring='_delay10000_log_norm', heat0=heat0, delay=delay, $
duration=duration, colormax1=mx1, colormax2=mx2
spawn, 'evince nustar'+ids[region]+'_obs_likel_interp_heat0_duration_reopt_delay10000_log_norm.eps &'
spawn, 'evince nustar'+ids[region]+'_obs_likel_interp_heat0_delay_reopt_delay10000_log_norm.eps &'
spawn, 'evince nustar'+ids[region]+'_obs_likel_interp_delay_duration_reopt_delay10000_log_norm.eps &'
stop
ENDFOR
end

; Plot histograms of different parameters at optimal values
device, Window_State=win
; Heating
hhist = histogram(heat0, min=0.005, max=0.5, nbins=20, locations=nh)
if win[0] eq 0 then window, 0, retain=2 else wset, 0
plot, nh, hhist, psy=10, thick=3, xr=[0.05, 0.50], xtit='Heating', ytit='Frequency'
; Duration
durhist = histogram(duration, min=50, max=500, nbins=20, locations=ndur)
if win[1] eq 0 then window, 1, retain=2 else wset, 1 
plot, ndur, durhist, psy=10, thick=3, xr=[0, 550], xtit='Duration', ytit='Frequency'
; Delay 
dhist = histogram(delay, min=500, max=10000, nbins=20, locations=nd)
if win[2] eq 0 then window, 2, retain=2 else wset, 2 
plot, nd, dhist, psy=10, thick=3, xr=[0, 10500], xtit='Delay', ytit='Frequency' 
; Fill factor 
restore, 'nustar'+ids[region]+'_obs_table'+lengthstr+'_interp_stats_delay10000_log_norm.sav', /v  
hn = histogram(alog10(norm_array), min=-10, max=8, nbins=20, locations=nn)
if win[3] eq 0 then window, 3, retain=2 else wset, 3
plot, nn, hn, xr=[-10, 8], xtit='Log(Fill Factor)', ytit='Frequency', psy=10, thick=3
stop
ENDFOR
end

; Put energy flux limits in 
.r
FOR region=0, 4 DO BEGIN
if region eq 3 then lengthstr='100Mm' else lengthstr='70Mm'
restore, 'nustar'+ids[region]+'_obs_table_'+lengthstr+'_interp_stats_delay10000_log_norm.sav', /v  
restore, 'flux_limits_'+lengthstr+'_delay10000.sav', /v 
obs_chisq_fill_interp = obs_chisq_fill_interp / flux_limit_interp
obs_likel_fill_interp = obs_likel_fill_interp * flux_limit_interp
plot_params_reopt_nofill, savefile='nustar'+ids[region]+'_obs_table_'+lengthstr+'_interp_stats_delay10000_log_norm.sav',$
startstring='nustar'+ids[region]+'_', endstring='_delay10000_log_norm_flux_limits', $
chisq_table=obs_chisq_fill_interp, likel_table=obs_likel_fill_interp
spawn, 'evince nustar'+ids[region]+'_obs_likel_interp_heat0_duration_reopt_delay10000_log_norm_flux_limits.eps &'
spawn, 'evince nustar'+ids[region]+'_obs_likel_interp_heat0_delay_reopt_delay10000_log_norm_flux_limits.eps &'
spawn, 'evince nustar'+ids[region]+'_obs_likel_interp_delay_duration_reopt_delay10000_log_norm_flux_limits.eps &'
stop

; Put AIA/XRT limits in 
restore, 'nustar'+ids[region]+'_obs_table_'+lengthstr+'_interp_stats_delay10000_log_norm.sav', /v
restore, 'aia_filters_'+lengthstr+'_delay10000_interp_log_'+ids[region]+'.sav', /v
obs_chisq_fill_interp = obs_chisq_fill_interp / aia_filter 
obs_likel_fill_interp = obs_likel_fill_interp * aia_filter 
plot_params_reopt_nofill, savefile='nustar'+ids[region]+'_obs_table_'+lengthstr+'_interp_stats_delay10000_log_norm.sav',$
startstring='nustar'+ids[region]+'_', endstring='_delay10000_log_norm_aia_limits', chisq_table=obs_chisq_fill_interp, $
likel_table=obs_likel_fill_interp
spawn, 'evince nustar'+ids[region]+'_obs_likel_interp_heat0_duration_reopt_delay10000_log_norm_aia_limits.eps &'
spawn, 'evince nustar'+ids[region]+'_obs_likel_interp_heat0_delay_reopt_delay10000_log_norm_aia_limits.eps &'
spawn, 'evince nustar'+ids[region]+'_obs_likel_interp_delay_duration_reopt_delay10000_log_norm_aia_limits.eps &'
stop

; Put in all the limits 
restore, 'flux_limits_'+lengthstr+'_delay10000.sav', /v 
restore, 'nustar'+ids[region]+'_obs_table_'+lengthstr+'_interp_stats_delay10000_log_norm.sav', /v
mx1 = max(alog10(obs_chisq_fill_interp))
mx2 = max(obs_likel_fill_interp)
restore, 'aia_filters_'+lengthstr+'_delay10000_interp_log_'+ids[region]+'.sav', /v
obs_chisq_fill_interp = obs_chisq_fill_interp / aia_filter / flux_limit_interp
obs_likel_fill_interp = obs_likel_fill_interp * aia_filter * flux_limit_interp
plot_params_reopt_nofill, savefile='nustar'+ids[region]+'_obs_table_'+lengthstr+'_interp_stats_delay10000_log_norm.sav',$
startstring='nustar'+ids[region]+'_', endstring='_delay10000_log_norm_all_limits', chisq_table=obs_chisq_fill_interp, $
likel_table=obs_likel_fill_interp, delay=delay, duration=duration, heat0=heat0, colormax1=mx1, colormax2=mx2
spawn, 'evince nustar'+ids[region]+'_obs_likel_interp_heat0_duration_reopt_delay10000_log_norm_all_limits.eps &'
spawn, 'evince nustar'+ids[region]+'_obs_likel_interp_heat0_delay_reopt_delay10000_log_norm_all_limits.eps &'
spawn, 'evince nustar'+ids[region]+'_obs_likel_interp_delay_duration_reopt_delay10000_log_norm_all_limits.eps &'
stop

; Plot chi-squared histogram for 3 cases (no limits, flux limits,
; AIA/XRT limits) 
param_limits_hist, inst_file='nustar'+ids[region]+'_obs_table_'+lengthstr+'_interp_stats_delay10000_log_norm.sav', $
aia_xrt_file='aia_filters_'+lengthstr+'_delay10000_interp_log_'+ids[region]+'.sav', flux_file='flux_limits_'+lengthstr+'_delay10000.sav',$
figfile='nustar'+ids[region]+'_chisq_hist_delay10000_norm.eps', figtitle='NuSTAR AR '+ids[region]+' '+lengthstr, $
max=100, instr='nustar'
; Reduced chi-squared 
param_limits_hist, inst_file='nustar'+ids[region]+'_obs_table_'+lengthstr+'_interp_stats_delay10000_log_norm.sav', $
aia_xrt_file='aia_filters_'+lengthstr+'_delay10000_interp_log_'+ids[region]+'.sav', flux_file='flux_limits_'+lengthstr+'_delay10000.sav',$
figfile='nustar'+ids[region]+'_reduced_chisq_hist_delay10000_norm.eps', figtitle='NuSTAR AR '+ids[region]+' '+lengthstr, /reduced

; Plot fill factor histogram for 3 cases (no limits, flux limits,
; AIA/XRT limits)
norm_array_flux = norm_array * flux_limit_interp
norm_array_aia = norm_array * aia_filter 
hn = histogram(alog10(norm_array), min=-10, max=8, nbins=20, locations=nn)
hf = histogram(alog10(norm_array_flux), min=-10, max=8, nbins=20, locations=nf)
hax = histogram(alog10(norm_array_aia), min=-10, max=8, nbins=20, locations=nax)
cgps_open, 'nustar'+ids[region]+'_fill_hist_delay10000_norm.eps', /encaps
plot, nn, hn, xr=[-10, 8], xtit='Log(Fill Factor)', ytit='Frequency', psy=10, thick=3, $
tit='NuSTAR AR '+ids[region]+' '+lengthstr
oplot, nf, hf, linest=1, color=150, psy=10, thick=3 
oplot, nax, hax, linest=2, color=200, psy=10, thick=3 
al_legend, ['No Limits', 'Energy Limit', 'AIA Limits'], linest=[0,1,2], thick=3, $
color=[0,150,200], box=0, /top, /right, charsi=1.2, charthick=1.3
cgps_close

spawn, 'evince nustar'+ids[region]+'_chisq_hist_delay10000_norm.eps &'
spawn, 'evince nustar'+ids[region]+'_reduced_chisq_hist_delay10000_norm.eps &'
spawn, 'evince nustar'+ids[region]+'_fill_hist_delay10000_norm.eps &'

stop
ENDFOR
end

