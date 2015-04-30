import math
import myalgorithm as alg

#######################

class Discretizer:
	#abstract method
	def method(self):
		raise NotImplementedError('Discretization method not implementated!')
	def line(self,line):
		raise NotImplementedError('Discretization method not implementated!')
	def matrix(self,data):
		raise NotImplementedError('Discretization method not implementated!')

#######################
#extend discretize

#base abstract class
class DiscretizerExt(Discretizer):
	def __init__(self,bin_size,step_size=None):
		self.bin_size=bin_size
		self.step_size=step_size if step_size else bin_size	
		self.start_off=0		
	def set_start_off(self,start_time):
		self.start_off=int(start_time/float(self.step_size))
	def cal_length(self,line):
		return self.cal_length_t(line[0],line[-1])
	def cal_length_t(self,start_time,end_time):
		return int(math.ceil((end_time-start_time)/float(self.step_size)))
	def line(self,line,start_time=0,end_time=0):
		if end_time==0:
			end_time=line[-1]
		res_length=self.cal_length_t(start_time,end_time)
		(st,end)=alg.equal_range(line,0,len(line),start_time,end_time)
		self.set_start_off(start_time)
		if st!=0 or end!=len(line):
			return self.method(line[st:end],res_length)
		return self.method(line,res_length)
	def matrix(self,data,start_time=0,end_time=0):
		if end_time==0:
			end_time=max(line[-1] for line in data)
		res_length=self.cal_length_t(start_time,end_time)
		self.set_start_off(start_time)
		l=len(data)
		res=[None for i in range(l)]
		for i in range(l):
			line=data[i]
			(st,end)=alg.equal_range(line,0,len(line),start_time,end_time)
			if st!=0 or end!=len(line):
				res[i]=self.method(line[st:end],res_length)
			else:
				res[i]=self.method(line,res_length)
		return res

#count:
class CountDiscrer(DiscretizerExt):
	def __init__(self,bin_size,step_size=None):
		DiscretizerExt.__init__(self,bin_size,step_size)
		step_size=self.step_size
		self.covered_bin=int(bin_size/step_size)
		self.covered_part=bin_size%step_size
	def method(self,line,res_length):
		res=[0 for i in range(res_length)]
		l=len(line)
		if self.bin_size==self.step_size:
			for v in line:
				p=int(v/self.bin_size)-self.start_off
				res[p]+=1
		else:
			for v in line:
				p=int(v/self.step_size)-self.start_off
				part=1 if v%self.step_size<self.covered_part else 0
				q=max(0,p-self.covered_bin+part)
				for i in range(q,p+1):
					res[p]+=1
		return res
	
#binary	
class BinaryDiscer(DiscretizerExt):
	def __init__(self,bin_size,step_size=None):
		DiscretizerExt.__init__(self,bin_size,step_size)
		step_size=self.step_size
		self.covered_bin=int(bin_size/step_size)
		self.covered_part=bin_size%step_size
	def method(self,line,res_length):
		res=[0 for i in range(res_length)]
		l=len(line)
		if self.bin_size==self.step_size:
			for v in line:
				p=int(v/self.bin_size)-self.start_off
				res[p]=1
		else:
			for v in line:
				p=int(v/self.step_size)-self.start_off
				not_covered=0 if v%self.step_size<self.covered_part else 1
				q=max(0,p-self.covered_bin+not_covered)
				for i in range(q,p+1):
					res[p]+=1
		return res

#######################
#value discretize:

class DiscretizerVal(Discretizer):
	def line(self,line):
		return self.method(line)
	def matrix(self,data):
		return [self.method(line) for line in data]
			
class ThresholdOneDiscer(DiscretizerVal):
	def __init__(self,threshold):
		self.threshold=threshold
	def method(self,line):
		return [0 if v<=self.threshold else 1 for v in line]
	
class ThresholdMultiDiscer(DiscretizerVal):
	def __init__(self,*thresholds):
		if len(thresholds)==0:
			raise ValueError('No threshold inputed')
		if len(thresholds)==1 and isinstance(thresholds[0],list):
			self.thresholds=thresholds
		else:
			self.thresholds=[v for v in thresholds]
		self.n=len(self.thresholds)
		self.thresholds.sort()
	def method(self,line):
		f=lambda x:alg.lower_bound(self.thresholds,0,self.n,x)
		return [f(v) for v in line]
		
#######################
#matrix

def __test():
	import process_base as base
	data=base.read_data()
	cder=CountDiscer(0.1)
	l=cder.line(data[0])
	l2=cder.line(data[0],100,200)
	c=0
	for i in range(1000):
		if l[1000+i]!=l2[i]:
			c+=1
	print c
	bder=BinaryDiscer(0.1)
	m=bder.matrix(data)
	m2=bder.matrix(data,100,200)
	c=0
	for j in range(len(m)):
		for i in range(1000):
			if m[j][1000+i]!=m2[j][i]:
				c+=1
	print c
	

if __name__=='__main__':
	#__test()
	pass
