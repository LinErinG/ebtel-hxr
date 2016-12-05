PRO find_chisq_params_foxsi, delay=delay, save=save

;Goal - Determine parameter space, for fixed Length & Fill, in which
;       the EBTEL fit to FOXSI data has chi-squared less than a
;       particular value . Will want to convert this to a
;       probability 

; Restore FOXSI AR count spectra, in counts/keV
 restore, '~/foxsi/ebtel-hxr-master/sav/foxsi2-d6-spex.sav', /v
 erange = [5, 10]
 e = where( spec.energy_kev gt min(erange) and spec.energy_kev lt max(erange) and $
          spec.spec_p gt 0)

; Four different values of fill
; fill = [1, 1/5., 1/25., 1/125.]
; fill_ind = 1
fill = [1, 1/2., 1/5., 1/10.]
fill_ind = 2
; Fix the length
 length = 2d9  ;AIA quick fit for NuSTAR region D2 
; length = 9d9  ;AIA quick fit for NuSTAR region D1

; Don't have to do a fit, just need to calculate chi^2 for a
; large number of values of flare_dur, heat
 heat0 = [findgen(50)+1]*2d-3
 flare_dur = [findgen(50)+1]*10
 default, delay, []  ; Change impulsive heating frequency 

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
          obs = foxsi_testfunction( spec.energy_kev, param, delay=delay)  ;Calculate spectrum
          chisq[i,j,k] = total( (spec.spec_p[e]-obs[e])^2 / spec.spec_p[e] ) ; Calculate chi-squared
       ENDFOR
    ENDFOR
 ENDFOR
; end


chisq_tot = chisq
IF keyword_set(save) THEN BEGIN
   if keyword_set(delay) then $
      save, chisq_tot, file='chisq_params_foxsi'+strtrim(fill_ind,2)+'_delay'+strtrim(fix(delay),2)+'.sav', /verbose else $
      save, chisq_tot, file='chisq_params_foxsi'+strtrim(fill_ind,2)+'.sav', /verbose
ENDIF


END
