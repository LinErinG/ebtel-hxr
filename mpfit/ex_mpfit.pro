;; testing out MPFIT for our EBTEL-FOXSI-NuSTAR purposes.
;; Linz 12/6/2015


; Get the right routines ready. 
add_path, '~/local-git-repo/ebtel-idl/'				; or wherever your EBTEL codes are
add_path, 'pro'
add_path, 'mpfit'


; Retrieve the measured FOXSI-2 data to compare against.
restore, 'sav/foxsi2-d6-spex.sav'
energy = findgen(20./0.3)*0.3
measured = interpol( spec.spec_p, spec.energy_kev, energy ) / dt
err = sqrt(measured) / dt
err[ where( err lt 1. ) ] = 1.		; getting appropriate errors seems to be key!
i = where( energy gt 5. and energy lt 10. )			; fitting only 5-10 keV


; Do the fit.  This example is ONLY fitting the filling factor.
; Arguments to MPFITFUN are [1] name of function, [2] energies to fit, 
; [3] measured values to fit, [4] errors on measured values, and [5] start value

;; Run MPFIT.
;param = mpfitfun('linz_testfunction', energy[i], measured[i], err[i], 1.)

; For later. We can set the constraints for the parameters.  See MPFIT doc.
;constraint = replicate({fixed:0, limited:[0,0], limits:[0.D,0.D]},4)
;constraint = {fixed:0, limited:[1,1], limits:[0.001D,1.0D]}
;param = mpfitfun('linz_testfunction', energy[i], measured[i], err[i], 1., parinfo=constraint)


;; Best value for the filling factor is now in PARAM.  Rerun the function to see the 
;; expected observation given this best value for the filling factor.
;fill = param[0]
;obs = linz_testfunction( energy[i], fill )

;;; Trying again with heat0 and fill fit, and flare_dur as a fixed parameter.
undefine, param
undefine, constraint
constraint = replicate({fixed:0, limited:[0,0], limits:[0.0D,0.0D], step:0.0D}, 3)
constraint[2].fixed=1.
constraint[0].limited=[1,1]
constraint[0].limits =[0.001,0.1]
constraint[0].step = 0.001
constraint[1].limited=[1,1]
constraint[1].limits =[0.001,1.0]
constraint[1].step = 0.01
param = mpfitfun('linz_testfunction', energy[i], measured[i], err[i], [0.001,1., 500.], parinfo=constraint)
obs = linz_testfunction( energy, param )

;;; And now fitting flare duration instead.
undefine, param
undefine, constraint
constraint = replicate({fixed:0, limited:[0,0], limits:[0.0D,0.0D], step:0.0D}, 3)
constraint[2].fixed=1.
constraint[2].limited=[1,1]
constraint[2].limits =[50,800]
constraint[2].step = 20.
constraint[1].limited=[1,1]
constraint[1].limits =[0.01,1.0]
constraint[1].step = 0.01
param = mpfitfun('linz_testfunction', energy[i], measured[i], err[i], [0.01,1., 100.], parinfo=constraint)
obs = linz_testfunction( energy, param )


; Plotting to compare results with the measured values.

;save, param, energy, obs, spec, j, file='foxsi2-heat0-results.sav'

;;popen, 'foxsi2-heat0-result', xsi=7, ysi=6
!p.multi=0
loadct, 0
hsi_linecolors
plot, energy, obs, /xlo, /ylo, $
	xr=[4.,12.], yr = [1.e-2,1.e1], xtickv=[findgen(7)+4.], xticks=6, $
	/xsty, psym=10, xtitle='Energy [keV]', ytitle='Counts s!U-1!N keV!U-1!N', $
	charsi=1.4, charth=2, xth=3, yth=3, /nodata, $
	title='FOXSI-2 AR12234 count spectrum'
oplot, energy, obs, thick=8, color=120, psym=10

j = where( spec.energy_kev gt 5. and spec.energy_kev lt 10. and spec.spec_p gt 0. )
oplot_err, spec.energy_kev[j], spec.spec_p[j]/dt, xerr=0.5, $
	yerr=0.99*spec.spec_p_err[j]/dt, psym=1, $
	col=6, thick=8
;oplot, [5.,5.], [1.,100.], line=2
;oplot, [10.,10.], [1.,100.], line=2
al_legend, ['EBTEL expected values','FOXSI-2 measurement'], line=0, $
	col=[120,6], /right, box=0, charsi=1.3, thick=8
;;pclose
