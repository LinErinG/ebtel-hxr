;
; lines to write an ASCII file with effective areas (from SAV file)
;


restore, 'sav/foxsi-smex-effarea.sav'
openw, lun2, 'foxsi-smex-effarea.txt', /get_lun
printf, lun2, 'FOXSI SMEX effective area, Dec. 6, 2015'
printf, lun2, '     kev     cm2'
for i=0, 2999 do printf, lun2, area.energy_kev[i], area.eff_area_cm2[i]
close, lun2
free_lun, lun2
spawn, 'open foxsi-smex-effarea.txt'


restore, 'sav/foxsi2-d6-effarea.sav'
openw, lun2, 'foxsi2-d6-effarea.txt', /get_lun
printf, lun2, 'FOXSI-2 detector 6 effective area, Dec. 6, 2015'
printf, lun2, '     kev     cm2'
for i=0, 199 do printf, lun2, area.energy_kev[i], area.eff_area_cm2[i]
close, lun2
free_lun, lun2
spawn, 'open foxsi2-d6-effarea.txt'
