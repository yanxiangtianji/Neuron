import math

def _check_length(l1,l2):
	if l1!=l2:
		raise ValueError('length of line1 ('+str(l1)+') do not match length of line2 ('+str(l2)+')!')


#Calculate Pearson coefficient for two vector on SAME LENGTH
def pearson_lines(line1,line2,param=None):
	l=len(line1)
	_check_length(l,len(line2))
	c=0;	s1=[0,0];	s2=[0,0];
	for i in range(l):
		a=line1[i];	b=line2[i]
		s1[0]+=a;	s1[1]+=b;
		s2[0]+=a**2;	s2[1]+=b**2;
		c+=a*b
	n_var1=l*s2[0]-s1[0]**2;
	n_var2=l*s2[1]-s1[1]**2;
	return (n*c-s1[0]*s1[1])/math.sqrt(n_var1*n_var2)

#Calculate Dot-Product (sum of XOR on elements) for two vector on same length
def dot_product(line1,line2,param=None):
	l=len(line1)
	_check_length(l,len(line2))
	return sum(line1[i]^line2[i] for i in range(l))

#Calculate Norm_1 (sum absolute difference) for two vector on same length
def norm1(line1,line2,param=None):
	l=len(line1)
	_check_length(l,len(line2))
	return sum(abs(line1[i]-line2[i]) for i in range(l))

#Calculate Norm_2 (Euclidean distance) for two vector on same length
def norm2(line1,line2,param=None):
	l=len(line1)
	_check_length(l,len(line2))
	return math.sqrt(sum((line1[i]-line2[i])**2 for i in range(l)))

#Calculate Norm_n for two vector on same length
def norm(line1,line2,param=None):
	n=param['n']
	l=len(line1)
	_check_length(l,len(line2))
	if n==1:
		return norm1(line1,line2)
	elif n==2:
		return norm2(line1,line2)
	return math.pow(sum((line1[i]-line2[i])**n for i in range(l)),1.0/n)

	