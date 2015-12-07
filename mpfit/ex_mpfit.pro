;; testing out MPFIT for our EBTEL-FOXSI-NuSTAR purposes.
;; Linz 12/6/2015


; Get the right routines ready. 
add_path, '~/local-git-repo/ebtel-idl/'				; or wherever your EBTEL codes are
add_path, 'pro'
add_path, 'mpfit'


; Retrieve the measured FOXSI-2 data to compare against.
restore, 'sav/foxsi2-d6-spex.sav'
energy = findgen(20./0.3)*0.3
measured = interpol( spec.spec_p, spec.energy_kev, energy )
err = sqrt(measured)
err[ where( err lt 1. ) ] = 1.		; getting appropriate errors seems to be key!
i = where( energy gt 5. and energy lt 10. )			; fitting only 5-10 keV


; Do the fit.  This example is ONLY fitting the filling factor.
; Arguments to MPFITFUN are [1] name of function, [2] energies to fit, 
; [3] measured values to fit, [4] errors on measured values, and [5] start value

; Run MPFIT.
param = mpfitfun('linz_testfunction', energy[i], measured[i], err[i], 1.)

; For later. We can set the constraints for the parameters.  See MPFIT doc.
;constraint = replicate({fixed:0, limited:[0,0], limits:[0.D,0.D]},4)
;constraint = {fixed:0, limited:[1,1], limits:[0.001D,1.0D]}
;param = mpfitfun('linz_testfunction', energy[i], measured[i], err[i], 1., parinfo=constraint)


; Best value for the filling factor is now in PARAM.  Rerun the function to see the 
; expected observation given this best value for the filling factor.
fill = param[0]
obs = linz_testfunction( energy[i], fill )


; Plotting to compare results with the measured values.

!p.multi=0
loadct, 0
hsi_linecolors
plot_err, energy[i], obs, yerr=sqrt(obs), /xlo, /ylo, $
	xr=[3.,30.], yr = [1.,1.e2], $
	/xsty, psym=10, xtitle='Energy [keV]', ytitle='Counts s!U-1!N keV!U-1!N', $
	charsi=ch, thick=4, $
	title='Binned count spectrum'

; overplot the FOXSI-2 observation.
oplot_err, spec.energy_kev, spec.spec_p, yerr=spec.spec_p_err/dt, psym=10, col=6, thick=4
oplot, [5.,5.], [1.,100.], line=2
oplot, [10.,10.], [1.,100.], line=2
al_legend, ['EBTEL prediction','FOXSI-2 D6 quiet AR','Fit region'], line=0, $
	col=[0,6,0], /right, box=0
