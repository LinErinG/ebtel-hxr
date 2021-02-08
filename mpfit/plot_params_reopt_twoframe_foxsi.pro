PRO plot_params_reopt_twoframe_foxsi, savefile=savefile, all_limits=all_limits, display=display, $
stop=stop, startstring=startstring, endstring=endstring, mapstring=mapstring, chidiff=chidiff

default, savefile, 'foxsi_obs_table_interp_stats_log_norm.sav'
restore, savefile, /v

; Range of three parameters
heat0_range =  [min(heat0_interp), max(heat0_interp)]
duration_range = [min(flare_dur_interp),max(flare_dur_interp)]
delay_range = [min(delay_interp),max(delay_interp)]

if keyword_set(all_limits) then limstring='_all_limits' else limstring=''
mapfile = mapstring+limstring+'.sav'
restore, mapfile, /v 
default, startstring, 'foxsi_'
default, endstring, '_double'+limstring

!p.multi=[0,2,1]
mx1 = max(alog10(chi1))

; HEATING vs. DURATION
cgps_open, startstring+'chisq_heat0_duration_reopt'+endstring+'.eps', /encaps, xsi=14
cgloadct, 1, /reverse
colors2=floor( 255./(mx1-min(alog10(chi1))) * (alog10(chi1)-min(alog10(chi1))) )
plot, [0], [0], xrange=heat0_range, yrange=duration_range, xsty=1, ysty=1, /xlog, /ylog, $
xticks=5, yticks=5, xtit='Heating', ytit='Duration', charsi=si, charthick=thick, ticklen=-0.02, $
tit='Log(Chi-square) Map', color=255     
                                                 
FOR i=0, n_elements(heat0_interp)-2 DO BEGIN                               
  FOR j=0, n_elements(flare_dur_interp)-2 DO BEGIN                         
    x = [heat0_interp[i], heat0_interp[i], heat0_interp[i+1], heat0_interp[i+1]]                
    y = [flare_dur_interp[j], flare_dur_interp[j+1], flare_dur_interp[j+1], flare_dur_interp[j]]
    polyfill, x, y, color=colors2[i,j]                               
  ENDFOR                                                              
ENDFOR

contour, colors2, heat0_interp, flare_dur_interp, color=1, $
level=255./(mx1-min(alog10(chi1))) * (alog10(min(chi1)+chidiff)-min(alog10(chi1))), /over
cgcolorbar, /vertical, /right, position=[.14, 0.25, 0.18, 0.7], $
range=[min(alog10(chi1)),mx1], color=1

cgloadct, 3
;plot_image, delay
colors3 = floor( 255./( max(delay_interp) - min(delay_interp)) * (delay - min(delay_interp)) )
plot, [0], [0], xrange=heat0_range, yrange=duration_range, xsty=1, ysty=1, /xlog, /ylog, $
xticks=5, yticks=5, xtit='Heating', ytit='Duration', charsi=si, charthick=thick, ticklen=-0.02, $
tit='Delay Map'
FOR i=0, n_elements(heat0_interp)-2 DO BEGIN                               
  FOR j=0, n_elements(flare_dur_interp)-2 DO BEGIN                         
    x = [heat0_interp[i], heat0_interp[i], heat0_interp[i+1], heat0_interp[i+1]]                
    y = [flare_dur_interp[j], flare_dur_interp[j+1], flare_dur_interp[j+1], flare_dur_interp[j]]
    polyfill, x, y, color=colors3[i,j]                               
  ENDFOR                                                              
ENDFOR
cgcolorbar, /vertical, /right, position=[0.85, 0.25, 0.89, 0.65], $
range=delay_range, color=255
cgps_close
if keyword_set(display) then spawn, 'evince '+startstring+'chisq_heat0_duration_reopt'+endstring+'.eps &'

; HEATING vs. DELAY
cgps_open, startstring+'chisq_heat0_delay_reopt'+endstring+'.eps', /encaps, xsi=14
cgloadct, 1, /reverse
;colors2=floor(alog10(chi2)*255./mx1)
colors2=floor( 255./(mx1-min(alog10(chi2))) * (alog10(chi2)-min(alog10(chi2))) )
plot, [0], [0], xrange=heat0_range, yrange=delay_range, xsty=1, ysty=1, /xlog, /ylog, $
xticks=5, yticks=5, xtit='Heating', ytit='Delay', charsi=si, charthick=thick, ticklen=-0.02, $
tit='Log(Chi-square) Map', color=255

FOR i=0, n_elements(heat0_interp)-2 DO BEGIN                               
  FOR j=0, n_elements(delay_interp)-2 DO BEGIN                         
    x = [heat0_interp[i], heat0_interp[i], heat0_interp[i+1], heat0_interp[i+1]]                
    y = [delay_interp[j], delay_interp[j+1], delay_interp[j+1], delay_interp[j]]
    polyfill, x, y, color=colors2[i,j]                               
  ENDFOR                                                              
ENDFOR

contour, colors2, heat0_interp, delay_interp, color=1, $
level=255./(mx1-min(alog10(chi2))) * (alog10(min(chi2)+chidiff)-min(alog10(chi2))), /over
cgcolorbar, /vertical, /right, position=[.14, 0.25, 0.18, 0.7], $
range=[min(alog10(chi2)),mx1], color=1

cgloadct, 3
colors3 = floor( 255./( max(flare_dur_interp) - min(flare_dur_interp)) * (duration - min(flare_dur_interp)))
plot, [0], [0], xrange=heat0_range, yrange=delay_range, xsty=1, ysty=1, /xlog, /ylog, $
xticks=5, yticks=5, xtit='Heating', ytit='Delay', charsi=si, charthick=thick, ticklen=-0.02, $
tit='Duration Map'

FOR i=0, n_elements(heat0_interp)-2 DO BEGIN                               
  FOR j=0, n_elements(delay_interp)-2 DO BEGIN                         
    x = [heat0_interp[i], heat0_interp[i], heat0_interp[i+1], heat0_interp[i+1]]                
    y = [delay_interp[j], delay_interp[j+1], delay_interp[j+1], delay_interp[j]]
    polyfill, x, y, color=colors3[i,j]                               
  ENDFOR                                                              
ENDFOR

cgcolorbar, /vertical, /right, position=[0.85, 0.25, 0.89, 0.65], $
range=duration_range, color=255
cgps_close
if keyword_set(display) then spawn, 'evince '+startstring+'chisq_heat0_delay_reopt'+endstring+'.eps &'

; DELAY vs. DURATION
cgps_open, startstring+'chisq_delay_duration_reopt'+endstring+'.eps', /encaps, xsi=14
cgloadct, 1, /reverse
colors2=floor( 255./(mx1-min(alog10(chi3))) * (alog10(chi3)-min(alog10(chi3))) )
plot, [0], [0], xrange=delay_range, yrange=duration_range, xsty=1, ysty=1, /xlog, /ylog, $
xticks=5, yticks=5, xtit='Delay', ytit='Duration', charsi=si, charthick=thick, ticklen=-0.02, $
tit='Log(Chi-square) Map', color=255

FOR i=0, n_elements(delay_interp)-2 DO BEGIN                               
  FOR j=0, n_elements(flare_dur_interp)-2 DO BEGIN                         
    x = [delay_interp[i], delay_interp[i], delay_interp[i+1], delay_interp[i+1]]                
    y = [flare_dur_interp[j], flare_dur_interp[j+1], flare_dur_interp[j+1], flare_dur_interp[j]]
    polyfill, x, y, color=colors2[i,j]                               
  ENDFOR                                                              
ENDFOR

contour, colors2, delay_interp, flare_dur_interp, color=1, $
level=255./(mx1-min(alog10(chi3))) * (alog10(min(chi3)+chidiff)-min(alog10(chi3))), /over
cgcolorbar, /vertical, /right, position=[.39, 0.25, 0.43, 0.7], $
range=[min(alog10(chi3)),mx1], color=255

cgloadct, 3
;plot_image, delay
colors3 = floor( 255./(max(heat0_interp) - min(heat0_interp)) * (heat0 - min(heat0_interp)) )
plot, [0], [0], xrange=delay_range, yrange=duration_range, xsty=1, ysty=1, /xlog, /ylog, $
xticks=5, yticks=5, xtit='Delay', ytit='Duration', charsi=si, charthick=thick, ticklen=-0.02, $
tit='Heating Map'

FOR i=0, n_elements(delay_interp)-2 DO BEGIN                               
  FOR j=0, n_elements(delay_interp)-2 DO BEGIN                         
    x = [delay_interp[i], delay_interp[i], delay_interp[i+1], delay_interp[i+1]]                
    y = [flare_dur_interp[j], flare_dur_interp[j+1], flare_dur_interp[j+1], flare_dur_interp[j]]
    polyfill, x, y, color=colors3[i,j]                               
  ENDFOR                                                              
ENDFOR

cgcolorbar, /vertical, /right, position=[0.85, 0.25, 0.89, 0.65], $
range=heat0_range, color=255
cgps_close
if keyword_set(display) then spawn, 'evince '+startstring+'chisq_delay_duration_reopt'+endstring+'.eps &'

if keyword_set(stop) then STOP

end
