import time
import myalgorithm as alg

'''Result Format: A list for every neuron. Each spike time is a entry.
'''
def read_data(filename='all.txt'):
	fin=open(filename,'r')
	res=[]
	for line in fin:
		l=line.split(' ');
		for i in range(len(l)):
			l[i]=float(l[i]);
		res.append(l);
	fin.close();
	return res;

def write_data(data,filename):
	fout=open(filename,'w')
	for line in data:
#		nline=str(line)[1:-1].replace(',','')
#		fout.write(nline)
		fout.write(str(line[0]))
		for i in range(1,len(line)):
			fout.write(' ')
			fout.write(str(line[i]))
		fout.write('\n')
	fout.close()

'''Result Format: list of (cue_id, start_time, end_time, duration_to_next_cue)
'''
def read_cue(filename='beh.txt'):
	fin=open(filename,'r')
	res=[]
	for line in fin:
		l=line.split(' ')
		l[0]=int(l[0])
		l[1]=float(l[1])
		l[2]=float(l[2])
		l[3]=float(l[3])
		res.append(l)
	fin.close()
	return res

##########################	
#cue process
def get_cue_time_pairs(cue_data,cue_id,offset=0,duration=None):
	pred=lambda x : x==cue_id;
	if duration==None:	#to the end of that trial
		return [(d[1]+offset,d[2]) for d in cue_data if pred(d[0])]
	return [(d[1]+offset,d[1]+offset+duration) for d in cue_data if pred(d[0])]
	#
	if cue_id==None:	#all kind of trial
		if duration==None:	#to the end of that trial
			return [(d[1]+offset,d[2]) for d in cue_data]
		return [(d[1]+offset,d[1]+offset+duration) for d in cue_data]
	else:	#specific kind of trial
		if duration==None:
			return [(d[1]+offset,d[2]) for d in cue_data if d[0]==cue_id]
		return [(d[1]+offset,d[1]+offset+duration) for d in cue_data if d[0]==cue_id]

def get_rest_time_pairs(cue_data,cue_id,offset_OR_atMiddle=0,duration=None):
	#when @offset_OR_atMiddle is True, pick the middle of rest period; when it is integer, it is a starting offset
	#when @duration is None: pick the period to the end of the rest period and @offset_OR_atMiddle is meanlingless
	pred=lambda x : x==cue_id;
	if duration==None:	#to the end of that rest period
		offset=0 if isinstance(offset_OR_atMiddle,bool) else offset_OR_atMiddle
		#isinstance(True/False,bool)->True; isinstance(True/False,int)
		return [(d[2]+offset,d[2]+d[3]) for d in cue_data if pred(d[0])]
	else:
		if isinstance(offset_OR_atMiddle,bool)==True:	#at middle
			half=duration/2
			return [(d[2]+d[3]/2-half,d[2]+d[3]/2+half) for d in cue_data if pred(d[0])]
		else:
			offset=offset_OR_atMiddle
			return [(d[2]+offset,d[2]+offset+duration) for d in cue_data if pred(d[0])]


##########################
#range
def find_range(data,low_val,up_val):
	res=[]
	for line in data:
		res.append(alg.equal_range(line,0,len(line),low_val,up_val))
	return res
	
def get_whole_range(data):
	return [(0,len(l)) for l in data]

##########################
#matrix
def check_matrix_format(mat):
	#t=type([])
	#return (type(mat)==t and type(mat[0])==t and type(mat[0][0])!=t)
	return isinstance(mat,list) and len(mat)!=0 and isinstance(mat[0],list) and (len(mat[0])==0 or not isinstance(mat[0][0],list))
	#deal with the empty matrix

def _write_matrix_content(mat,fout,l_prefix='',l_suffix='\n'):
	for line in mat:
		fout.write(l_prefix)
#		nline=str(line)[1:-1].replace(',','')
#		fout.write(nline)
		fout.write(str(line[0]))
		for i in range(1,len(line)):
			fout.write(' ')
			fout.write(str(line[i]))
		fout.write(l_suffix)

def write_matrix_to_text_file(matrix,filename):
	if not check_matrix_format(matrix):
		raise ValueError('Input value is not a matrix format')
	fout=open(filename,'w')
	_write_matrix_content(matrix,fout,'','\n')
	fout.close()
	
def _write_mat_file_header(fout):
	fout.write('# Created by Python program of Tian Zhou, '+time.ctime(time.time())+'\n')

def _write_mat_matrix_info(mat,name,fout):
	fout.write('# name: '+name+'\n')
	fout.write('# type: matrix\n')
	fout.write('# rows: '+str(len(mat))+'\n')
	fout.write('# columns: '+str(len(mat[0]))+'\n')

def write_matrix_to_mat_file(matrix,name,filename):
	if not check_matrix_format(matrix):
		raise ValueError('Input value is not a matrix format')
	fout=open(filename,'w')
	_write_mat_file_header(fout)
	_write_mat_matrix_info(matrix,name,fout)
	_write_matrix_content(matrix,fout,' ','\n')
	fout.write('\n')
	fout.close()
	
def write_matrices_to_mat_file(matrices,name,filename):
	#save the matrices into a cell type
	#use cell2mat(mat_name(1)) to get the first matrix in matlab/octave
	fout=open(filename,'w')
	_write_mat_file_header(fout)
	fout.write('# name: '+name+'\n')
	fout.write('# type: cell\n')
	fout.write('# rows: 1\n')
	fout.write('# columns: '+str(len(matrices))+'\n')
	for mat in matrices:
		if not check_matrix_format(mat):
			raise ValueError('Input value is not a matrix format')
		_write_mat_matrix_info(mat,'<cell-element>',fout)
		_write_matrix_content(mat,fout,' ','\n')
		fout.write('\n\n');			
	fout.close()

##########################
#final

def main():
	print 'reading data'
	data=read_data('all.txt')
	length=len(data)
	st=1031
	threshold=1;
	
	duration=10
	ranges=find_range(data,st,st+duration)
	print 'occurance:'
	#correlation_no_time(data,ranges,'cm_occurence.txt')
	#correlation_template(data,ranges,methods.co_occurance,{},'cm_occurence.txt')
	
	duration=10
	ranges=find_range(data,st,st+duration)
	filename='cm_s'+str(st)+'_d'+str(duration)+'_t'+str(threshold)+'.txt'
	print 'time:',filename
	#correlation_time(data,ranges,threshold,filename)
	

if __name__=='__main__':
	#main()
	pass
	