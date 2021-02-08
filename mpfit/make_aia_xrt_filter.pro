PRO make_aia_xrt_filter, table_file, ninds=ninds, nfill=nfill, savefile=savefile

restore, table_file
savdir = '~/foxsi/ebtel-hxr-master/sav/'
dns_obs_aia = rd_tfile(savdir+'aia_dn_s_pixel.txt',7,-1)
dns_obs_aia = average(float(dns_obs_aia[1:*,*]),2)
dns_obs_xrt = rd_tfile(savdir+'xrt_dn_s_pixel.txt',2,-1) 
dns_obs_xrt = transpose(dns_obs_xrt[1,*])

default, ninds, 100
default, nfill, 30
aia_filter = fltarr(ninds+1, ninds+1, ninds+1, nfill+1)
xrt_filter = aia_filter

;.r
FOR i=0, 100 DO BEGIN
  FOR j=0, 100 DO BEGIN
     FOR k=0, 100 DO BEGIN
        FOR m=0, 30 DO BEGIN
           aia_filter[i,j,k,m] = 1 - ( total(aia_table_fill_interp[i,j,k,*,m] / dns_obs_aia ge 3) ge 1 )
           xrt_filter[i,j,k,m] = 1 - ( total(xrt_table_fill_interp[i,j,k,*,m] / dns_obs_xrt ge 3) ge 1 )
       ENDFOR
     ENDFOR
  ENDFOR
ENDFOR
;end

if keyword_set(savefile) then save, aia_filter, xrt_filter, file=savefile


end
