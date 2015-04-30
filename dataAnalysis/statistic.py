import math

def mean_std(line,do_skip=False,skip_v=None):
	m=0;	s=0;
	c=0
	for v in line:
		if do_skip and v==skip_v:
			continue
		c+=1
		m+=v
		s+=v**2
	if c==0:
		return (0,0)
	l=float(c)
	m/=l
	s=math.sqrt(s/l-m**2)
	return (m,s)
	
def stat_3(line,do_skip=False,skip_v=None):
	s1=0;	s2=0;	s3=0;
	c=0
	for v in line:
		if do_skip and v==skip_v:
			continue
		c+=1
		s1+=v
		s2+=v**2
		s3+=v**3
	if c==0:
		return (0,0,0)
	l=float(c)
	s1/=l;	s2/=l;	s3/=l;
	s=math.sqrt(s2-s1**2)
	sk=(s3-3*s1*s2+2*s1**3)/s**3 if s!=0 else 0
	return (s1,s,sk)

def stat_4(line,do_skip=False,skip_v=None):
	s1=0;	s2=0;	s3=0;	s4=0
	c=0
	for v in line:
		if do_skip and v==skip_v:
			continue
		c+=1
		s1+=v
		s2+=v**2
		s3+=v**3
		s4+=v**4
	if c==0:
		return (0,0,0,0)
	l=float(c)
	s1/=l;	s2/=l;	s3/=l;	s4/=l;
	s=math.sqrt(s2-s1**2)
	sk=(s3-3*s1*s2+2*s1**3)/s**3 if s!=0 else 0
	k=(s4-4*s1*s3+6*s1**2*s2-3*s1**4)/s**4 if s!=0 else 0
	return (s1,s,sk,k-3)
	
	