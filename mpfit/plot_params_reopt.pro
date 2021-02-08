PRO plot_params_reopt, savefile=savefile, endstring=endstring

default, endstring, ''
default, savefile, 'foxsi_obs_table_interp_stats_nfill.sav'
restore, savefile, /v

; Use array indices from obs_interp_best_fits.pro
heat0_range =  [min(heat0_interp), max(heat0_interp)]
duration_range = [min(flare_dur_interp),max(flare_dur_interp)]
delay_range = [min(delay_interp),max(delay_interp)]

si=1.8
thick=2


; HEATING VS. DURATION
imc = obs_chisq_fill_interp[*,*,0,0]
iml = imc
FOR i=0, (size(imc))[1]-1 DO BEGIN
   FOR j=0, (size(imc))[2]-1 DO BEGIN
      imc[i,j] = min(obs_chisq_fill_interp[i,j,*,*])
      iml[i,j] = max(obs_likel_fill_interp[i,j,*,*])
   ENDFOR
ENDFOR
      
a1 = alog10(imc)
colors1 = floor(a1*255./max(a1))
a2 = reform(iml)
colors2 = floor(a2*255./max(a2))

; Plot chi-squared intensity map
cgps_open, 'obs_chisq_interp_heat0_duration_reopt'+endstring+'.eps', /encaps
cgloadct, 1, /reverse
;window, 0, retain=2
plot, [0], [0], xrange=heat0_range, yrange=duration_range, xsty=1, ysty=1, /xlog, /ylog, $
xticks=5, yticks=5, xtit='Heating', ytit='Duration', charsi=si, charthick=thick, color=255, ticklen=-0.02
;.r                                                                  
FOR i=0, n_elements(heat0_interp)-2 DO BEGIN                               
  FOR j=0, n_elements(flare_dur_interp)-2 DO BEGIN                         
    x = [heat0_interp[i], heat0_interp[i], heat0_interp[i+1], heat0_interp[i+1]]                
    y = [flare_dur_interp[j], flare_dur_interp[j+1], flare_dur_interp[j+1], flare_dur_interp[j]]
    polyfill, x, y, color=colors1[i,j]                               
  ENDFOR                                                              
ENDFOR
;end
cgps_close

;Plot likelihood intensity map
cgps_open, 'obs_likel_interp_heat0_duration_reopt'+endstring+'.eps', /encaps
cgloadct, 1
;window, 1, retain=2
plot, [0], [0], xrange=heat0_range, yrange=duration_range, xsty=1, ysty=1, /xlog, /ylog, xtickv=heat0_tickv, $
ytickv=duration_tickv, xticks=5, yticks=5, xtit='Heating', ytit='Duration', charsi=si, charthick=thick,ticklen=-0.02 

;.r                                                                  
FOR i=0, n_elements(heat0_interp)-2 DO BEGIN                               
  FOR j=0, n_elements(flare_dur_interp)-2 DO BEGIN                         
    x = [heat0_interp[i], heat0_interp[i], heat0_interp[i+1], heat0_interp[i+1]]
    y = [flare_dur_interp[j], flare_dur_interp[j+1], flare_dur_interp[j+1], flare_dur_interp[j]]
    polyfill, x, y, color=colors2[i,j]                              
  ENDFOR                                                              
ENDFOR
;end
cgps_close

; HEATING VS. DELAY
imc = reform(obs_chisq_fill_interp[*,0,*,0])
iml = imc

FOR i=0, (size(imc))[1]-1 DO BEGIN
   FOR j=0, (size(imc))[2]-1 DO BEGIN
      imc[i,j] = min(obs_chisq_fill_interp[i,*,j,*])
      iml[i,j] = max(obs_likel_fill_interp[i,*,j,*])
   ENDFOR
ENDFOR

a1 = alog10(imc)
colors1 = floor(a1*255./max(a1))
a2 = reform(iml)
colors2 = floor(a2*255./max(a2))

; Plot chi-squared intensity map
cgps_open, 'obs_chisq_interp_heat0_delay_reopt'+endstring+'.eps', /encaps
cgloadct, 1, /reverse
;window, 0, retain=2
plot, [0], [0], xrange=heat0_range, yrange=delay_range, xsty=1, ysty=1, /xlog, /ylog, xtickv=heat0_tickv,$
ytickv=delay_tickv, xticks=5, yticks=5, xtit='Heating', ytit='Delay',charsi=si, charthick=thick, color=255, $
ticklen=-0.02

;.r                                                                  
FOR i=0, n_elements(heat0_interp)-2 DO BEGIN                               
  FOR j=0, n_elements(delay_interp)-2 DO BEGIN                         
    x = [heat0_interp[i], heat0_interp[i], heat0_interp[i+1], heat0_interp[i+1]]
    y = [delay_interp[j], delay_interp[j+1], delay_interp[j+1], delay_interp[j]]
    polyfill, x, y, color=colors1[i,j]                               
  ENDFOR                                                              
ENDFOR
;end
cgps_close

;Plot likelihood intensity map
cgps_open, 'obs_likel_interp_heat0_delay_reopt'+endstring+'.eps', /encaps
cgloadct, 1
;window, 1, retain=2
plot, [0], [0], xrange=heat0_range, yrange=delay_range, xsty=1, ysty=1, /xlog, /ylog, xticks=5, yticks=5, $
xtit='Heating', ytit='Delay',charsi=si, charthick=thick, ticklen=-0.02

;.r                                                                  
FOR i=0, n_elements(heat0_interp)-2 DO BEGIN                               
  FOR j=0, n_elements(delay_interp)-2 DO BEGIN                         
    x = [heat0_interp[i], heat0_interp[i], heat0_interp[i+1], heat0_interp[i+1]]
    y = [delay_interp[j], delay_interp[j+1], delay_interp[j+1], delay_interp[j]]
    polyfill, x, y, color=colors2[i,j]                               
  ENDFOR                                                              
ENDFOR
;end
cgps_close

; DELAY VS. DURATION
imc = reform(obs_chisq_fill_interp[0,*,*,0])
iml = imc

FOR i=0, (size(imc))[1]-1 DO BEGIN
   FOR j=0, (size(imc))[2]-1 DO BEGIN
      imc[i,j] = min(obs_chisq_fill_interp[i,*,j,*])
      iml[i,j] = max(obs_likel_fill_interp[i,*,j,*])
   ENDFOR
ENDFOR

a1 = transpose(alog10(imc))
colors1 = floor(a1*255./max(a1))
a2 = transpose(reform(iml))
colors2 = floor(a2*255./max(a2))

; Plot chi-squared intensity map
cgps_open, 'obs_chisq_interp_delay_duration_reopt'+endstring+'.eps', /encaps
cgloadct, 1, /reverse
;window, 0, retain=2
plot, [0], [0], xrange=delay_range, yrange=duration_range, xsty=1, ysty=1, /xlog, /ylog, xticks=5, yticks=5, $
xtit='Delay', ytit='Duration',charsi=si, charthick=thick, col=255, ticklen=-0.02
;.r                                                                  
FOR i=0, n_elements(delay_interp)-2 DO BEGIN                               
  FOR j=0, n_elements(flare_dur_interp)-2 DO BEGIN                         
    x = [delay_interp[i], delay_interp[i], delay_interp[i+1], delay_interp[i+1]]
    y = [flare_dur_interp[j], flare_dur_interp[j+1], flare_dur_interp[j+1], flare_dur_interp[j]]
    polyfill, x, y, color=colors1[i,j]                               
  ENDFOR                                                              
ENDFOR
;end
cgps_close

;Plot likelihood intensity map
cgps_open, 'obs_likel_interp_delay_duration_reopt'+endstring+'.eps', /encaps
cgloadct, 1
;window, 1, retain=2
plot, [0], [0], xrange=delay_range, yrange=duration_range, xsty=1, ysty=1, /xlog, /ylog, xticks=5, yticks=5, $
xtit='Delay', ytit='Duration',charsi=si, charthick=thick, ticklen=-0.02

;.r                                                                  
FOR i=0, n_elements(delay_interp)-2 DO BEGIN                               
  FOR j=0, n_elements(flare_dur_interp)-2 DO BEGIN                         
    x = [delay_interp[i], delay_interp[i], delay_interp[i+1], delay_interp[i+1]]
    y = [flare_dur_interp[j], flare_dur_interp[j+1], flare_dur_interp[j+1], flare_dur_interp[j]]
    polyfill, x, y, color=colors2[i,j]                               
  ENDFOR                                                              
ENDFOR
;end
cgps_close



END
