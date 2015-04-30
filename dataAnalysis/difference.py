import math
import process_base as base

def cal_dif_lists(data,doSort=False,n_dig=7):
	res=[]
	for line in data:
		l=[round(line[i]-line[i-1],n_dig) for i in range(1,len(line))]
		res.append(l)
	if doSort:
		for l in res:
			l.sort()
	return res

'''change SORTED value points to (Value, Count) pairs.
Merge the values fall into the same unit (whose size is given).
When unit_size=0, just merge the exactly same value.
'''
def cal_vc_pair_lists(dif_data,unit_size=0):
	res=[]
	for line in dif_data:
		if len(line)==0:
			continue
		c=0
		l=[]
		if unit_size==0:
			last=line[0]
			for v in line:
				if v==last:
					c+=1
				else:
					l.append((last,c))
					last=v
					c=1
		else:
			last=int(line[0]/unit_size) #not value, but the number of unit
			for v in line:
				if int(v/unit_size)==last:
					c+=1
				else:
					l.append(((last+0.5)*unit_size,c))
					last=int(v/unit_size)
					c=1
		res.append(l)
	return res

def cal_matrix_from_vc_pair(vc_list_data):
	#
	length=len(vc_list_data)
	temp={}
	num=0
	for line in vc_list_data:
		for v,c in line:
			temp.setdefault(v,[0 for i in range(length)])[num]=c
		num+=1
	res=[]
	for v,counts in sorted(temp.items()):
		t=[v]
		t.extend(c for c in counts)
		res.append(t)
	return res
	
def write_vc_list(filename,vclist):
	f=open(filename,'w')
	for v,c in vclist:
		f.write(str(v)+' '+str(c)+'\n')
	f.close()
	
	