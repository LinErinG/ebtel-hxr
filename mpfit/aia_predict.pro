FUNCTION aia_predict, logtdem, dem_cm5_cor, dem_cm5_tr, length=length, $
dns_pred_aia=dns_pred_aia, scaling=scaling, instr=instr, fill=fill

default, scaling, 3   ; scaling*flux is maximum permitted
default, instr, 'foxsi'

savdir = '~/foxsi/ebtel-hxr-master/sav/'
default, length, 6d9  ; loop length in cm 

; Get observed / predicted AIA fluxes 
IF instr eq 'foxsi' THEN BEGIN
   dns_obs_aia = rd_tfile(savdir+'aia_dn_s_pixel.txt',7,-1)
   dns_obs_aia = average(float(dns_obs_aia[1:*,*]),2)
ENDIF ELSE IF instr eq 'nustar' THEN BEGIN
   restore, savdir+'aia_dn_s_pixel_nustar.sav'
   dns_obs_aia = [dns_obs_aia[0:4],dns_obs_aia[6]]
ENDIF

wave = [94, 131, 171, 193, 211, 335]
dns_pred_aia = float(wave) 

for i=0, n_elements(wave)-1 do $
dns_pred_aia[i] = dem_aia(wave[i], logtdem, length, $
dem_cor=dem_cm5_cor, dem_tr=dem_cm5_tr, fill=fill)

ratio = dns_pred_aia / dns_obs_aia 
print, 'Ratios of AIA predicted to observed are '
print, ratio
ratio_test = ratio ge scaling 

IF total(ratio_test) gt 0 THEN return, 0 ELSE return, 1

END
