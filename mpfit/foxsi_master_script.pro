; Tabulate FOXSI fluxes for the full parameter space 
tabulate_ebtel_runs, inst='foxsi', length=6d9, savefile='foxsi_obs_table.sav'
; Interpolate to a finer grid 
interp_obs_table, 'foxsi_obs_table.sav', inst='foxsi', /calc_stats, $
  savefile='foxsi_obs_table_interp_stats_nfill.sav'

; Tabulate AIA & XRT flux values
tabulate_aia_xrt_flux, length=6d9, savefile='aia_xrt_table_60Mm.sav'
; Interpolate to a finer grid 
restore, 'aia_xrt_table_60Mm.sav'
; Use parts of interp_obs_table and calc_stats_obs_table to
; interpolate arrays by hand to a single save file
; 'aia_xrt_table_interp_nfill.sav'

make_aia_xrt_ratio, 'aia_xrt_table_interp_nfill.sav', savefile='aia_xrt_filters_60Mm_interp_nfill.sav'

; Make energy flux limit table 
make_flux_limit_table, obs_table_file='foxsi_obs_table_interp_stats_nfill.sav', $
length=6d9, savefile='flux_limits_60Mm.sav'

; Calculate limit arrays and make plots 
plot_stat_intensity_aia_xrt_limits ; Plot intensity maps w/ AIA/XRT constraints

foxsi_param_limits  ; Chi-squared hist with no limits, energy limits, and AIA/XRT limits
$gimp foxsi_chisq_hist.eps &
foxsi_param_limits, foxsi_file='foxsi_obs_table_20Mm_interp_stats_nfill.sav' , $
aia_xrt_file='aia_xrt_filters_20Mm_interp_nfill.sav', $
flux_file='flux_limits_20Mm', figfile='foxsi_chisq_hist_20Mm.eps', $
figtitle='FOXSI AR Length 20 Mm'
$gimp foxsi_chisq_hist_20Mm.eps &
foxsi_param_limits, foxsi_file='foxsi_obs_table_delay10000_interp_stats_nfill.sav', $
aia_xrt_file='aia_xrt_filters_60Mm_delay10000_interp_nfill.sav', $
flux_file='flux_limits_delay10000.sav', figfile= 'foxsi_chisq_hist_delay10000.eps', $
figtitle='FOXSI AR Max Delay 10,000 s'
$gimp foxsi_chisq_hist_delay10000.eps &

; Plot intensity maps w/ re-optimized parameters 
plot_params_reopt_params
plot_params_reopt_params, savefile='foxsi_obs_table_20Mm_interp_stats_nfill.sav', $
endstring='_20Mm'
plot_params_reopt_params, savefile='foxsi_obs_table_delay10000_interp_stats_nfill.sav', $
endstring='_delay10000'

plot_params_reopt_limits, aia_xrt_file='aia_xrt_filters_interp_nfill.sav'
plot_params_reopt_limits, flux_file='flux_limits_interp1.sav'
plot_params_reopt_limits, savefile='foxsi_obs_table_20Mm_interp_stats_nfill.sav',$
aia_xrt_file='aia_xrt_filters_20Mm_interp_nfill.sav', endstring='_aia_xrt_20Mm'
plot_params_reopt_limits, savefile='foxsi_obs_table_20Mm_interp_stats_nfill.sav',$
flux_file='flux_limits_20Mm', endstring='_flux_limits_20Mm'
plot_params_reopt_limits, savefile='foxsi_obs_table_delay10000_interp_stats_nfill.sav', $
aia_xrt_file='aia_xrt_filters_delay10000_interp_nfill.sav', endstring='_aia_xrt_delay10000'
plot_params_reopt_limits, savefile='foxsi_obs_table_delay10000_interp_stats_nfill.sav', $
flux_file='flux_limits_delay10000.sav', endstring='_flux_limits_delay10000'
