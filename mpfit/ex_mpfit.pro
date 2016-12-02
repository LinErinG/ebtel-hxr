;; testing out MPFIT for our EBTEL-FOXSI-NuSTAR purposes.

; Get the right routines ready. 
add_path, '~/local-git-repo/ebtel-idl/'	; or wherever your EBTEL codes are
add_path, '~/ebtel-master'	; or wherever your EBTEL codes are
add_path, 'pro'
add_path, 'mpfit'

; Retrieve the measured FOXSI-2 data to compare against.
; Divid by integration times to get units of cts / kev / s
;restore, 'sav/foxsi2-d6-spex.sav'
restore, 'sav/foxsi2-d6-spex-0.5keV.sav'
i = where( spec.energy_kev ge 5. and spec.energy_kev le 10. ) ; fitting only 5-10 keV
energy = spec.energy_kev[i]
measured = spec.spec_p[i] / dt
err = spec.spec_p_err[i] / dt
err[ where( err lt 1. ) ] = 1.		; getting appropriate(ly large) errors seems to be key!


; MPFIT
; Parameter list:
; Parameter 0:	Heating amplitude
; Parameter 1:	Filling factor (by default, this is automatically calculated)
; Parameter 2:	Flare duration [s]
; Parameter 3:	Loop length (better to get from observations)

undefine, param
undefine, constraint
; Set up constraint array.
constraint = replicate({fixed:0, limited:[0,0], limits:[0.0D,0.0D], step:0.0D}, 4)

; Choose which parameters to fit.  1 means fit; 0 means don't.
constraint[0].fixed=1.		; Amplitude fixed?
constraint[1].fixed=1.		; Filling factor fixed?
constraint[2].fixed=0.		; Flare_dur fixed?
constraint[3].fixed=1.		; Loop length fixed?

; Set limits on those parameters that we're fitting.
; If a parameter is fixed then these won't matter.
constraint[0].limited=[1,1]	; Flag that we want limits on param[0] (i.e. heat0)
constraint[0].limits =[0.001,0.1]	; Specify the limits for param[0]
constraint[0].step = 0.001		; Step size for adjustments to param[0]
;constraint[1].limited=[1,1]		; Flag that we want limits on param[1] (i.e. fill)
;constraint[1].limits =[0.001,1.0]	; Specify the limits for param[1]
;constraint[1].step = 0.001		; Step size for adjustments to param[1]
constraint[2].limited=[1,1]		; Flag that we want limits on param[1] (i.e. fill)
constraint[2].limits =[1.,500.]	; Specify the limits for param[1]
constraint[2].step = 1		; Step size for adjustments to param[1]

; Do the fit!
param = mpfitfun('linz_testfunction', energy[i], measured[i], err[i], [0.01,1.,500.,3.d9], parinfo=constraint)
; Best-fit values are now in PARAM.

; Rerun the function to see the expected observation given this best set of variables.
obs = linz_testfunction( energy, param )
; Use finer energy bins for the theoretical values.
; NOTE: this should come out of the fit function, but right now it's not.

;test1 = linz_testfunction( energy, [0.01,1.,500.,3.d9], /dont )
;test2 = linz_testfunction( energy, [0.01,1.,500.,3.d9] )


;
; If desired, save results.
; save, param, energy, obs, spec, file=instr+'-heat0-results.sav'

; Make a plot to compare results with the measured values.
hsi_linecolors
plot, energy, obs, /xlo, /ylo, xr=[4.,12.], yr = [1.e-1,1.e2], xtickv=[findgen(7)+4.], $
	xticks=6, /xsty, psym=10, xtitle='Energy [keV]', ytitle='Counts s!U-1!NkeV!U-1!N', $
	charsi=1.4, charth=2, xth=3, yth=3, /nodata, $
	title='Count spectrum'
oplot, energy, obs, thick=8, color=120, psym=10
j = where( spec.energy_kev gt 5. and spec.energy_kev lt 10. and spec.spec_p gt 0. )
oplot_err, spec.energy_kev[j], spec.spec_p[j], xerr=0.25, $
	yerr=0.99*spec.spec_p_err[j], psym=1, $
	col=6, thick=8
al_legend, ['EBTEL expected values','FOXSI-2 measurement'], line=0, $
	col=[120,6], /right, box=0, charsi=1.3, thick=8
