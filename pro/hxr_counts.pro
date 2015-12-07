FUNCTION	HXR_COUNTS, energy, hxr, instr=instr, stop=stop, effarea=effarea

	if instr eq 'FOXSI2' or instr eq 'foxsi2' then file='data/foxsi2-d6-effarea.txt'
	if instr eq 'SMEX' or instr eq 'smex' then file='data/foxsi-smex-effarea.txt'
	if instr eq 'NUSTAR' or instr eq 'nustar' then file='data/nustar_fpma_eff.txt'
	
	dat = read_ascii( file, data_start=2 )
	
	; get everybody's energy arrays on the same page.
	instr_area = interpol( reform(dat.field1[1,*]), reform(dat.field1[0,*]), energy )
	count_rate = hxr
	nT = (size(hxr))[1]
	for i=0, nT-1 do count_rate[i,*] *= instr_area
	
	if keyword_set( stop ) then stop
	
	effarea = instr_area

	return, count_rate
	
END