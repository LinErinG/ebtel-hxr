PRO foxsi_chisq_plus, npix=npix, delay=delay, length=length, save=save

; Restore FOXSI AR count spectra, in counts/keV
 restore, '~/foxsi/ebtel-hxr-master/sav/foxsi2-d6-spex.sav', /v
 erange = [5, 10]
 e = where( spec.energy_kev gt min(erange) and spec.energy_kev lt max(erange) and spec.spec_p gt 0)
 energy = findgen(150.)*0.1

; fill = [1, 1/5., 1/25., 1/125.]
; fill_ind = 1
 fill = [1, 1/2., 1/5., 1/10.]
 fill_ind = 2
 default, length, 2d9  ;AIA quick fit for NuSTAR region D2 
; length = 9d9  ;AIA quick fit for NuSTAR region D1

 default, npix, 50
 heat0 = [findgen(npix)+1]*2d-3*(50./npix)
 flare_dur = [findgen(npix)+1]*10*(50./npix)
 default, delay, 10000

 param = fltarr(4)
 param[3] = delay

 chisq = fltarr(n_elements(fill), n_elements(heat0), n_elements(flare_dur))
 aia_filter = chisq 
 xrt_filter = chisq
; .run ebtel2

; .r
 FOR i=0, n_elements(fill)-1 DO BEGIN  ; Loop over fill factor 
    param[1] = fill[i]
    FOR j=0, npix-1 DO BEGIN  ; Loop over heat input
       param[0] = heat0[j]
       FOR k=0, npix-1 DO BEGIN  ; Loop over flare duration
          param[2] = flare_dur[k]

          obs = foxsi_testfunction( energy, param, length=length, logtdem=logtdem,$
          dem_cm5_tr=dem_cm5_tr, dem_cm5_cor=dem_cm5_cor, /ebtelplus)

          obs_coarse = spec.spec_p

          for n=0,(n_elements(obs)-10)/10.-1 do obs_coarse[n] = average(obs[n*10:n*10+10])

          aia_filter[i,j,k] = aia_predict(logtdem, dem_cm5_cor, dem_cm5_tr, dns_pred_aia=dns_pred_aia)

          xrt_filter[i,j,k] = xrt_predict(logtdem, dem_cm5_cor, dem_cm5_tr, dns_pred_xrt=dns_pred_xrt)

          chisq[i,j,k] = total( (spec.spec_p[e]*ratio-obs_coarse[e])^2 / spec.spec_p[e]*ratio )
       ENDFOR
    ENDFOR
 ENDFOR
; end

 chisq_tot = chisq
 IF keyword_set(save) THEN $
 save, chisq_tot, aia_filter, xrt_filter, file='chisq_plus_foxsi'+strtrim(fill_ind,2)+'_delay'+strtrim(fix(delay),2)+'_new.sav', /verbose 


END
