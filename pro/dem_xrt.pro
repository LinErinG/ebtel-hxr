;+
; NAME: DEM_XRT
;
; PURPOSE:
; Compute XRT DN for a differential emission measure
; vs temperature set. Responses are those for two XRT filters used during 
; the FOXSI-2 flight.
;
; INPUT:
;	FILTER:		Name of XRT filter to use, in all lowercase.  Choices are:
;				be-thick 
;				al-thick 
;				ti-poly 
;				al-mesh 
;				al-poly/ti-poly 
;				c-poly/ti-poly 
;				be-thin 
;				be-med 
;				al-med 
;				al-poly 
;   LOGTE:		log(T) temperature array (temperature measured in Kelvin)
;   DEM:		Differential emission measure in units of cm^-5 K^-1 corresponding logte array
;	LENGTH:		Loop half length
;
; OUTPUT:
;
; KEYWORDS:
;	dem_cor:	Coronal DEM in cm^-5
;	dem_tr:		Transition region DEM in cm^-5.  Either coronal or TR must be supplied.
;	scale_height:	Coronal density scale height
;
;
; HISTORY:
;2016-dec-01		LG	Updated with more XRT responses from the time of the FOXSI flight.
;2016-nov-18		LG	Wrote routine
;-

FUNCTION DEM_XRT, filter, logte, length, dem_cor=dem_cor, dem_tr=dem_tr, $
                  scale_height=scale_height, savdir=savdir, _extra=_extra

default, scale_height, 5.e9
default, dem_cor, 0.
default, dem_tr, 0.

<<<<<<< HEAD
restore, 'sav/XRT_Response.sav'
i_filter = where( filter_list eq filter )
=======
default, savdir, '~/foxsi/ebtel-hxr-master/sav/'
restore, savdir+'XRT_Response.sav', /v
i_filter = where( strmid(filter_list,0,9) eq strmid(filter,0,9) )
>>>>>>> 9f28201487e0685e116c821be163aecb2774b472

if i_filter eq -1 then begin
	print, 'No filter match found.'
	return, -1
endif

if ~keyword_set(dem_cor) and ~keyword_set(dem_tr) then begin
   print, "DEM input (coronal and/or TR) required."
   return, 0
endif


; Compute EM in cm^-3 by multiplying DEM by temperature bin width and emitting area.
dlogt = average( get_edges( logte, /width ) )	; binwidth assuming evenly-spaced logT bins
; Ensure time averaged DEM
if size(dem_cor, /n_dimensions) gt 1 then dem_cor = double( average( dem_cor, 1 ) )
if size(dem_tr, /n_dimensions) gt 1 then dem_tr = double( average( dem_tr, 1 ) )

; This ugly code just computes the temperature bin widths.
logTint = alog10( response[i_filter].temp )
nt = n_elements(logtint)
lgt_edg=get_edges(logTint,/mean)
lgt_edg=[lgt_edg[0]-(lgt_edg[1]-lgt_edg[0]),lgt_edg,lgt_edg[nt-2]+(lgt_edg[nt-2]-lgt_edg[nt-3])]
t_edg = 10.^lgt_edg
dT=t_edg[1:nt]-t_edg[0:nt-1]

; Note: if either dem_cor or dem_tr are zero (i.e. not input) then they won't contribute to this.
dem_cm5 = (dem_cor + dem_tr) * scale_height / (2*length)
dem_cm5 = interpol( dem_cm5, logte, alog10(response[i_filter].temp) )
em_cm5 = dem_cm5*dT

cts_pred = response[i_filter].temp_resp * em_cm5
cts_pred[ where( finite( cts_pred ) eq 0 ) ] = 0.

return, total( cts_pred )
 	
END
