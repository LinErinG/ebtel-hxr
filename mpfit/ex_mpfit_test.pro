PRO ex_mpfit_test, instr=instr, region=region, save_fit=save_fit, save_plot=save_plot, save_dir=save_dir

; Get the right routines ready. 
add_path, '~/ebtel-master/'	; or wherever your EBTEL codes are
add_path, '~/foxsi/ebtel-hxr-master/'
add_path, '~/foxsi/ebtel-hxr-master/pro'
add_path, '~/foxsi/ebtel-hxr-master/mpfit'

default, instr, 'foxsi2'
default, save_dir, '~/foxsi/ebtel-hxr-master/'

; defaults
;heat0 = 0.01d          	; amplitude of (nano)flare [erg cm^-3 s^-1]
;length = 6.0d9			; loop half-length
;flare_dur = 500d		; duration of heating event [seconds]
scale_height = 5d9		; coronal scale height (or any desired height)

; Retrieve the measured data to compare against.
CASE instr OF 

   'foxsi2': BEGIN
      restore, '~/foxsi/ebtel-hxr-master/sav/foxsi2-d6-spex.sav', /v
      energy = findgen(20./0.3)*0.3
      measured = interpol( spec.spec_p, spec.energy_kev, energy ) / dt
      err = sqrt(measured / dt / (energy[1]-energy[0]))    ;account for integration time & bin width
      err[ where( err lt 1. ) ] = 1.           ; getting appropriate errors seems to be key!
      i = where( energy gt 5. and energy lt 10. )   ; fitting only 5-10 keV
             END

   'nustar': BEGIN
      restore, '~/foxsi/ebtel-hxr-master/sav/O4P1G0_FPMA.dat', /v
      energy = findgen(20./0.3)*0.3
      measured = interpol( counts_flux[region,*], engs, energy )
      err = sqrt(measured / (dur*lvt) / (energy[1]-energy[0]))  ;account for integration time & bin width
      err[ where( err lt 1. ) ] = 1.            ; getting appropriate errors seems to be key!
      i = where( energy gt 2.5 and energy lt 6. )   ; fitting only 2.5-6 keV
             END

   ELSE: BEGIN
      print, 'Instr keyword must be foxsi2 or nustar'
      RETURN
      END

ENDCASE

; Setup for MPFIT:
; Currently the list of parameters is:
;    param[0]   Heating amplitude (heat0)
;    param[1]   Filling factor (fill)
;    param[2]   Flare duration (flare_dur)
;    param[3]   Loop length (length)

; Set up constraint array.
constraint = replicate({fixed:0, limited:[0,0], limits:[0.0D,0.0D], step:0.0D}, 4)

;   Initial heating (heat0)
;constraint[0].fixed=1           ; Fix param[0], i.e. don't fit heat0
constraint[0].limited=[1,1]       ; Flag that we want limits on param[0] (i.e. heat0)
constraint[0].limits =[0.001,0.1]	; Specify the limits for param[0]
constraint[0].step = 0.001		; Step size for adjustments to param[0]
;   Fill factor (fill)
constraint[1].fixed=1
;constraint[1].limited=[1,1]		
;constraint[1].limits =[0.001,1.0]	
;constraint[1].step = 0.001	
;   Flare duration (flare_dur)	
constraint[2].fixed=1                   
;constraint[2].limited=[1,1]
;constraint[2].limits =[1., 500.]
;constraint[2].step = 1. 
;   Loop half-length (length)
;constraint[3].fixed=1	
constraint[3].limited=[1,1]
constraint[3].limits =[1e9, 9e9]
constraint[3].step = [1e8]

;How to pass additional arguments to user-supplied function
;functargs = {scale_height:scale_height}

;Name plots and .sav files indicating free fit parameters
param_string = ['heat0', 'fill', 'flare_dur', 'length']
f = where(constraint.fixed eq 0)
n_strings = n_elements(f)

FOR fn=0, n_strings-1 DO BEGIN
   p = param_string[f[fn]] + '-'
   print, param_string[f[fn]] + ' is a free parameter'
   if fn eq 0 then fitstring = p
   if fn gt 0 then fitstring = fitstring + p
ENDFOR

initial_param = [0.01d, 1d, 500d, 2.0d9]

stop

CASE instr OF 

'foxsi2': BEGIN
   param = mpfitfun('foxsi_testfunction', energy[i], measured[i], err[i], initial_param, $
              parinfo=constraint, bestnorm=bestnorm)
   ; Best values for heat0, fill, and flare_dur are now in PARAM.
   ; Rerun the function to see the expected observation given this best set of variables.
   obs = foxsi_testfunction( energy, param )

   if keyword_set(save_fit) then save, initial_param, param, bestnorm, energy, obs, $
                         file=save_dir+'sav/'+instr+'-'+fitstring+'results.sav'

   IF keyword_set(save_plot) THEN BEGIN
         title=strupcase(instr)+' AR12234 count spectrum'
         popen, save_dir+'figs/'+instr+'-'+fitstring+'result.eps', xsi=7, ysi=6, /encaps
         !p.multi=0
         loadct, 0
         hsi_linecolors
         plot, energy, obs, /xlo, /ylo, $
              xr=[1.,12.], yr = [1.e-2,1.e2], xtickv=[findgen(11)+1.], xticks=6, $
              /xsty, psym=10, xtitle='Energy [keV]', ytitle='Counts s!U-1!N keV!U-1!N', $
              charsi=1.4, charth=2, xth=3, yth=3, /nodata, title=title
         oplot, energy, obs, thick=8, color=120, psym=10
           
         j = where( spec.energy_kev gt 5. and spec.energy_kev lt 10. and spec.spec_p gt 0. )
         oplot_err, spec.energy_kev[j], spec.spec_p[j]/dt, xerr=0.5, $
                    yerr=0.99*spec.spec_p_err[j]/dt, psym=1, $
                    col=6, thick=8
                             ;oplot, [5.,5.], [1.,100.], line=2
                             ;oplot, [10.,10.], [1.,100.], line=2
         al_legend, ['EBTEL expected values',strupcase(instr)+' measurement'], line=0, $
                    col=[120,6], /right, box=0, charsi=1.3, thick=8
         pclose
      ENDIF


    END

'nustar': BEGIN  
   param = mpfitfun('nustar_testfunction', energy[i], measured[i], err[i], initial_param, $
              parinfo=constraint, bestnorm=bestnorm)
   ; Best values for heat0, fill, and flare_dur are now in PARAM.
   ; Rerun the function to see the expected observation given this best set of variables.
   obs = nustar_testfunction( energy, param )

   ; If desired, save results.
   if keyword_set(save_fit) then save, initial_param, param, bestnorm, energy, obs, $
                         file=save_dir+'sav/'+instr+'_'+ids[region]+'-'+fitstring+'results.sav'

   IF keyword_set(save_plot) THEN BEGIN
      title=strupcase(instr)+' '+ids[region]+' count spectrum'
      popen, save_dir+'figs/'+instr+'_'+ids[region]+'-'+fitstring+'result.eps', xsi=7, ysi=6, /encaps
      !p.multi=0
      loadct, 0
      hsi_linecolors
      plot, energy, obs, /xlo, /ylo, $
            xr=[1.,12.], yr = [1.e-1,1.e5], /xsty, psym=10, $
            xtitle='Energy [keV]', ytitle='Counts s!U-1!N keV!U-1!N', $
            charsi=1.4, charth=2, xth=3, yth=3, /nodata, title=title
      oplot, energy, obs, thick=8, color=120, psym=10

      j = where( engs gt 2.5 and engs lt 6. and counts_flux[region,*] gt 0. )
      oplot_err, engs[j], counts_flux[region, j]/(dur*lvt), xerr=0.5, $
                 yerr=sqrt(counts_flux[j])/(dur*lvt), psym=1, $
                 col=6, thick=8
                             ;oplot, [2.5,2.5], [1.,100.], line=2
                             ;oplot, [6.,6.], [1.,100.], line=2
      al_legend, ['EBTEL expected values',strupcase(instr)+' measurement'], line=0, $
                 col=[120,6], /right, box=0, charsi=1.3, thick=8
      pclose
   ENDIF
END
ENDCASE


END
