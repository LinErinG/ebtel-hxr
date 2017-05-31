PRO plot_params_reopt_nofill, savefile=savefile, startstring=startstring, $
endstring=endstring, delay=delay, duration=duration, heat0=heat0, $
chisq_table=chisq_table, likel_table=likel_table, figtit=figtit, stop=stop, $
colormax1=cmax1, colormax2=cmax2

default, startstring, ''
default, endstring, ''
default, figtit, ''
default, savefile, 'foxsi_obs_table_interp_stats_log_norm.sav'
restore, savefile, /v
if keyword_set(chisq_table) then obs_chisq_fill_interp = chisq_table 
if keyword_set(likel_table) then obs_likel_fill_interp = likel_table

; Range of three parameters
heat0_range =  [min(heat0_interp), max(heat0_interp)]
duration_range = [min(flare_dur_interp),max(flare_dur_interp)]
delay_range = [min(delay_interp),max(delay_interp)]

si=1.8
thick=2

; HEATING VS. DURATION
imc = obs_chisq_fill_interp[*,*,0]
iml = imc
if keyword_set(delay) then delay = imc 

FOR i=0, (size(imc))[1]-1 DO BEGIN
   FOR j=0, (size(imc))[2]-1 DO BEGIN
      s = (size(imc))[3]
      imc[i,j] = min(obs_chisq_fill_interp[i,j,*])
      iml[i,j] = max(obs_likel_fill_interp[i,j,*])
      if keyword_set(delay) then $
         if ~finite(min(obs_chisq_fill_interp[i,j,*])) then delay[i,j] = 1./0. else $
         delay[i,j] = delay_interp[where(obs_chisq_fill_interp[i,j,*] eq min(obs_chisq_fill_interp[i,j,*]))]
   ENDFOR
ENDFOR

imc[where(~finite(imc))] = 1.2*max(imc[where(finite(imc))])     
a1 = alog10(imc)
colors1 = floor(a1*255./cmax1)
a2 = reform(iml)
colors2 = floor(a2*255./cmax2)

chi1 = imc 
like1 = iml

; Plot chi-squared intensity map
cgps_open, startstring+'obs_chisq_interp_heat0_duration_reopt'+endstring+'.eps', /encaps
cgloadct, 1, /reverse
;window, 0, retain=2
plot, [0], [0], xrange=heat0_range, yrange=duration_range, xsty=1, ysty=1, /xlog, /ylog, tit=figtit, $
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
cgps_open, startstring+'obs_likel_interp_heat0_duration_reopt'+endstring+'.eps', /encaps
cgloadct, 1
;window, 1, retain=2
plot, [0], [0], xrange=heat0_range, yrange=duration_range, xsty=1, ysty=1, /xlog, /ylog, tit=figtit, $
xtickv=heat0_tickv, ytickv=duration_tickv, xticks=5, yticks=5, xtit='Heating', ytit='Duration', charsi=si, $
charthick=thick, ticklen=-0.02 

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
imc = reform(obs_chisq_fill_interp[*,0,*])
iml = imc
if keyword_set(duration) then duration = imc

FOR i=0, (size(imc))[1]-1 DO BEGIN
   FOR j=0, (size(imc))[2]-1 DO BEGIN
      imc[i,j] = min(obs_chisq_fill_interp[i,*,j])
      iml[i,j] = max(obs_likel_fill_interp[i,*,j])
      if keyword_set(duration) then $
         if ~finite(min(obs_chisq_fill_interp[i,*,j])) then duration[i,j] = 1./0. else $
        duration[i,j] = flare_dur_interp[where(obs_chisq_fill_interp[i,*,j] eq min(obs_chisq_fill_interp[i,*,j]))]
   ENDFOR
ENDFOR

imc[where(~finite(imc))] = 1.2*max(imc[where(finite(imc))])
a1 = alog10(imc)
colors1 = floor(a1*255./cmax1)
a2 = reform(iml)
colors2 = floor(a2*255./cmax2)

chi2 = imc 
like2 = iml

; Plot chi-squared intensity map
cgps_open, startstring+'obs_chisq_interp_heat0_delay_reopt'+endstring+'.eps', /encaps
cgloadct, 1, /reverse
;window, 0, retain=2
plot, [0], [0], xrange=heat0_range, yrange=delay_range, xsty=1, ysty=1, /xlog, /ylog, xtickv=heat0_tickv,$
ytickv=delay_tickv, xticks=5, yticks=5, xtit='Heating', ytit='Delay',charsi=si, charthick=thick, color=255, $
ticklen=-0.02, tit=figtit

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
cgps_open, startstring+'obs_likel_interp_heat0_delay_reopt'+endstring+'.eps', /encaps
cgloadct, 1
;window, 1, retain=2
plot, [0], [0], xrange=heat0_range, yrange=delay_range, xsty=1, ysty=1, /xlog, /ylog, xticks=5, yticks=5, $
xtit='Heating', ytit='Delay',charsi=si, charthick=thick, ticklen=-0.02, tit=figtit

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
imc = reform(obs_chisq_fill_interp[0,*,*])
iml = imc
if keyword_set(heat0) then heat0 = imc

FOR i=0, (size(imc))[1]-1 DO BEGIN
   FOR j=0, (size(imc))[2]-1 DO BEGIN
      imc[i,j] = min(obs_chisq_fill_interp[*,i,j])
      iml[i,j] = max(obs_likel_fill_interp[*,i,j])
      if keyword_set(heat0) then $
         if ~finite(min(obs_chisq_fill_interp[*,i,j])) then heat0[i,j] = 1./0. else $
        heat0[i,j] = heat0_interp[where(obs_chisq_fill_interp[*,i,j] eq min(obs_chisq_fill_interp[*,i,j]))]
   ENDFOR
ENDFOR

if keyword_set(heat0) then heat0 = transpose(heat0)

imc[where(~finite(imc))] = 1.2*max(imc[where(finite(imc))])
a1 = transpose(alog10(imc))
colors1 = floor(a1*255./cmax1)
a2 = transpose(reform(iml))
colors2 = floor(a2*255./cmax2)

chi3 = transpose(imc) 
like3 = transpose(iml)

; Plot chi-squared intensity map
cgps_open, startstring+'obs_chisq_interp_delay_duration_reopt'+endstring+'.eps', /encaps
cgloadct, 1, /reverse
;window, 0, retain=2
plot, [0], [0], xrange=delay_range, yrange=duration_range, xsty=1, ysty=1, /xlog, /ylog, xticks=5, yticks=5, $
xtit='Delay', ytit='Duration',charsi=si, charthick=thick, col=255, ticklen=-0.02, tit=figtit
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
cgps_open, startstring+'obs_likel_interp_delay_duration_reopt'+endstring+'.eps', /encaps
cgloadct, 1
;window, 1, retain=2
plot, [0], [0], xrange=delay_range, yrange=duration_range, xsty=1, ysty=1, /xlog, /ylog, xticks=5, yticks=5, $
xtit='Delay', ytit='Duration',charsi=si, charthick=thick, ticklen=-0.02, tit=figtit

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

save, chi1, like1, chi2, like2, chi3, like3, delay, duration, heat0, $
file=startstring+'reopt_maps'+endstring+'.sav'

if keyword_set(stop) then STOP

END
