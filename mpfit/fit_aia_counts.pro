; Download AIA data
; start/end of NuSTAR P1
;cd, '~/nustar/solar/obs2/aia_orb1/'
;t1=' 1-Nov-2014 21:34:49'
;t2=anytim(anytim(t1)+790,/yoh,/trunc)
;v = vso_search(t1, t2, instr='aia', wave='94-335')
;vg = vso_get(v)
; Convert to Level 1.5 
;files = file_search('*.fits')
;aia_prep, files, -1, /do_write_fits

; Get spatial regions of NuSTAR AR spectra  
restore, file='~/nustar/solar/20141101_data/nsigh_nov14-master/out_files/roi_no14.dat', /v
print, xcsp, ycsp, wid
nr = n_elements(rnm)
aia_dir = '~/nustar/solar/obs2/aia_orb1/'
wave = ['94', '131', '171', '193', '211', '304', '335'] ;AIA EUV wavelengths
dns_obs_aia = fltarr(nr, n_elements(wave))
dn_obs  = fltarr(n_elements(wave))
exptime = fltarr(n_elements(wave)) 
nf = fltarr(n_elements(wave)) 

.r
FOR region=0, 4 DO BEGIN
   xrange=xcsp[region]+0.5*wid*[-1,1]
   yrange=ycsp[region]+0.5*wid*[-1,1]

; Obtain observed AIA counts in spectral region of interest during
; integrated observation time 
   FOR i=0, n_elements(wave)-1 DO BEGIN
      afiles = file_search(aia_dir+'AIA*'+wave[i]+'.fits') ; Use Level 1.5 
                                ; Read in one full file 
      read_sdo, afiles[0], index, data
; Convert x, y range to AIA pixel values using header
      xc_pix = round(index(0).crpix1-1)
      yc_pix = round(index(0).crpix2-1)
      aia_pix_size = index(0).cdelt1
      pixx = round( xc_pix + xrange / aia_pix_size )
      pixy = round( yc_pix + yrange / aia_pix_size )
      print, pixx, pixy 
;Read in remaining files, AR field-of-view only
      read_sdo, afiles, index, data, min(pixx), min(pixy), max(pixx)-min(pixx), max(pixy)-min(pixy)
      nf[i] = (size(data))[3]
      exptime[i] = total(index.exptime)
      dn_obs[i] = total(data)
   ENDFOR
   stop
   dns_obs_aia[region,*] = dn_obs / exptime / (max(pixx)-min(pixx)) / (max(pixy)-min(pixy))
ENDFOR
end

save, dns_obs_aia, file='~/foxsi/ebtel-hxr-master/sav/aia_dn_s_pixel_nustar_regions.sav'



; Calculate predicted AIA counts in spectral region of interest during
; integrated observation time
; Generate DEM with EBTEL 
heat0 = 0.025
fill  = 1
flare_dur = 200
length = 1d9
scale_height = 5.e9
solar_dx_arcsec = 120.		; Diameter of solar area of interest.
pix_cm  = solar_dx_arcsec*0.725d8
dem_cm5 = run_ebtel( time, heat0=heat0, length=length, t_heat=flare_dur, te=te,$
                      dens=dens, logtdem=logtdem, dem_cm5_cor=dem_cm5_cor )
dem_cm5 *= fill
dem_cm5_cor *= fill
dem_cm5_tr = dem_cm5 - dem_cm5_cor 
; em_cm3 = dem_cm5_cor * pix_cm^2 * scale_height / (2 * length) + 0.5 * dem_cm5_tr * pix_cm^2

; Get AIA temperature response for each channel 
aiatresp_dn = aia_get_response(/dn, /temp)   ; DN cm^5 s^-1 pix^-1
logte = aiatresp_dn.a94.logte
tresp = transpose( [[aiatresp_dn.a94.tresp], [aiatresp_dn.a131.tresp], [aiatresp_dn.a171.tresp], $
[aiatresp_dn.a193.tresp], [aiatresp_dn.a211.tresp], [aiatresp_dn.a304.tresp], [aiatresp_dn.a335.tresp]] )

; Calculate predicted flux in each region 
dn_pred = dn_obs
.r
FOR i=0, n_elements(wave)-1 DO BEGIN
tresp_interp = interpol(tresp[i,*], logte, logtdem) ; Use same logT bins for DEM and AIA response 
dn_pred[i] = total( tresp_interp * dem_cm5  * alog(10) * 10^logtdem * (logtdem[1]-logtdem[0]) * exptime[i] * (max(pixx)-min(pixx)) * (max(pixy)-min(pixy)) )
ENDFOR
end

print, dn_pred 

save, tresp, logte, logtdem, dem_cm5, exptime, dn_obs, dn_pred, $
      file='fit_aia_counts_nustar_'+strtrim(ids[region],2)+'.sav'

; Plot ratio of predicted to observed counts 
cgps_open, filename='ratio_aia_pred_obs.eps', /encaps
plot, findgen(n_elements(wave)), dn_pred/dn_obs, psym=5, yr=[0.1, 10], /ylog, $
thick=3, xstyle=4, xtitle='AIA Channel', ytitle='Predicted / Observed DNs', ycharsi=0.8
axis, xaxis=0, xtickna=['94', '131', '171', '193', '211', '304', '335'], $
xrange=[0, n_elements(wave)+1], xticks=6, xtitle='AIA Channel', xcharsi=0.8
axis, /xaxis, xrange=[0, n_elements(wave)+1], xtickformat="(A1)"
cgps_close

