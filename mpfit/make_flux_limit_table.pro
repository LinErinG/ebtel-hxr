PRO make_flux_limit_table, obs_table_file=obs_table_file, length=length, $
savefile=savefile

restore, obs_table_file

default, length, 6d9

flux_limit_interp = fltarr(size(obs_table_fill_interp[*,*,*,0], /dim))

FOR i=0, n_elements(heat0_interp)-1 DO BEGIN
   FOR j=0, n_elements(flare_dur_interp)-1 DO BEGIN
      FOR k=0, n_elements(delay_interp)-1 DO BEGIN
         F = 0.5 * heat0_interp[i] * flare_dur_interp[j] * length / delay_interp[k]
         IF F lt 1d8 THEN flux_limit_interp[i,j,k] = 1  ; is 0 by default
      ENDFOR
   ENDFOR
ENDFOR

save, heat0_interp, flare_dur_interp, delay_interp, flux_limit_interp, $
file=savefile


end
