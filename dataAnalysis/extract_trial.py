import math
import process_base as base


def extract(o_fn,data,time_rng,n_amp=4):
	amp=math.pow(10,n_amp)
	beg_t=time_rng[0]
	end_t=time_rng[1]
	offset=beg_t*amp
	fout=open(o_fn,'w')
	n_node=len(data);
	for i in range(n_node):
		line=data[i]
		(st_id,end_id)=base.alg.equal_range(line, 0, len(line), beg_t, end_t)
		fout.write(str(i)+' '+str(end_id-st_id)+'\n')
		for v in line[st_id:end_id]:
			fout.write(' ')
			fout.write(str(int(v*amp-offset)))
		fout.write('\n')
	fout.close()

def go(data,m_rng,prefix,suffix='.txt'):
	for i in range(len(m_rng)):
		fn=prefix+str(i)+suffix
		print fn
		extract(fn,data,m_rng[i],4)
	
def main(out_base_dir,start=0,duration=10):
	data=base.read_data('all.txt')
	cue=base.read_cue('beh.txt')
	mt1_rng=base.get_cue_time_pairs(cue, 1, start, duration)
	mt2_rng=base.get_cue_time_pairs(cue, 2, start, duration)
	#mr1_rng=base.get_rest_time_pairs(cue, 1, start, duration)
	#mr2_rng=base.get_rest_time_pairs(cue, 2, start, duration)
	mr1_rng=base.get_rest_time_pairs(cue, 1, True, duration)#middle of the rest period, if duration is not None
	mr2_rng=base.get_rest_time_pairs(cue, 2, True, duration)
	#extract('cue1_0.txt',data,mt1_rng[0],4)
	#extract('cue1_4.txt',data,mt1_rng[4],4)
	suffix='.txt'
#	if duration!=None:
#		suffix='_'+str(start)+'_'+str(duration)+'.txt'
	#go(data,mt1_rng,out_base_dir+'/cue1_','.txt')
	#go(data,mt2_rng,out_base_dir+'/cue2_','.txt')
	go(data,mr1_rng,out_base_dir+'/rest1_','.txt')
	go(data,mr2_rng,out_base_dir+'/rest2_','.txt')
		
if __name__=="__main__":
	print 'start'
	out_base_dir="D:/My Program/Projects/Neuron/data/real/st/"
	main(out_base_dir,0)
	#main(out_base_dir+"../st0-3/",0,3)
	#main(out_base_dir+"../st3-6/",3,3)
	#main(out_base_dir+"../st6-9/",6,3)
	print 'finished'
	
