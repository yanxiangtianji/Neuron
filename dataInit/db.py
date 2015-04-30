import string,math
import db_base as base

######################
#initial

def read_raw_time_data(file_name,sepper=','):
	fin=open(file_name,'r');
	length=fin.readline().count(',')+1;
	fin.seek(0);
	print 'number of item each line:',length
	res=[];
	for line in fin:
		items=line.split(sepper);
		for i in range(length):
			if items[i]!='' and items[i]!='\n':
				res.append((i+1,float(items[i])))
	fin.close()
	return res;

def trans_raw_time_to_lists(data):
	dict={}
	for nid,time in data:
		dict.setdefault(nid,[]).append(time)
	for line in dict.values():
		line.sort()
	return [dict[k] for k in sorted(dict.keys())]

def read_raw_cue_data(name,sepper=','):
	fin=open(name,'r');
	length=fin.readline().count(',')+1;
	fin.seek(0);
	print length,'each line'
	res=[];
	last_time=0.0;
	last_state=0;
	for line in fin:
		items=line[:-1].split(sepper)
		time=float(items[0]);
		state=int(items[1]);
		if state==3:
			res.append([last_state,last_time,time,time-last_time]);
		last_time=time;
		last_state=state;
	fin.close();
	for i in range(1,len(res)):
		res[i-1].append(res[i][1]-res[i-1][2])
	res[-1].append(0)
	return res;

######################
#neuron: IO

#read list format neuron
def read_lists_from_db_time(table_name,block_size=5000,conn=None):
	#read data from db
	if conn==None:
		con=get_db_con();
	else:
		con=conn
	cursor=con.cursor();
	cursor.execute("select count(*) from "+table_name+"_neuron")
	n=cursor.fetchone()[0];
	res=[[] for i in range(n)]
	cursor.execute("select * from "+table_name+" order by time")
	count=0;
	block=cursor.fetchmany(block_size)
	while block:
		for (nid,time) in block:
			res[nid-1].append(time)
		count+=block_size;
		if count%50000==0:
			print count,'pieces processed'
		block=cursor.fetchmany(block_size)
	if conn==None:
		con.close()
	print count,'pieces processed'
	return res;

#read list format neuron
def read_lists_from_list_file(file_name):
	f=open(file_name,'r')
	res=[]
	for line in f:
		l=line.split(' ')
		for i in range(len(l)):
			l[i]=float(l[i])
		res.append(l)
	f.close()
	return res

def write_to_one_file(res,filename):
	#write 2D data to file
	fout=open(filename,'w')
	for line in res:
		l=len(line)
		if l!=0:
			fout.write(str(line[0]))
			for i in range(1,l):
				fout.write(' ')
				fout.write(str(line[i]))
		fout.write('\n')
	fout.close();

def write_to_n_files(res,filename_prefix,ext):
	#write 2D data to n files (each line for a file)
	if ext[0]!='.':
		ext='.'+ext
	count=0;
	for line in res:
		count+=1
		fout=open(filename_prefix+str(count)+ext,'w')
		l=len(line)
		if l!=0:
			fout.write(str(line[0]))
			for i in range(1,l):
				fout.write(' ')
				fout.write(str(line[i]))
		fout.write('\n')
		fout.close();

def export_to_file(data,all_name,sep_name_prefix=None,sep_name_suffix=None):
	print 'writing to one file'
	write_to_one_file(data,all_name)
	if sep_name_prefix!=None and sep_name_suffic!=None:
		print 'writing to n files'
		write_to_n_files(data,sep_name_prefix,sep_name_suffix)

#####################
#update neuron

def cal_neuron_dif(data,mode_unit_size=1e-3):
	res=[]
	nid=0;
	for line in data:
		nid+=1
		n=len(line)-1
		dif_min=line[1]-line[0]
		dif_max=line[1]-line[0]
		s1=0;   s2=0;   s3=0;   s4=0;
		occur={}
		zero_count=0
		for i in range(n):
			t=line[i+1]-line[i]
			v=int(t/mode_unit_size)
			if v in occur:
				occur[v]+=1
			else:
				occur[v]=1
			if t==0:
				zero_count+=1
			elif t<dif_min:
				dif_min=t
			elif t>dif_max:
				dif_max=t
			s1+=t;  s2+=t**2; s3+=t**3; s4+=t**4;
		s1/=float(n); s2/=float(n); s3/=float(n); s4/=float(n);
		#moment related
		mean=s1
		std=math.sqrt(s2-s1**2)
		cm3=s3-3*s2*s1+2*s1**3
		cm4=s4-4*s3*s1+6*s2*s1**2-3*s1**4;
		#mode(most often)
		(mode,freq)=max(occur.iteritems(),key=lambda x:x[1])
		mode=(mode+0.5)*mode_unit_size
#		print mode,freq
		t={'zero_count':zero_count,'min':dif_min,'max':dif_max,'mode':mode,'mode_count':freq,
			'mean':mean,'std':std,'cm3':cm3,'cm4':cm4}
		res.append(t)
	return res

#####################
#dif

'''get the unsorted difference list from line1 to line2, (both line1 and line2 are non-decreasing)
(0 difference is NOT returned in list, but its occurrence number returned separated)
  One difference value: for i find smallest line2[j] (>line1[i]), the difference is line2[j]-line1[i]
  noJump=True: value (line2[j]-line1[i]) is considered only when line1[i] is also the largest value smaller than line2[j] in line1.
    i.e. no other k satisfies: line1[i]<line1[k]<line2[j] . and for all k where line1[i]!=line1[k] satisfies: line1[k]<line1[i] or line1[k]>line2[j]
'''
def cal_dif_list(line1,line2,noJump=False,epsilon=1e-6):
	j=0;
	length1=len(line1)
	length2=len(line2)
	res=[]
	equal_count=0;
	n_dig=int(math.ceil(-math.log10(epsilon)))
	for i in range(length1):
		v=line1[i]
		while j<length2 and line2[j]<=v+epsilon:
			if abs(line2[j]-v)<=epsilon:
				equal_count+=1
			j+=1
		if j==length2:
			break
		if noJump and i+1<length1 and line1[i+1]<line2[j] and v<line1[i+1]:
			continue
		res.append(round(line2[j]-v,n_dig))
	return (equal_count,res)

'''calculate the statistical information of the given UNSORTED dif list
(dif is SORTED in this function)
'''
def cal_dif_list_info(zero_count,dif,quantile_points,mode_unit_size):
	dif.sort()
	n=len(dif)
	s1=0; s2=0; s3=0; s4=0;
	s_min=dif[0]; s_max=dif[-1];
	occur=[]
	last=-1
	c=0
	for t in dif:
		s1+=t;  s2+=t**2; s3+=t**3; s4+=t**4;
		if int(t/mode_unit_size)==last:
			c+=1
		else:
			occur.append((last,c))
			c=1
			last=int(t/mode_unit_size)
	s1/=float(n); s2/=float(n); s3/=float(n); s4/=float(n);
	#moment
	mean=s1
	std=math.sqrt(s2-s1**2)
	cm3=s3-3*s2*s1+2*s1**3
	cm4=s4-4*s3*s1+6*s2*s1**2-3*s1**4
	#quantile
	quantile=[dif[int(round(n*v))] for v in quantile_points]
	#mode
	(mode,freq)=max(occur,key=lambda x:x[1])
	mode=(mode+0.5)*mode_unit_size
	return {'count':n,'zero_count':zero_count,'min':s_min,'max':s_max,
			'mode':mode,'mode_count':freq,
			'mean':mean,'std':std,'cm3':cm3,'cm4':cm4,'quantile':quantile}

def cal_col_dif(data,quantile_points,noJump=False,mode_unit_size=1e-3,epsilon=1e-6,col_file_prefix=None):
	length=len(data)
	res=[[() for i in range(length)] for i in range(length)];
	for i in range(length):
		print 'Processing correlation from',(i+1)
		l=[]
		for j in range(length):
			(zero_count,dif)=cal_dif_list(data[i],data[j],noJump,epsilon)
			if col_file_prefix!=None:
				l.append(dif)
			res[i][j]=cal_dif_list_info(zero_count,dif,quantile_points,mode_unit_size)
		if col_file_prefix!=None:
			write_to_one_file(l,col_file_prefix+str(i+1)+'.txt')
	return res

	
#####################
#final

def init_db(basic_table_name,quantile_points,mode_unit_size=1e-3,epsilon=1e-6,col_file_prefix=None,con=None):
	print 'creating tables:'
	base.create_tables(basic_table_name,quantile_points,con)
	print 'importing data:'
	#data=base.import_to_db('R108-122911-spike.csv',read_raw_time_data,basic_table_name)
	data=read_raw_time_data('R108-122911-spike.csv')
	base.insert_template(data,basic_table_name,con)
	#base.import_to_db('R108-122911-beh.csv',read_raw_cue_data,basic_table_name+'_beh(type,begin,end,duration,rest)')
	base.insert_template(read_raw_cue_data('R108-122911-beh.csv'),
						basic_table_name+'_beh(type,begin,end,duration,rest)',con)
	print 'initializing neuron info:'
	base.init_neuron(basic_table_name,con)
	data=trans_raw_time_to_lists(data)
	neu_dif_data=cal_neuron_dif(data,mode_unit_size)
	base.update_neuron_dif(neu_dif_data,basic_table_name,con)
	
	#del neu_dif_data
	print 'writing difference matrix(jump):'
	diff_j=cal_col_dif(data,quantile_points,False,mode_unit_size,epsilon,
						col_file_prefix+'j_' if col_file_prefix else None)
	base.insert_dif(diff_j,basic_table_name,False,con)
	#del diff_j
	print 'writing difference matrix(no-jump):'
	diff_nj=cal_col_dif(data,quantile_points,True,mode_unit_size,epsilon,
						col_file_prefix+'nj_' if col_file_prefix else None)
	base.insert_dif(diff_nj,basic_table_name,True,con)
	#del diff_nj
	

if __name__=='__main__':
	basic_table_name='r108_122911'
	quantile_points=[0.05*i for i in range(1,19)]
	#init_db(basic_table_name,quantile_points)
	
	#print 'reading data lists from db'
    #data=read_db_time_data(basic_table_name)
	#print 'reading data lists from file'
	#data=read_file_time_data('./all.txt')
	#data=trans_raw_time_to_lists(read_raw_time_data('R108-122911-spike.csv'))
	#export_to_file(data,'all.txt','','.txt')
	#base.update_neuron_dif(data,basic_table_name)
	cal_dif(data,basic_table_name)
	

