import math
import myalgorithm as alg
import process_base as base


def _matrix_sum(mat):
	return sum(sum(line) for line in mat)

#def _find_max_score(line1,line2,)
	
def find_offset_p(data,i_rng, step,max_off, cr_l_fun,param, pred=lambda x,y:x>y):
	n_node=len(data)
	dummy=99999999 if pred(1,-1) else -99999999
	best=[[-dummy for i in range(n_node)] for i in range(n_node)]
	res=[[0 for i in range(n_node)] for i in range(n_node)]
	try_list=range(-1,-max_off-1,-1)
	try_list.extend(1,max_off+1)
	for j in range(n_node):
		#make temporary moved list outside for efficiency
		for k in try_list:
			x=[v+k*step for v in data[j][i_rng[j][0]:i_rng[j][1]]]
			for i in range(n_node):
				if j>i:	#upper right
					res[i][j]=-res[j][i]
					continue
				#temporary list latter
				v=cr_l_fun(data[i][i_rng[i][0]:i_rng[i][1]],x,param)
				if pred(v,best[i][j]):
					res[i][j]=k*step
					best[i][j]=v
	return res

	
def find_offset_dis(data,rng, max_off, cr_l_fun,param, pred=lambda x,y:x>y):
	n_node=len(data)
	st=rng[0]
	end=rng[1]
	res=[[0 for i in range(n_node)] for i in range(n_node)]
	for i in range(n_node):
		for j in range(n_node):
			if i>j:
				res[i][j]=-res[j][i]
				continue
			max_v=cr_l_fun(data[i][st:end],data[j][st:end],param)
			best_k=0
			for k in range(1,max_off+1):
				vn=cr_l_fun(data[i][st:end],data[j][st-k:end-k],param)
				vp=cr_l_fun(data[i][st:end],data[j][st+k:end+k],param)
				v=vp if vn==vp or pred(vp,vn) else vn
				if pred(v,max_v):
					v=max_v
					best_k=k
			res[i][j]=best_k
	return res
	

def main():
	data=base.read_data('all.txt')
	cue=base.read_cue('beh.txt')
	n=len(data)
#	data_b=.....
	m_t_rng=base.get_cue_time_pairs(cue,1,3,1)
	res=[[0 for i in range(n_node)] for i in range(n_node)]
	mats=[]
	for st,end in m_t_rng:
		x=find_offset_dis(data_b,(int(10*st),int(10*end)),3,method_base.dot_product,{})
		for i in range(n):
			for j in range(n):
				res[i][j]+=x[i][j]
		mats.append(x)
	for i in range(n):
		for j in range(n):
			res[i][j]/=float(len(m_t_rng))
	base.write_matrix_to_mat_file(res,'offset','offset.mat')
	base.write_matrices_to_mat_file(mats,'offset_s','offset_s.mat')
	