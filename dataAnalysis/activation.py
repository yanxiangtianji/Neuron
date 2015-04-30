import math
import process_base as base
import myalgorithm as alg

def cal_dif_pair(line_from,line_to,n_dig=4):
	res=[]
	length_f=len(line_from)
	length_t=len(line_to)
	if length_f==0 or length_t==0:
		return res
	j=0
	start_p=0
	while start_p<length_f and line_from[start_p]<line_to[0]:
		start_p+=1
	for i in range(start_p+1,length_f):
		t=line_from[i]
		v=round(t-line_from[i-1],n_dig)
		while j+1<length_t and line_to[j+1]<t:
			j+=1
		#TODO: finish setting
		if j==length_t:
			break
		res.append((v,round(t-line_to[j],n_dig)))
	return res

def activation_time_pair(line_from,line_to,n_dig=4):
	lf=len(line_from)
	lt=len(line_to)
	res=[]
	p=0
	for i in range(lf):
		v=line_from[i]
		p=alg.lower_bound(line_to,p,lt,v)
		if p==lt:
			break
		res.append(round(line_to[p]-v,n_dig))
	return res
	
def activation_time_one(line_from,data,n_dig=4):
	lf=len(line_from)
	n_nodes=len(data)
	lt=[len(l) for l in data]
	res=[]
	p=[None for i in range(n_nodes)]
	for i in range(lf):
		temp=[0 for j in range(n_nodes)]
		v=line_from[i]
		for j in range(n_nodes):
			p[j]=alg.lower_bound(line_to,p[j],lt[j],v)
			if p[j]==lt[j]:
				continue
			temp[j]=round(line_to[p[j]]-v,n_dig)
		res.append(temp)
	return res

	
'''calculate the nearest activation time from all neuron to a specific neuron
'''
def cal_dif_one_table(line,data,rng,n_dig=4):
	n=len(data)
	if n!=len(rng):
		raise ValueError('Unmatched lenght of data ('+str(n)+') and rng ('+str(len(rng))+').')
	length=len(line)
	res=[]
	if length==0:
		return res
	start_j=[rng[i][0] for i in range(n)]
	end_j=[rng[i][1] for i in range(n)]
	start_i=0
	for i in range(n):
		while start_i<length and line[start_i]<data[i][0]:
			start_i+=1
	for i in range(start_i+1,length):
		t=line[i]
		v=round(t-line[i-1],n_dig)
		temp=[v]
		for j in range(n):
			while start_j[j]+1<end_j[j] and data[j][start_j[j]+1]<t:
				start_j[j]+=1
			#when the loop finished, data[j][start[j]]<t<=data[j][start_j[j]+1]
			if start_j[j]==end_j[j]:
				break
			temp.append(round(t-data[j][start_j[j]],n_dig))
		res.append(temp)
	return res

def cal_all_dif_pair(data,n_dig=4):
	n=len(data)
	#res=[[[] for j in range(n)] for i in range(n)]
	res=[]
	for i in range(n):
		temp=[]
		for j in range(n):
			l=cal_dif_pair(data[i],data[j],n_dig)
			temp.append(l)
		res.append(temp)
	return res
	
def write_dif_pair_one(filename,pair_data):
	f=open(filename,'w')
	for x,y in pair_data:
		f.write(str(x)+' '+str(y)+'\n')
	f.close()
	
def write_dif_pair_all(filename_prefix,data):
	n=len(data)
	for i in range(n):
		for j in range(n):
			fn=filename_prefix+'_'+str(i+1)+'_'+str(j+1)+'.txt'
			write_dif_pair_one(fn,data[i][j])
