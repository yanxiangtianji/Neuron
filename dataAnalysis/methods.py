'''
methods for correlation_template in process.py
fun(res,data,i_rng,param):
	res: square matrix of neuron correlation
	data: time points data of each neuron
	rng: [) range (i_rng: index range for each neuron. t_rng: a global time range)
	param: additional parameters of this function
'''
import math
import myalgorithm as alg
import process_base as base

__EPSILON=1e-10

######################
#i_rng algorithms:

def co_occurance(data,i_rng,param=None):
	#param={}
	n_node=len(data)
	res=[[0 for i in range(n_node)] for i in range(n_node)]
	for i in range(n_node):
		for j in range(n_node):
			if i_rng[i][0]!=i_rng[i][1] and i_rng[j][0]!=i_rng[j][1]:
				res[i][j]=1;
	return res

def count_after(data,i_rng,param):
	#param{'threshold'}: valid period for considering
	threshold=param['threshold'];
	n_node=len(data)
	res=[[0 for i in range(n_node)] for i in range(n_node)]
#	m=[];
	for i in range(n_node):
		scan_end_p=alg.lower_bound(
			data[i],i_rng[i][0],i_rng[i][1],data[i][i_rng[i][1]-1]-threshold)
#		m_i=0
		for j in range(n_node):
			count=0;
			for v in data[i][i_rng[i][0]:scan_end_p]:
				e=alg.equal_range(data[j],i_rng[j][0],i_rng[j][1],v,v+threshold)
				count+=e[1]-e[0]
			res[i][j]=count
			# if count>m_i:
				# m_i=count
		# m.append(m_i)
	# for i in range(n_node):
		# for j in range(n_node):
			# if m[i]!=0:
				# res[i][j]/=m[i]*1.0
	return res
	
def shortest_interval_after(data,i_rng,param):
	#param{'threshold'}: valid period for considering
	#param{'jump'}: whether to jump the spike of i before nearest spike of j
	threshold=param['threshold'];
	enableJump=param['jump'];
	n_node=len(data)
	res=[[0 for i in range(n_node)] for i in range(n_node)]
	for i in range(n_node):
		scan_end_p=alg.lower_bound(
			data[i],i_rng[i][0],i_rng[i][1],data[i][i_rng[i][1]-1]-threshold)
		for j in range(n_node):
			time=0;
			c=0;
			for idx in range(i_rng[i][0],scan_end_p):
				v=data[i][idx]
				p=alg.upper_bound(data[j],i_rng[j][0],i_rng[j][1],v)
				if p!=i_rng[j][1]:
					vj=data[j][p]
					if (vj-v)<=threshold and (enableJump or vj<=data[i][idx+1]):
						time+=data[j][p]-v
						c+=1
			#1/avg(time)
			res[i][j]=c/time if time!=0 else 0
	return res

######################
#t_rng algorithms:

def shortest_interval_after_multi(data,m_t_rng,param):
	#param{'threshold'}: valid period for considering
	#param{'jump'}: whether to jump the spike of i before nearest spike of j
	threshold=param['threshold'];
	enableJump=param['jump'];
	n_node=len(data)
	res=[[0 for i in range(n_node)] for i in range(n_node)]
	time=[[0.0 for i in range(n_node)] for j in range(n_node)]
	c=[[0 for i in range(n_node)] for j in range(n_node)]
	for t_rng in m_t_rng:
		i_rng=base.find_range(data,t_rng[0],t_rng[1])
		for i in range(n_node):
			last_i=alg.upper_bound(data[i],i_rng[i][0],i_rng[i][1],t_rng[1]-threshold)
			for idx in range(i_rng[i][0],last_i):
				vi=data[i][idx]
				for j in range(n_node):
					p=alg.upper_bound(data[j],i_rng[j][0],i_rng[j][1],vi)
					if p!=i_rng[j][1]:
						vj=data[j][p]
						if (vj-vi)<=threshold and (enableJump or vj<=data[i][idx+1]):
							time[i][j]+=vj-vi
							c[i][j]+=1
	for i in range(n_node):
		for j in range(n_node):
			#res=1/avg(time); avg(time)=time/c
			res[i][j]=c[i][j]/time[i][j] if time[i][j]!=0 else 0
	return res

######
#Spike Count Pearson coefficient
	
#Generate qualified vector, together with its len*moment_1 and len*moment_2
def _sc_pearson_count(raw_point_line,t_rng,T_length,step):
	l=[]
	s1=0
	s2=0
	t=t_rng[0]+T_length
	(r_f,r_l)=alg.equal_range(raw_point_line,0,len(raw_point_line),t_rng[0],t_rng[1])
	end=t_rng[1]+__EPSILON
	while t<=end:	#t<=t_rng[1]
		r=alg.equal_range(raw_point_line,r_f,r_l,t-T_length,t)
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

def sc_pearson(data,t_rng,param):
	#param{'T'}: duration of each count period
	#param{'step'}: step length of each movement (0<step<=T)
	T_length=param['T'];
	step=param['step'];
	if t_rng[1]-t_rng[0]+__EPSILON<T_length:
		return
	#length=int((t_rng[1]-t_rng[0]-T_length)/float(step))+1
	#round(x,10) is used to deal with rounding problem when exact division ((1035.6-1035.3-0.05)/0.05=4.9999999999990905). 
	#length=int(round((t_rng[1]-t_rng[0]-T_length)/float(step),10))+1
	length=int((t_rng[1]-t_rng[0]-T_length+__EPSILON)/float(step))+1
	n_node=len(data)
	res=[[0 for i in range(n_node)] for i in range(n_node)]
	l=[[] for i in range(n_node)]
	s1=[None for i in range(n_node)]
	s2=[None for i in range(n_node)]
	#prepare count list
	for i in range(n_node):
		t=_sc_pearson_count(data[i],t_rng,T_length,step)
		l[i]=t[0]
		s1[i]=t[1]
		s2[i]=t[2]
	#calculate correlation
	n_var=[(length*s2[i]-s1[i]**2) for i in range(n_node)]
	del s2
	for i in range(n_node):
		for j in range(n_node):
			if i>j:
				res[i][j]=res[j][i]
				continue
			res[i][j]=_sc_pearson_coefficient(length,l[i],s1[i],n_var[i],l[j],s1[j],n_var[j])
	return res

#join vectors of each ranges, then calculate the result
def sc_pearson_multi(data,m_t_rng,param):
	#param{'T'}: duration of each count period
	#param{'step'}: step length of each movement (0<step<=T)
	T_length=param['T'];
	step=param['step'];
	n_node=len(data)
	res=[[0 for i in range(n_node)] for i in range(n_node)]
	l=[[] for i in range(n_node)]
	s1=[0 for i in range(n_node)]
	s2=[0 for i in range(n_node)]
	length=0
	for t_rng in m_t_rng:
		if t_rng[1]-t_rng[0]<T_length:
			continue
		length+=int((t_rng[1]-t_rng[0]-T_length)/step)+1
		for i in range(n_node):
			t=_sc_pearson_count(data[i],t_rng,T_length,step)
			l[i].extend(t[0])
			s1[i]+=t[1]
			s2[i]+=t[2]
	#calculate correlation
	var=[(length*s2[i]-s1[i]**2) for i in range(n_node)]
#	del s2
	for i in range(n_node):
		for j in range(n_node):
			if i>j:
				res[i][j]=res[j][i]
				continue
			res[i][j]=_sc_pearson_coefficient(length,l[i],s1[i],var[i],l[j],s1[j],var[j])
	return res

#average the result from each range
def sc_pearson_multi_avg(data,m_t_rng,param):
	n_node=len(data)
	x=[[0.0 for i in range(n_node)] for i in range(n_node)]
	for t_rng in m_t_rng:
		res=sc_pearson(data,t_rng,param)
		for i in range(n_node):
			for j in range(n_node):
				x[i][j]+=res[i][j]
	for i in range(n_node):
		for j in range(n_node):
			x[i][j]/=float(len(m_t_rng))
	return x

#####
#dot product

def dot_product(dis_data,t_rng,param):
	#param{'size'}: the bin size for discretization
	bin_size=param['size']
	st=int(t_rng[0]/bin_size)
	end=int(math.ceil(t_rng[1]/bin_size))
	l=end-st
	n_node=len(dis_data)
	res=[[0 for i in range(n_node)] for i in range(n_node)]
	for i in range(n_node):
		for j in range(n_node):
			res[i][j]=sum(dis_data[i][k]^dis_data[j][k] for k in range(st,end))
	return res
	
def dot_product_multi_avg(dis_data,m_t_rng,param):
	n_node=len(data)
	x=[[0.0 for i in range(n_node)] for i in range(n_node)]
	for t_rng in m_t_rng:
		res=dot_product(data,t_rng,param)
		for i in range(n_node):
			for j in range(n_node):
				x[i][j]+=res[i][j]
	for i in range(n_node):
		for j in range(n_node):
			x[i][j]/=float(len(m_t_rng))
	return x
	