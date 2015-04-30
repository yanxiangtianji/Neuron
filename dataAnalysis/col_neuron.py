import math
import process_base as base
import methods
import statistic
import discretize

'''Get correlation matrix with given method (whose parameter(s) is/are also given).
res=cr_fun(data,rng,param):
	data: time points data of each neuron
	rng: [) range for each neuron in data (i_rng: index range; t_rng: time range)
	param: additional parameters of this function
	RETURN: square matrix of the neuron correlation
'''
def _template_correlation(data,rng,  cr_fun,parameter,  filename=None):
	res=cr_fun(data,rng,parameter);
	if filename:
		write_matrix_to_text_file(res,filename)
	return res

def _template_process_write(data,ranges,  cr_fun,param,  matname=None,filename=None):
	mats=[]
	for rng in ranges:
		res=_template_correlation(data,rng,cr_fun,param,None)
		mats.append(res)
	if matname and filename:
		base.write_matrices_to_mat_file(mats,matname,filename)
	else:
		return mats

'''Get the snapshots of neuron correlation of successive TIME PERIOD.
The result is several matrices written to a matlab cell style file.
_i version for those works on index range.
_t version for those works on time range.
'''
def get_successive_snapshots_i(data,  start,end,snap_size,  cr_fun,param,  matname,filename=None):
	if not filename:
		filename=matname+'.mat'
	st=start
	ranges=[]
	while st<end:
		i_rng=base.find_range(data,st,st+snap_size)
		st+=snap_size
		ranges.append(i_rng)
	_template_process_write(data,ranges, cr_fun,param, matname,filename)

def get_successive_snapshots_t(data,  start,end,snap_size,  cr_fun,param,  matname,filename=None):
	if not filename:
		filename=matname+'.mat'
	st=start
	ranges=[];
	while st<end:
		t_rng=(st,st+snap_size)
		st+=snap_size
		ranges.append(t_rng)
	_template_process_write(data,ranges, cr_fun,param, matname,filename)

'''Get snapshots of neuron correlation at fixed RELATIVE PERIOD of specific cue.
start,end are RELATIVE values to the beginning of each cue.
'''
def get_successive_cue_pattern(data,cue_data,cue_id,  start,end,snap_size,  cr_fun,param,  matname,filename=None):
	if not filename:
		filename=matname+'.mat'
	st=start
	ranges=[]
	while st<end:
		cue_param={'id':cue_id,'offset':st,'duration':snap_size}
		m_t_rng=base.get_cue_time_pairs(cue_data,cue_param.get('id'),
							cue_param.get('offset'),cue_param.get('duration'))
		ranges.append(m_t_rng)
		st+=snap_size
	_template_process_write(data,ranges, cr_fun,param, matname,filename)

def _transform_slice_to_3d(mats):
	n=len(mats)
	len1=len(mats[0])
	len2=len(mats[0][0])
	res=[[[None for i in range(n)] for i in range(len2)] for i in range(len1)]
	for k in range(n):
		for i in range(len1):
			for j in range(len2):
				res[i][j][k]=mats[k][i][j]
	return res
	
'''Get the pattern(snapshots) of neuron correlation at given RELATIVE PERIOD of specific cue.
'''	
def get_neuron_correlation_pattern(data,cue_data,cue_id,  start,end,  cr_fun,param,
							slice_matname,stat_matname,slice_filename=None,stat_filename=None):
	if not slice_filename and slice_matname:
		slice_filename=slice_matname+'.mat'
	if not stat_filename and stat_matname:
		stat_filename=stat_matname+'.mat'
	n=len(data)
	m_t_rng=base.get_cue_time_pairs(cue_data,cue_id,start,end-start)
	n_cue=len(m_t_rng)
	mats=_template_process_write(data,m_t_rng, cr_fun,param, None,None)
	if slice_matname:
		base.write_matrices_to_mat_file(mats,slice_matname,slice_filename)
	if not stat_matname:
		return
	mats=_transform_slice_to_3d(mats)
	mean=[[0 for i in range(n)] for i in range(n)]
	std=[[0 for i in range(n)] for i in range(n)]
	skew=[[0 for i in range(n)] for i in range(n)]
	kurtosis=[[0 for i in range(n)] for i in range(n)]
	for i in range(n):
		for j in range(n):
			(mean[i][j],std[i][j],skew[i][j],kurtosis[i][j])=statistic.stat_4(mats[i][j])
			#(mean[i][j],std[i][j],skew[i][j],kurtosis[i][j])=statistic.stat_4(mats[i][j],True,0)
	base.write_matrices_to_mat_file([mean,std,skew,kurtosis],stat_matname,stat_filename)

def main():
	print 'reading data'
	data=base.read_data('all.txt')
	cue=base.read_cue('beh.txt')
	#different snapshot on same trial: (network evolution)
	#get_successive_snapshots_i(data,1035,1038,0.3,methods.co_occurance,{},'ob','co_1035_s0.03.mat')
	#get_successive_snapshots_i(data,1035,1038,0.3,methods.count_after,{'threshold':0.03},'ob','ca_1035_s0.3_t0.03.mat')
	#get_successive_snapshots_t(data,1035,1038,0.3,methods.sc_pearson,{'T':0.05,'step':0.05},'cps','cps.mat')
	#get_successive_snapshots_t(data,1031,1040,1,methods.sc_pearson,{'T':0.1,'step':0.1},'cps','cps.mat')
	
	#same snapshot of different trial: (network consistency)
	get_neuron_correlation_pattern(data,cue,1, 4,5, methods.sc_pearson,{'T':0.05,'step':0.05},'ptn_s','ptn')
	get_neuron_correlation_pattern(data,cue,1, 4.8,5.2, methods.sc_pearson,{'T':0.05,'step':0.05},'ptn_s',None)
	data_b=[discretize.discretize_binary_t(data[i],0,4000,0.1) for i in range(len(data))]
	get_neuron_correlation_pattern(data_b,cue,1, 4,5, methods.dot_product,{'size':0.1},'ptn_s','ptn')
	
	

if __name__=='__main__':
	pass
	#main()

	