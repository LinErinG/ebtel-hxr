PRO plot_params_reopt_twoframe_nustar, all_limits=all_limits, display=display, region=region, $
stop=stop

ids=['D1','D2','L1', 'L2', 'L3']

if region eq 3 then lengthstr='100Mm' else lengthstr='70Mm'
if region ge 2 then addstring='_coronal' else addstring='' 
restore, 'nustar'+ids[region]+'_obs_table_'+lengthstr+'_interp_stats_delay10000'+addstring+'_log_norm.sav', /v
; Range of three parameters
heat0_range =  [min(heat0_interp), max(heat0_interp)]
duration_range = [min(flare_dur_interp),max(flare_dur_interp)]
delay_range = [min(delay_interp),max(delay_interp)]

if keyword_set(all_limits) then limstring='_all_limits' else limstring=''
restore, 'nustar'+ids[region]+'_reopt_maps_delay10000'+addstring+'_log_norm'+limstring+'.sav', /v 
startstring='nustar'+ids[region]+'_'
endstring='_delay10000'+addstring+'_double'+limstring
!p.multi=[0,2,1]
mx1 = max(alog10(chi1))

; HEATING vs. DURATION
cgps_open, startstring+'chisq_heat0_duration_reopt'+endstring+'.eps', /encaps, xsi=4
cgloadct, 1, /reverse
colors2=floor(alog10(chi1)*255./mx1)
plot, [0], [0], xrange=heat0_range, yrange=duration_range, xsty=1, ysty=1, /xlog, /ylog, $
xticks=5, yticks=5, xtit='Heating', ytit='Duration', charsi=si, charthick=thick, ticklen=-0.02, $
tit='Chi-square Map', color=255
FOR i=0, n_elements(heat0_interp)-2 DO BEGIN                               
  FOR j=0, n_elements(flare_dur_interp)-2 DO BEGIN                         
    x = [heat0_interp[i], heat0_interp[i], heat0_interp[i+1], heat0_interp[i+1]]                
    y = [flare_dur_interp[j], flare_dur_interp[j+1], flare_dur_interp[j+1], flare_dur_interp[j]]
    polyfill, x, y, color=colors2[i,j]                               
  ENDFOR                                                              
ENDFOR
contour, colors2, heat0_interp, flare_dur_interp, level=alog10(min(chi1)+6.25)*255./mx1, /over
xyouts, 0.4, 0.8, ids[region], /normal, color=0

cgloadct, 3
colors3 = floor(delay*255./10000.)
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
xyouts, 0.9, 0.8, ids[region], /normal, color=255
cgps_close
if display then spawn, 'evince ' + startstring+'chisq_heat0_duration_reopt'+endstring+'.eps &'

; HEATING vs. DELAY
cgps_open, startstring+'chisq_heat0_delay_reopt'+endstring+'.eps', /encaps, xsize=14
cgloadct, 1, /reverse
colors2=floor(alog10(chi2)*255./mx1)
plot, [0], [0], xrange=heat0_range, yrange=delay_range, xsty=1, ysty=1, /xlog, /ylog, $
xticks=5, yticks=5, xtit='Heating', ytit='Delay', charsi=si, charthick=thick, ticklen=-0.02, $
tit='Chi-square Map', color=255
                                                                  
FOR i=0, n_elements(heat0_interp)-2 DO BEGIN                               
  FOR j=0, n_elements(delay_interp)-2 DO BEGIN                         
    x = [heat0_interp[i], heat0_interp[i], heat0_interp[i+1], heat0_interp[i+1]]                
    y = [delay_interp[j], delay_interp[j+1], delay_interp[j+1], delay_interp[j]]
    polyfill, x, y, color=colors2[i,j]                               
  ENDFOR                                                              
ENDFOR
contour, colors2, heat0_interp, delay_interp, level=alog10(min(chi2)+6.25)*255./mx1, /ove
xyouts, 0.4, 0.8, ids[region], /normal, color=0

cgloadct, 3
colors3 = floor(duration*255./500.)
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
xyouts, 0.9, 0.8, ids[region], /normal, color=255
;cgcolorbar, /fit, range=[500, 10000]
cgps_close
if display then spawn, 'evince '+ startstring+'chisq_heat0_delay_reopt'+endstring+'.eps &'

; DELAY vs. DURATION
cgps_open, startstring+'chisq_delay_duration_reopt'+endstring+'.eps', /encaps, xsize=14
cgloadct, 1, /reverse
colors2=floor(alog10(chi3)*255./mx1)
plot, [0], [0], xrange=delay_range, yrange=duration_range, xsty=1, ysty=1, /xlog, /ylog, $
xticks=5, yticks=5, xtit='Delay', ytit='Duration', charsi=si, charthick=thick, ticklen=-0.02, $
tit='Chi-square Map', color=255

FOR i=0, n_elements(delay_interp)-2 DO BEGIN                               
  FOR j=0, n_elements(flare_dur_interp)-2 DO BEGIN                         
    x = [delay_interp[i], delay_interp[i], delay_interp[i+1], delay_interp[i+1]]                
    y = [flare_dur_interp[j], flare_dur_interp[j+1], flare_dur_interp[j+1], flare_dur_interp[j]]
    polyfill, x, y, color=colors2[i,j]                               
  ENDFOR                                                              
ENDFOR
contour, colors2, delay_interp, flare_dur_interp, level=alog10(min(chi3)+6.25)*255./mx1, /over
xyouts, 0.4, 0.8, ids[region], /normal, color=0

cgloadct, 3
colors3 = floor(heat0*255./0.5)
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
xyouts, 0.9, 0.8, ids[region], /normal, color=255
;cgcolorbar, /fit, range=[500, 10000]
cgps_close
if display then spawn, 'evince ' + startstring+'chisq_delay_duration_reopt'+endstring+'.eps &'
if keyword_set(stop) then STOP


end
