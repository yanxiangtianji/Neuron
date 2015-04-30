import math
import process_base as base
import myalgorithm as alg

__EPSILON=1e-10

def _sc_pearson_count(line,t_rng,T_length,step):
	l=[]
	s1=0
	s2=0
	t=t_rng[0]+T_length
	(r_f,r_l)=alg.equal_range(line,0,len(line),t_rng[0],t_rng[1])
	end=t_rng[1]+__EPSILON
	while t<=end:	#t<=t_rng[1]
		r=alg.equal_range(line,r_f,r_l,t-T_length,t)
		c=r[1]-r[0]
		l.append(c)
		s1+=c
		s2+=c**2
		r_f=r[0]
		t+=step
	return (l,s1,s2)

def _sc_pearson_coefficient(length, l_i,s1_i,var_i, l_j,s1_j,var_j,nodata_value=0):
	cov=sum(l_i[k]*l_j[k] for k in range(length))
#	return (length*cov-s1_i*s1_j)/math.sqrt(var_i*var_j) if var_i!=0 and var_j!=0 else nodata_value
	if s1_i!=0 and s1_j!=0:
		return (length*cov-s1_i*s1_j)/math.sqrt(var_i*var_j) if var_i!=0 and var_j!=0 else 1
	else
		return nodata_value


def col_period_one_neuron(line,m_t_rng,T_length,step):
	n=len(m_t_rng)
	l=[]
	s1=[]
	s2=[]
	length=int((m_t_rng[0][1]-m_t_rng[0][0]-T_length+__EPSILON)/step)+1
	res=[[0.0 for i in range(n)] for i in range(n)]
	for t_rng in m_t_rng:
		t=_sc_pearson_count(line,t_rng,T_length,step)
		l.append(t[0])
		s1.append(t[1])
		s2.append(t[2])
	var=[(length*s2[i]-s1[i]**2) for i in range(n)]
	for i in range(n):
		for j in range(n):
			if i>j:
				res[i][j]=res[j][i]
				continue
			res[i][j]=_sc_pearson_coefficient(length,l[i],s1[i],var[i],l[j],s1[j],var[j])
	return res
	
def all(line,cue_data,cue_id, start,end,snap_size,  T_length,step, matname,filename):
	pass
	mats=[]
	st=start
	while st<end:
		m_t_rng=base.get_cue_time_pairs(cue_data,cue_id,st,snap_size)
		st+=snap_size
		res=col_period_one_neuron(line,m_t_rng,T_length,step)
		mats.append(res)
	base.write_matrices_to_mat_file(mats,matname,filename)
		
def test(data,cue_data):
	all(data[0],cue_data,1,-3,15,1,0.1,0.1,'cps','cps.mat')
	all(data[1],cue_data,2,0,18,1,0.1,0.1,'cps','cps.mat')
	
	
