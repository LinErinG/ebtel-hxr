FUNCTION HXR_COUNTS_2D, energy, hxr, instr=instr, response=response, main_dir=main_dir, $
region=region, stop=stop

default, main_dir, '~/foxsi/ebtel-hxr-master/'

count_rate = hxr
nT = (size(hxr))[1]

if instr eq 'FOXSI2' or instr eq 'foxsi2' or instr eq 'foxsi' then begin
   file=main_dir+'data/foxsi2_det6_E2.0-21.9_b0.1_resp.sav'
   restore, file, /v
   response = nondiag
endif
if instr eq 'NUSTAR' or instr eq 'nustar' then begin
   if ~keyword_set(region) then begin
      print, "Region D1 used by default" 
      region = 0
   endif
   ids=['D1','D2','L1','L2','L3']
   print, "Using Region "+ids[region]
   file=file_search(main_dir+'data/*'+ids[region]+'*.dat')
   restore, file, /v
   response = rsp
endif

if n_elements(size(hxr,/dimensions)) gt 1 then $
for i=0,nT-1 do count_rate[i,*] = response##count_rate[i,*] else $
count_rate = response##count_rate

if keyword_set( stop ) then stop

return, count_rate

END
