PRO plot_stat_intensity_aia_xrt_limits

restore, 'foxsi_obs_table_interp_stats_nfill.sav', /v

heat0_range =  [min(heat0_interp), max(heat0_interp)]
duration_range = [min(flare_dur_interp),max(flare_dur_interp)]
delay_range = [min(delay_interp),max(delay_interp)]

si=1.8
thick=2

; HEATING VS. DURATION
; Set up color table
a1 = alog10(reform(obs_chisq_fill_interp[*,*,72,25]))
colors1 = floor(a1*255./max(a1))
; Determine parameter space exclusion from AIA & XRT
xaia = min(where(aia_ratio[*,0,72,25] eq 0))
yaia = min(where(aia_ratio[0,*,72,25] eq 0))
xxrt = min(where(xrt_ratio[*,0,72,25] eq 0))
yxrt = min(where(xrt_ratio[*,100,72,25] eq 0))

; Plot chi-squared intensity map
cgps_open, 'obs_chisq_interp_heat0_duration_aia_xrt.eps', /encaps
cgloadct, 1, /reverse
;window, 0, retain=2
plot, [0], [0], xrange=heat0_range, yrange=duration_range, xsty=1, ysty=1, /xlog, /ylog, $
xticks=5, yticks=5, xtit='Heating', ytit='Duration', charsi=si, charthick=thick, color=255, $
ticklen=-0.02

;.r                                                                  
for i=0, n_elements(heat0_interp)-2 do begin                               
  for j=0, n_elements(flare_dur_interp)-2 do begin                         
    x = [heat0_interp[i], heat0_interp[i], heat0_interp[i+1], heat0_interp[i+1]]                
    y = [flare_dur_interp[j], flare_dur_interp[j+1], flare_dur_interp[j+1], flare_dur_interp[j]]
    polyfill, x, y, color=colors1[i,j]                               
  endfor                                                              
endfor
;end

oplot, [heat0_interp[xaia],heat0_interp[0]], [flare_dur_interp[0],flare_dur_interp[yaia]],$
color=255, linest=0, thick=3  ; AIA 
oplot, [heat0_interp[xxrt],heat0_interp[0]], [flare_dur_interp[yxrt],flare_dur_interp[100]],$
color=255, linest=2, thick=3  ; XRT

xyouts, 0.3, 0.3, 'Allowed', /normal, charsi=1.5, charthick=2, color=255
xyouts, 0.6, 0.5, 'Excluded', /normal, charsi=1.5, charthick=2, color=255

cgps_close

; HEATING VS. DELAY
; Set up color table
a1 = alog10(reform(obs_chisq_fill_interp[*,97,*,25]))
colors1 = floor(a1*255./max(a1))
; Determine parameter space exclusion from AIA & XRT
xaia = min(where(reform(aia_ratio[*,97,100,25]) eq 0))
yaia = min(where(reform(aia_ratio[0,97,*,25]) eq 1))
xxrt = min(where(reform(xrt_ratio[*,97,100,25]) eq 0))
yxrt = min(where(reform(xrt_ratio[0,97,*,25]) eq 1))

; Plot chi-squared intensity map
cgps_open, 'obs_chisq_interp_heat0_delay_aia_xrt.eps', /encaps
cgloadct, 1, /reverse
;window, 0, retain=2
plot, [0], [0], xrange=heat0_range, yrange=delay_range, xsty=1, ysty=1, /xlog, /ylog, xticks=5, $
yticks=5, xtit='Heating', ytit='Delay',charsi=si, charthick=thick, color=255

;.r                                                                  
for i=0, n_elements(heat0_interp)-2 do begin                               
  for j=0, n_elements(delay_interp)-2 do begin                         
    x = [heat0_interp[i], heat0_interp[i], heat0_interp[i+1], heat0_interp[i+1]]
    y = [delay_interp[j], delay_interp[j+1], delay_interp[j+1], delay_interp[j]]
    polyfill, x, y, color=colors1[i,j]                               
  endfor                                                              
endfor
;end

oplot, [heat0_interp[xaia],heat0_interp[0]], [delay_interp[100],delay_interp[yaia]],$
color=255, linest=0, thick=3  ; AIA 
oplot, [heat0_interp[xxrt],heat0_interp[0]], [delay_interp[100],delay_interp[yxrt]],$
color=255, linest=2, thick=3  ; XRT

xyouts, 0.21, 0.85, 'Allowed', /normal, charsi=0.7, charthick=2, color=255
xyouts, 0.4, 0.6, 'Excluded', /normal, charsi=1.5, charthick=2, color=255

cgps_close

; DELAY VS. DURATION
; ALL ZEROES! No need to make a new plot 
