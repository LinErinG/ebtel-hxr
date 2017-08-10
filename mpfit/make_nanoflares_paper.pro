PRO make_nanoflares_paper, length=length, solar_dx_arcsec=solar_dx_arcsec

default, length, 2d9
flare_dur = 100
heat0 = 0.05

; Run nanoflare train
nano_repeat, length=length, tau=flare_dur, heat0=heat0, delay=500, $
nflares=10, savefile='nano_repeat_paper.sav';, /plot

; Run single nanoflare
dem_cm5_tot = run_ebtel(time=time, duration=10000, heat0=heat0, te=t,$
t_heat=flare_dur, dens=n, heat_array=heat_array, logtdem=logtdem, $
dem_cm5_cor=dem_cm5_cor, dem_cm5_tr=dem_cm5_tr, length=length)

; Rename variables to avoid overlap
ts = t & ns = n 

restore, 'nano_repeat_paper.sav', /v

; Make plots 
cgps_open, 'nanoflares_paper_delay.eps', /encaps
!p.multi=[0,2,2]
charsi=0.9

; Heating 
plot, time, heat_array, xtit='Time (s)', charsi=charsi, $
ytit='Heating Rate (erg cm!U-3!N s!U-1!N)' ;single
oplot, time, heat, linesty=1 ;train
; Temperature
plot, time, ts/1d6, xtit='Time (s)', ytit='Temperature (MK)', charsi=charsi ;single
oplot, time, t/1d6, linesty=1 ;train
; Density
;plot, time, n, xtit='Time (s)', ytit='Density (cm!U-3!N)', linest=1, charsi=charsi ;train
;oplot, time, ns
; DEMs
plot, logtdem, alog10(dem_cm5_tot), yran=[18.,25.], xran=[5.5,8.],$
xtit='log T', ytit='DEM (cm!U-5!N K!U-1!N)', charsi=charsi
oplot, logtdem, alog10(dem_tot_avg), linest=1, thick=2
; HXR Spectra 
default, solar_dx_arcsec, 60
pix_cm  = solar_dx_arcsec*0.725d8
flux = dem_hxr(logtdem, pix_cm, length, energy, dem_cor=dem_cm5_cor, dem_tr=dem_cm5_tr)
flux = total(flux, 1)
flux_train = dem_hxr(logtdem, pix_cm, length, energy, dem_cor=dem_cor_avg, dem_tr=dem_tr_avg)
flux_train = total(flux_train, 1)
plot, energy, flux, /ylog, yr=[1d-4, 1d2], xr=[1,15], /xs, thick=2, $
xtit='Energy (keV)', ytit='Flux (ph cm!U-2!N s!U-1!N keV!U-1!N)', $
charsi=charsi, ytickf='exp1'
oplot, energy, flux_train, linest=1, thick=2
cgps_close


END
