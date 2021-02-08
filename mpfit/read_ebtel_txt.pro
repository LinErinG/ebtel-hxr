pro read_ebtel_txt, prefix, main_dir=main_dir, time=time, te=te, n=n, $
heat=heat, logtdem=logtdem, dem_cor_avg=dem_cor_avg, dem_tr_avg=dem_tr_avg, $
delay=delay

default, main_dir, '/home/andrew/foxsi/ebtel-hxr-master/mpfit/'
prefix = strtrim(prefix,2) ; make sure its a string

rdfloat, main_dir+prefix, time, te, ti, n, pe, pi, v, heat 
dem_tr_file = main_dir+prefix+'.dem_tr'
dem_cor_file = main_dir+prefix+'.dem_corona'

; Read DEM data from only last nanoflare (in sequence of 5)
tlast = where(time ge delay*4. and time lt delay*5.)
num_records = max(tlast)-min(tlast)
logtdem = read_ascii(dem_tr_file, num_records=1)
logtdem=alog10(logtdem.(0))
dem_tr = read_ascii(dem_tr_file, record_start=min(tlast)+1, num_records=num_records)
dem_tr = dem_tr.(0)
dem_cor = read_ascii(dem_cor_file, record_start=min(tlast)+1, num_records=num_records)
dem_cor = dem_cor.(0)
dem_tr_avg = average(dem_tr,2)
dem_cor_avg = average(dem_cor,2)

END
