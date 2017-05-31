PRO interp_aia_xrt_table, aia_xrt_file, dofill=dofill, ninds=ninds, savefile=savefile, $
log=log, stop=stop, _extra=_extra

restore, aia_xrt_file

default, ninds, 100
interp_inds = findgen(ninds+1) * 0.1  ; Indices 0.0, 0.1, ... , 9.9, 10.0
aia_table_interp = fltarr(ninds+1, ninds+1, ninds+1, n_elements(aia_table[0,0,0,*]))
xrt_table_interp = fltarr(ninds+1, ninds+1, ninds+1, n_elements(xrt_table[0,0,0,*]))

FOR ebin=0, n_elements(aia_table[0,0,0,*])-1 DO BEGIN
   if keyword_set(log) then $
      aia_table_interp[*,*,*,ebin] = interpolate(alog10(aia_table[*,*,*,ebin]), interp_inds, interp_inds, interp_inds, /grid) $
   else $
   aia_table_interp[*,*,*,ebin] = interpolate(aia_table[*,*,*,ebin], interp_inds, interp_inds, interp_inds, /grid)
ENDFOR

FOR ebin=0, n_elements(xrt_table[0,0,0,*])-1 DO BEGIN
   if keyword_set(log) then $
      xrt_table_interp[*,*,*,ebin] = interpolate(alog10(xrt_table[*,*,*,ebin]), interp_inds, interp_inds, interp_inds, /grid) $
   else $
   xrt_table_interp[*,*,*,ebin] = interpolate(xrt_table[*,*,*,ebin], interp_inds, interp_inds, interp_inds, /grid)
ENDFOR


IF keyword_set(log) THEN BEGIN
   print, 'Logarithmic interpolation'
   aia_table_interp = 10^aia_table_interp
   xrt_table_interp = 10^xrt_table_interp
ENDIF

heat0_interp_log = findgen(ninds+1) * alog10(max(heat0)/min(heat0)) / ninds + alog10(min(heat0))
heat0_interp =  10^heat0_interp_log
flare_dur_interp_log = findgen(ninds+1) * alog10(max(flare_dur)/min(flare_dur)) /ninds + alog10(min(flare_dur))
flare_dur_interp = 10^flare_dur_interp_log
delay_interp_log = findgen(ninds+1) * alog10(max(delay)/min(delay)) /ninds + alog10(min(delay))
delay_interp = 10^delay_interp_log

IF keyword_set(dofill) THEN BEGIN
   s0 = (size(aia_table_interp, /dimensions))[0]
   s1 = (size(aia_table_interp, /dimensions))[1]
   s2 = (size(aia_table_interp, /dimensions))[2]
   aia_dim3 = (size(aia_table_interp, /dimensions))[3]
   xrt_dim3 = (size(xrt_table, /dimensions))[3]
; Look at a range of filling factors
   default, nfill, 30 
   default, maxfill, 1.0
   default, minfill, 1d-4
   fill_log = [findgen(nfill+1)]*alog10(maxfill/minfill)/nfill + alog10(minfill)
   fill = 10^fill_log

   aia_table_fill_interp = fltarr(s0, s1, s2, aia_dim3, n_elements(fill))
   xrt_table_fill_interp = fltarr(s0, s1, s2, xrt_dim3, n_elements(fill))

   FOR i=0, s0-1 DO BEGIN
      FOR j=0, s1-1 DO BEGIN
         FOR k=0, s2-1 DO BEGIN
            FOR m=0, nfill DO BEGIN
               aia_table_fill_interp[i,j,k,*,m] = aia_table_fill_interp[i,j,k,*] * fill[m]
               xrt_table_fill_interp[i,j,k,*,m] = xrt_table_fill_interp[i,j,k,*] * fill[m]
            ENDFOR
         ENDFOR
      ENDFOR
   ENDFOR
ENDIF

if keyword_set(stop) then stop

if keyword_set(savefile) then $
save, heat0_interp, flare_dur_interp, delay_interp, aia_table_interp, xrt_table_interp, $
aia_table_fill_interp, xrt_table_fill_interp, file=savefile


END
