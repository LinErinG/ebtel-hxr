PRO find_chisq_params_nustar, region=region, delay=delay, save=save

;Goal - Determine parameter space, for fixed Length & Fill, in which
;       the EBTEL fit to NuSTAR data has chi-squared less than a
;       particular value. Will want to convert this to a
;       probability 

; Restore NuSTAR AR count spectra, in counts/s/keV
 restore, '~/foxsi/ebtel-hxr-master/sav/O4P1G0_FPMA.dat', /v
 erange = [2.5, 5]
 default, region, 0  ; ids[region] gives region name
 print, 'Using NuSTAR Region '+ids[region]
 e = where( engs gt min(erange) and engs lt max(erange) and counts_flux[region,*] gt 0)

; Four different values of fill
; fill = [1, 1/5., 1/25., 1/125.]  
; fill_ind = 1
 fill = [1, 1/2., 1/5., 1/10.]
 fill_ind = 2
 ; Fix the length
 length = 2d9  ;AIA quick fit for region D2 
; length = 9d9  ;AIA quick fit for region D1

; Don't have to do a fit, just need to calculate chi^2 for a
; large number of values of flare_dur, heat
 heat0 = [findgen(50)+1]*2d-3
 flare_dur = [findgen(50)+1]*10
 default, delay, [] ; Change impulsive heating frequency 

 param = fltarr(4)
 param[3] = length

 chisq = fltarr(n_elements(fill), n_elements(heat0), n_elements(flare_dur))
; .run ebtel2

; .r
; Loop over fill factor 
 FOR i=0, n_elements(fill)-1 DO BEGIN
    param[1] = fill[i]
    ; Loop over heat input
    FOR j=0,n_elements(heat0)-1 DO BEGIN
       param[0] = heat0[j]
       ; Loop over flare duration
       FOR k=0, n_elements(flare_dur)-1 DO BEGIN
          param[2] = flare_dur[k]
          obs = nustar_testfunction( engs, param, delay=delay)  ;Calculate spectrum
          chisq[i,j,k] = total( (counts_flux[region,e]-obs[e])^2 / (counts_flux[region,e]/(dur*lvt)/(engs[1]-engs[0])) ) ; Calculate chi-squared
          print, 'Chi squared = '+strtrim(chisq[i,j,k],2)
       ENDFOR
    ENDFOR
 ENDFOR
; end

 chisq_tot = chisq
 IF keyword_set(save) THEN BEGIN
    if keyword_set(delay) then $
       save, chisq_tot, file='chisq_params_nustar'+strtrim(fill_ind,2)+'_'+strtrim(ids[region], 2)+'_delay'+strtrim(fix(delay),2)+'.sav', /verbose else $
       save, chisq_tot, file='chisq_params_nustar'+strtrim(fill_ind,2)+'_'+strtrim(ids[region], 2)+'.sav', /verbose
 ENDIF

END
