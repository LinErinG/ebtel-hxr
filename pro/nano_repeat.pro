PRO nano_repeat, length=length, tau=tau, heat0=heat0, delay=delay, nflares=nflares, $
                 save=save, dem_tot_avg=dem_tot_avg, dem_cor_avg=dem_cor_avg, $
                 dem_tr_avg=dem_tr_avg, logtdem=logtdem, plot=plot, time=time, heat=heat, $
                 heat_bkg=heat_bkg, savefile=savefile
;
; Routine to compute temperature and density evolution and the time-averaged DEM(T) 
; for the last cycle of a sequence of repeating nanoflares
;
; written, J. A. Klimchuk, 2016 Aug 10
; corrected normalization of dem, JAK, 2016 Aug 15
; added input keywords, AJM, 2016 Oct 7
; changed delay to a float; errors otherwise, AJM, 2016 Nov 9
  
  default, savefile, 'ebtel_output.sav'

 ; Set default parameters
  default, length, 3.0e9  ;  loop halflength
  default, tau, 100.  ;  nanoflare duration
  default, heat0, 1.5e-1  ;  nanoflare amplitude (maximum heating rate)
  default, delay, 3000.  ;  time delay between successive nanoflares (start to start)
  default, nflares, 5  ;  number of nanoflares in sequence

  hcorona = 5.e9  ;  vertical thickness of corona
  default, heat_bkg, 1.e-5  ;  background heating rate
  delay = float(delay)  ; Int delay can cause error

  duration = nflares*delay 
  time = findgen(duration)
  heat = fltarr(duration)
  tauhalf = tau/2
  
  for i = 0, tauhalf do heat(i) = heat0*time(i)/tauhalf
  for i = tauhalf+1, tau do heat(i) = heat0*(tau - time(i))/tauhalf

  for i = 1, nflares-1 do heat(i*delay:(i+1)*delay-1) = heat(0:delay-1)
  
  heat = heat + heat_bkg
    
;  ebtel2, time, heat, length, t, n, p, v, ta, na, pa, c11, dem_tr, dem_cor, logtdem, /classical
  ebtel2, time, heat, length, t, n, p, v, ta, na, pa, c11, dem_tr, dem_cor, logtdem
  
  timelast = time(delay*(nflares-1):duration-1) 
  tlast = t(delay*(nflares-1):duration-1)
  nlast = n(delay*(nflares-1):duration-1)
  
  dem_cor_avg = total(dem_cor(delay*(nflares-1):duration-1,*),1)/delay
  dem_tr_avg = total(dem_tr(delay*(nflares-1):duration-1,*),1)/delay
  dem_tot_avg = dem_cor_avg + dem_tr_avg
  
  flux_avg = heat0*tauhalf/delay*hcorona
  
  !x.thick = 3.5
  !y.thick = 3.5
  !z.thick = 3.5
  !p.thick = 3.5
  
IF keyword_set(plot) THEN BEGIN
  !p.multi=[0,2,2]
  plot, time, heat, xtit='Time (s)',   $
   ytit='Heating Rate (erg cm!U-3!N s!U-1!N)',  $
	charsiz=1.6, charthick=3.5

  plot, logtdem, alog10(dem_tot_avg), yran=[18.,23.], xran=[5.5,7.5],   $
        xtit='log T', ytit='DEM (cm!U-5!N K!U-1!N)',   $
		tit='Total DEM (solid), Coronal DEM (dashed)',   $
		charsiz=1.6, charthick=3.5
  oplot, logtdem, alog10(dem_cor_avg), linest=2
  
  plot, timelast, tlast/1.e6, xtit='Time (s)', ytit='T (MK)',  $
	charsiz=1.6, charthick=3.5

  plot, timelast, nlast, xtit='Time (s)', ytit='Density (cm!U-3!N)',  $
	charsiz=1.6, charthick=3.5
  !p.multi=0

ENDIF
  
  print, 'T_max =', max(tlast)
  print, 'T_min =', min(tlast)
  print, 'n_min =', min(nlast)
  print, 'energy flux =', flux_avg
  
if keyword_set(save) or keyword_set(savefile) then $
 save, file=savefile, logtdem, dem_tot_avg, dem_cor_avg, dem_tr_avg, $
       timelast, tlast, nlast, time, heat, /verbose
  

END
