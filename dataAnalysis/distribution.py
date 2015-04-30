import math
import myalgorithm as alg
import process_base as base

def cal_dis_one_table(line,data,rng_l,rng,n_dig=6):
	n=len(data)
	if n!=len(rng):
		raise ValueError('Unmatched lenght of data ('+str(n)+') and rng ('+str(len(rng))+').')
	res=[]
	if rng_l[1]-rng_l[0]==0:
		return res
	start_i=rng_l[0]
	end_i=rng_l[1]
	start_j=[rng[i][0] for i in range(n)]
	end_j=[rng[i][1] for i in range(n)]
	# for i in range(n):
		# while start_i<end_i and line[start_i]<data[i][start_j[i]]:
			# start_i+=1
#	print start_i,end_i
	for i in range(start_i,end_i):
		t=line[i]
		temp=[]
#		print t
		for j in range(n):
			while start_j[j]+1<end_j[j] and data[j][start_j[j]+1]<t:
				start_j[j]+=1
			#when the loop finished, data[j][start[j]]<t<=data[j][start_j[j]+1]
			if start_j[j]==end_j[j]:
				temp.append(-1);
			else:
				temp.append(round(t-data[j][start_j[j]],n_dig))
		res.append(temp)
	return res

