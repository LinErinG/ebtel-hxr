"""
Write ebtel++ configuration file using specified nanoflare parameters.
Run ebtel++ using the generated configuration file. 
Heating amplitude, flare duration, delay, loop length, and filename are passed.
"""
import sys
import os
import subprocess

#top_dir = os.path.dirname(os.path.dirname(os.path.realpath(__file__)))
top_dir = '/home/andrew/ebtelPlusPlus/'
sys.path.append(os.path.join(top_dir,'rsp_toolkit/python'))
from xml_io import InputHandler,OutputHandler

heat_amplitude = float(sys.argv[1])
duration = float(sys.argv[2]) 
delay = float(sys.argv[3]) 
looplength = float(sys.argv[4]) 
filename = str(sys.argv[5])

#configure the run
ih = InputHandler(os.path.join(top_dir,'config','ebtel.example.cfg.xml'))
base_dir = ih.lookup_vars()
#base_dir['total_time'] = delay*5
base_dir['total_time'] = 5e4
base_dir['loop_length'] = looplength
base_dir['force_single_fluid'] = True
base_dir['use_flux_limiting'] = True
base_dir['use_adaptive_solver'] = True
base_dir['tau_max'] = 10
base_dir['calculate_dem'] = True
#base_dir['output_filename'] = 'hxr_heating_tests'
base_dir['output_filename'] = '/home/andrew/foxsi/ebtel-hxr-master/mpfit/'+filename
base_dir['heating']['partition'] = 0.5


#configure the individual events
events = []
for i in range(5):
   events.append({'event':{'rise_start':i*delay, 'rise_end':i*delay+duration/2,
     'decay_start':i*delay+duration/2, 'decay_end':i*delay+duration,'magnitude':heat_amplitude}})
base_dir['heating']['events'] = events

#print the file
oh = OutputHandler(base_dir['output_filename']+'.xml',base_dir)
oh.print_to_xml()

#run the model
subprocess.call([os.path.join(top_dir,'bin','ebtel++.run'),'-c',base_dir['output_filename']+'.xml'])
#subprocess.call([os.path.join('/home/andrew/','ebtelPlusPlus/bin/ebtel++.run'),
#                    '-c','hxr_tmp_config.xml'])
