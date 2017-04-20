FUNCTION HXR_COUNTS_2D, energy, hxr, instr=instr, response=response, main_dir=main_dir, $
region=region, stop=stop

default, main_dir, '~/foxsi/ebtel-hxr-master/'

count_rate = hxr
nT = (size(hxr))[1]

IF instr eq 'FOXSI2' or instr eq 'foxsi2' or instr eq 'foxsi' THEN BEGIN
   file=main_dir+'data/foxsi2_det6_E2.0-21.9_b0.1_resp.sav'
   restore, file
   response = nondiag
   if n_elements(size(hxr,/dimensions)) gt 1 then $
      for i=0,nT-1 do count_rate[i,*] = response##count_rate[i,*] else $
         count_rate = response##count_rate
ENDIF

IF instr eq 'NUSTAR' or instr eq 'nustar' THEN BEGIN
   IF ~keyword_set(region) THEN BEGIN
      print, "Region D1 used by default" 
      region = 0
   ENDIF
   ids=['D1','D2','L1','L2','L3']
   print, "Using Region "+ids[region]
   file=file_search(main_dir+'data/*'+ids[region]+'*004.dat')
   restore, file
   response = rsp
   e = get_edges(edges, /mean)

   IF n_elements(e) ne n_elements(energy) THEN BEGIN $
      new_rate = fltarr(nT, n_elements(e))
      for i=0,nT-1 do new_rate[i,*] = interpol(count_rate[i,*], energy, e)
      count_rate = new_rate
   ENDIF

   if n_elements(size(hxr,/dimensions)) gt 1 then $
      for i=0,nT-1 do count_rate[i,*] = response#reform(count_rate[i,*]) else $
         count_rate = response#count_rate
ENDIF


if keyword_set( stop ) then stop

return, count_rate

END
