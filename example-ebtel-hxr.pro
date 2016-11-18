;
; Example script to demonstrate the calculation of expected hard X-ray (HXR) 
; observations from EBTEL simulations.
;

add_path, '~/local-git-repo/ebtel-idl/'	; or wherever your EBTEL codes are
add_path, 'pro'
add_path, 'mpfit'

;; Set up parameters
heat0 = 0.01          	; amplitude of (nano)flare [erg cm^-3 s^-1]
length = 7.5e9		; loop half-length
scale_height = 5.e9	; coronal scale height (or any desired height)
flare_dur = 500.	; duration of heating event [seconds]

solar_dx_arcsec = 60.	; Diameter of solar area of interest.
; Examples: FOXSI FWHM (5"), NuSTAR pixel (12"), AR size (~60")
pix_cm  = solar_dx_arcsec*0.725d8		; Observing area, centimeters

fill=1.		; filling factor

;; Next are the three main functions.

;; First is just a wrapper for EBTEL. Returns *time-averaged* DEMs
dem_cm5 = run_ebtel( time, heat0=heat0, length=length, t_heat=flare_dur, te=te, dens=dens, $
					 logtdem=logtdem, dem_cm5_cor=dem_cm5_cor, dem_cm5_tr=dem_cm5_tr)

; put filling factor outside EBTEL wrapper so we can test several filling factors 
; without rerunning EBTEL.
dem_cm5 *= fill		
dem_cm5_cor *= fill
dem_cm5_tr *= fill

;; Next, calculate HXR flux based on EBTEL DEM and relevant area
hxr = dem_hxr( logtdem, pix_cm, length, energy, dem_cor=dem_cm5_cor, dem_tr=dem_cm5_tr )

;; Fold through HXR instrument response (example NuSTAR)
instr = 'nustar'
count_rate = hxr_counts( energy, hxr, instr=instr, effarea=effarea )

; Get total counts and integrate for X seconds.
integration = 30.			; 30 seconds
counts = total( count_rate, 1 )*integration

obs = keep_it_real( energy, counts, coarse )
obs[ where(obs lt 0)] = 0.

;*
; All of the following is to plot intermediate variables and end results.
;*

popen, 'ebtel-plots-'+instr, xsi=10, ysi=8, /land	; for printing plots.  Needs special library.

; EBTEL OUTPUTS

!p.multi=[0,2,2]
ch=1.3
plot, time, te, xtit='Time [s]', ytit='Temperature [K]', charsi=ch, thick=4, title='Single nanoflare'
plot, time, dens, xtit='Time [s]', ytit='Density [cm!U-3!N]', charsi=ch, thick=4, title='Single nanoflare'
plot, logtdem, dem_cm5/length/2, xtit='Log T [log MK]', ytit='DEM [cm!U-6!N K!U-1!N]', $
	/ylog, xra=[5.5,7.5], yra=[1.e8,1.e14], charsi=ch, $
	thick=4, title='Time-averaged DEM'
oplot, logtdem, dem_cm5_cor/length/2, line=2, thick=2
al_legend, ['Corona + TR','Corona only'], line=[0,2], thick=4, /top, /right, box=0

em_cm3_cor = dem_cm5_cor * pix_cm^2 * scale_height / (2 * length)
em_cm3 = em_cm3_cor + 0.5 * dem_cm5_tr * pix_cm^2
em_log_cm3 = em_cm3 * alog(10.) * 10.^logtdem
em_log_cm3_cor = em_cm3_cor * alog(10.) * 10.^logtdem

; EM

plot, logtdem, em_log_cm3, xtit='Log T [log MK]', ytit='DEM!Llog!N [cm!U-3!N]', charsi=ch, thick=4, $
	/ylog, xra=[5.5,7.5], yra=minmax(em_log_cm3[where(em_log_cm3 gt 0.)]), $
	tit='DEM_log in macro area, filling factor '+string(fill, format='(F0.2)')
oplot, logtdem, em_log_cm3_cor, line=2, thick=4
al_legend, ['Corona + TR','Corona only'], line=[0,2], thick=2, /top, /right, box=0
;peak = max( em_log_cm3_cor, i_peak )
;oplot, logtdem[i_peak]*[1.,1.], [1.d42,1.d46], line=1

; HXR FLUX

loadct, 13
nonzero = where( max( hxr, dim=2 ) gt 0. )
sparse = nonzero[0:*:5]		; just take every 5th temperature bin, to make fewer lines.
n_sparse = n_elements( sparse )
plot, energy, hxr[0,*], /xlo, /ylo, yr=minmax(hxr), charsi=ch, color=1, thick=4, $
	xtit='Energy [keV]', ytit='Photons s!U-1!N cm!U-2!N keV!U-1!N', tit='f_vth X-ray flux'
for i=0, n_sparse-1 do oplot, energy, hxr[sparse[i],*], col=255/n_sparse*i, thick=4
al_legend, strtrim(logtdem[sparse],2), color=indgen(n_sparse)*255/n_sparse, $
	/right, box=0, charsi=0.7, line=0, thick=4

; EFFECTIVE AREA

plot, energy, effarea, charsi=ch, thick=4, xtitle='Energy [keV]', $
	ytitle='Effective area [cm!U2!N]', title=instr+' effective area'

; PREDICTED COUNT RATE

; Plot results
loadct, 13
nonzero = where( max( count_rate, dim=2 ) gt 0. )
sparse = nonzero[0:*:5]
n_sparse = n_elements( sparse )
plot, energy, count_rate[0,*], /xlo, /ylo, yr=minmax(hxr), charsi=ch, thick=4, $
	xtit='Energy [keV]', ytit='Counts s!U-1!N keV!U-1!N', tit=instr+' counts'
for i=0, n_sparse-1 do oplot, energy, count_rate[sparse[i],*], col=255/n_sparse*i, thick=4
al_legend, strtrim(logtdem[sparse],2), col=indgen(n_sparse)*255/n_sparse, $
	/right, box=0, charsi=0.7, line=0, thick=4

; FINAL, 'DIRTY' OBSERVATION

plot_err, coarse, obs, yerr=sqrt(double(obs)/integration), /xlo, /ylo, xr=[2.,20.], $
	yr=[1.e0,1.e4], /xsty, psym=10, xtitle='Energy [keV]', ytitle='Counts keV!U-1!N', $
	charsi=ch, thick=4, title='Binned count spectrum for '+strtrim(string(integration),2)+' s'

pclose	; for printing plots.  Needs special library.
