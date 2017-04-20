PRO calc_stats_obs_table, obs_table, obs_chisq=obs_chisq, obs_likel=obs_likel, $
dofill=dofill, nfill=nfill, minfill=minfill, maxfill=maxfill, fill=fill, $
obs_table_fill=obs_table_fill, inst=inst, region=region

IF inst eq 'foxsi' THEN BEGIN
restore, '~/foxsi/ebtel-hxr-master/sav/foxsi2-d6-spex.sav', /v
earray = spec.energy_kev
sarray = spec.spec_p*ratio
efactor = 1
erange = [5,10]
; Chisq
ec = where(earray ge min(erange) and earray le max(erange) and sarray gt 0)
ENDIF ELSE IF inst eq 'nustar' THEN BEGIN
restore, '~/foxsi/ebtel-hxr-master/sav/O4P1G0_FPMA.dat', /v
default, region, 0
print, 'NuSTAR region is '+ids[region]
earray = engs
sarray = counts_flux[region,*]
efactor = (dur*lvt)*(engs[1]-engs[0])
erange = [2.5,5]
; Chisq
ec = where(earray ge min(erange) and earray le max(erange) and sarray gt 0)
ENDIF

s0 = (size(obs_table, /dimensions))[0]
s1 = (size(obs_table, /dimensions))[1]
s2 = (size(obs_table, /dimensions))[2]
s3 = (size(obs_table, /dimensions))[3]

; Look at a range of filling factors
IF keyword_set(dofill) THEN BEGIN
default, nfill, 30 
default, maxfill, 1.0
default, minfill, 1d-4
fill_log = [findgen(nfill+1)]*alog10(maxfill/minfill)/nfill + alog10(minfill)
fill = 10^fill_log

obs_table_fill = fltarr(s0, s1, s2, s3, n_elements(fill))

FOR i=0, s0-1 DO BEGIN
   FOR j=0, s1-1 DO BEGIN
      FOR k=0, s2-1 DO BEGIN
         FOR m=0, nfill DO BEGIN
               obs_table_fill[i,j,k,*,m] = obs_table[i,j,k,*] * fill[m]
         ENDFOR
      ENDFOR
   ENDFOR
ENDFOR

ENDIF

IF keyword_set(dofill) THEN BEGIN
   obs_chisq = fltarr(s0, s1, s2, n_elements(fill))
   obs_likel = obs_chisq
ENDIF ELSE BEGIN
   obs_chisq = fltarr(s0, s1, s2)
   obs_likel = obs_chisq
ENDELSE   

FOR i=0, s0-1 DO BEGIN
   FOR j=0, s1-1 DO BEGIN
      FOR k=0, s2-1 DO BEGIN
         IF keyword_set(dofill) THEN BEGIN
            FOR m=0, nfill DO BEGIN
         obs_chisq[i,j,k,m] = total( (sarray[ec]-obs_table_fill[i,j,k,ec,m])^2 / (sarray[ec]/efactor))
         print, 'Observed Counts = ' 
         print, transpose(sarray[ec])
         print, 'Model Counts = '
         print, transpose(obs_table_fill[i,j,k,ec,m])
         print, 'Chi-squared = '
         print, obs_chisq[i,j,k,m]
            ENDFOR
         ENDIF ELSE $
            obs_chisq[i,j,k] = total( (sarray[ec]-obs_table[i,j,k,ec])^2 / (sarray[ec]/efactor))
      ENDFOR
   ENDFOR
ENDFOR

; Likelihood
el = where(earray ge min(erange) and earray le max(erange))
restore, '~/poisson/poissontable3.sav'

FOR i=0, s0-1 DO BEGIN
   FOR j=0, s1-1 DO BEGIN
      FOR k=0, s2-1 DO BEGIN
         IF keyword_set(dofill) THEN BEGIN
         FOR m=0, nfill DO BEGIN
            ptot = 1
            FOR l=0, n_elements(el)-1 DO BEGIN
               p = poisson_table(obs_table_fill[i,j,k,el[l],m] * efactor, sarray[el[l]] * efactor,$ 
               ploose=ploose, pfine=pfine)
               ptot *= p
            ENDFOR
            obs_likel[i,j,k,m] = ptot
         ENDFOR
         ENDIF ELSE BEGIN
            ptot = 1
            FOR l=0, n_elements(el)-1 DO BEGIN
               p = poisson_table(obs_table[i,j,k,el[l]] * efactor, sarray[el[l]] * efactor,$ 
               ploose=ploose, pfine=pfine)
               ptot *= p
            ENDFOR
            obs_likel[i,j,k] = ptot
         ENDELSE
      ENDFOR
   ENDFOR
ENDFOR

;save, obs_table_fill, obs_likel, obs_chisq, file='foxsi_obs_table_stats_nfill.sav'

end
