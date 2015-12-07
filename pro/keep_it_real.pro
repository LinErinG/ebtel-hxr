;+
;
; This function adds in all the dirty business of the real world by 
; "smearing" values a little, and use coarser bins and varying the counts 
; using Poisson statistics.  It's provided as a separate function so 
; that the user doesn't have to keep it real if they don't want to.
;
;-

FUNCTION	KEEP_IT_REAL, energy, counts, energy_coarse, binsize=binsize, fwhm=fwhm, $
												stop=stop

	default, fwhm, 0.5			; energy resolution
	default, binsize, 0.3		; energy bin size

	; Smear by energy resolution of 0.5 keV.
	nBin = n_elements( energy )
	energy_wid = average( deriv(energy) )
	sigma = fwhm / 2.355
	smeared = fltarr( n_elements( counts ) )
	; This line calculates a Gaussian that has a mean of the energy bin of interest, 
	; integrates to 1, and has the desired width.  Then we multiply that Gaussian by the
	; measured count array to "smear" the measured energies.
	; This doesn't integrate to 1 at the edges of the energy range, but that's fine since
	; it will mimic the energy resolution of the threshold.
	for i=0, nBin-1 do smeared += $
		counts[i]*gaussian( findgen(nBin), [0.3989*energy_wid/sigma,i,sigma/energy_wid] )

	; coarser energy bins.
	energy_coarse = findgen(20./binsize)*binsize
	observation = interpol( smeared, energy, energy_coarse)
	
	if keyword_set( stop ) then stop

	return, observation
	
END