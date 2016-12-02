function linz_testfunction, fit_energy, params, instr=instr, scale_height=scale_height, $
	dont_compute_fill=dont_compute_fill, stop=stop

;; Note to Lindsay: FIT_ENERGY is currently not being used.  Should alter this.

default, instr, 'foxsi2'	; Must specify if you want NuSTAR.

; Params that can be fit are [heat0, fill, flare_dur, loop_length].
	
heat0 = params[0]
fill  = params[1]		; Note that default is that this is not fit!!
flare_dur = params[2]
length = params[3]

; defaults, for reference
;heat0 = 0.01       	; amplitude of (nano)flare [erg cm^-3 s^-1]
;length = 6.0e9			; loop half-length
;flare_dur = 500.		; duration of heating event [seconds]
scale_height = 5.e9		; coronal scale height (or any desired height)

; Diameter of solar area of interest.  1 arcmin for FOXSI-2, 100" for NuSTAR.
if instr eq 'foxsi2' or instr eq 'FOXSI2' then solar_dx_arcsec = 60. else solar_dx_arcsec = 100.
solar_dx_cm  = solar_dx_arcsec*0.725d8		; Instrument measurement length, centimeters

dem_cm5 = run_ebtel( time, heat0=heat0, length=length, t_heat=flare_dur, te=te, dens=dens, $
					 logtdem=logtdem, dem_cm5_cor=dem_cm5_cor, dem_cm5_tr=dem_cm5_tr)
dem_cm5 *= fill[0]
hxr = dem_hxr( logtdem, solar_dx_cm, length, energy, dem_cor=dem_cm5_cor, dem_tr=dem_cm5_tr )

count_rate = hxr_counts( energy, hxr, instr=instr, effarea=effarea )
counts = total( count_rate, 1 )
obs = keep_it_real( energy, counts, coarse )
obs[ where(obs lt 0)] = 0.

; Adjust obs to scale decently to the observation by manually adjusting the filling factor.
restore, 'sav/foxsi2-d6-spex-0.5keV.sav'
i = where( spec.energy_kev ge 5. and spec.energy_kev le 10. ) ; fitting only 5-10 keV
energy_measured = spec.energy_kev[i]
measured = spec.spec_p[i] / dt
err = spec.spec_p_err[i] / dt

obs = interpol( obs, coarse, energy_measured )

if not keyword_set( DONT_COMPUTE_FILL ) then begin
	; Artificially calculate "filling factor" just by comparing the integrals.
	int_measure = int_tabulated( energy_measured, measured )
	int_model   = int_tabulated( energy_measured, obs )	
	fill_new = int_measure / int_model
	print, 'Computed filling factor is ', fill_new
	;if fill_new gt 3. then fill_new = 3.
	obs *= fill_new
endif

;plot, fit_energy[j], obs[j], /ylo, /xlo, xra=[1.,20.]
;oplot, energy_measured[i], measured[i], /psy

loadct,0
hsi_linecolors
plot, energy_measured, obs, /xlo, /ylo, xr=[4.,12.], yr = [1.e-3,1.e1], xtickv=[findgen(7)+4.], $
	xticks=6, /xsty, psym=10, xtitle='Energy [keV]', ytitle='Counts s!U-1!NkeV!U-1!N', $
	charsi=1.4, charth=2, xth=3, yth=3, /nodata, $
	title='Count spectrum'
oplot, energy_measured, obs, thick=8, color=120, psym=10
oplot, energy_measured, measured, psym=1, col=6, thick=8
oplot_err, energy_measured, measured, xerr=0.25, $
	yerr=0.99*err, psym=1, $
	col=6, thick=8
al_legend, ['EBTEL expected values','FOXSI-2 measurement'], line=0, $
	col=[120,6], /right, box=0, charsi=1.3, thick=8

	
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
	
if keyword_set( stop ) then stop
	
return, obs
	
end	
