FUNCTION xrt_predict, logtdem, dem_cm5_cor, dem_cm5_tr, length=length, $
dns_pred_xrt=dns_pred_xrt, scaling=scaling, fill=fill, _extra=_extra

default, scaling, 3   ; scaling*flux is maximum permitted
default, fill, 1.0

savdir = '~/foxsi/ebtel-hxr-master/sav/'
default, length, 6d9  ; loop length in cm
 
; Get observed / predicted XRT fluxes 
dns_obs_xrt = rd_tfile(savdir+'xrt_dn_s_pixel.txt',2,-1) 
restore, savdir+'XRT_Response.sav';, /v
dns_pred_xrt = fltarr(n_elements(filter_list))

for j=0, n_elements(filter_list)-1 do $
dns_pred_xrt[j] = dem_xrt(filter_list[j], logtdem, length, $
dem_cor=dem_cm5_cor, dem_tr=dem_cm5_tr, fill=fill, _extra=_extra)

ratio = dns_pred_xrt / dns_obs_xrt[1,*]
print, 'Ratios of XRT predicted to observed are '
print, ratio
ratio_test = ratio ge scaling

IF total(ratio_test) gt 0 THEN return, 0 ELSE return, 1

END
