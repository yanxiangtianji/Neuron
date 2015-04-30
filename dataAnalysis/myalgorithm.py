def lower_bound(line,first,last,val):
	while first<last:
		mid=(first+last)/2
		if line[mid]<val:
			first=mid+1
		else:
			last=mid
	return first

def upper_bound(line,first,last,val):
	while first<last:
		mid=(first+last)/2
		if line[mid]<=val:
			first=mid+1
		else:
			last=mid
	return first

def bisearch(line,first,last,val):
	it=lower_bound(line,first,last,val)
	if line[it]==val:
		return it
	return None
	
#range between [st_val,end_val]
def equal_range(line,first,last,st_val,end_val=None):
	#l=len(line)
	if end_val==None:
		end_val=st_val
	low=lower_bound(line,first,last,st_val)
	up=upper_bound(line,low,last,end_val)
	return (low,up)

#range between (st_val,end_val)
def tight_range(line,first,last,st_val,end_val=None):
	#l=len(line)
	if end_val==None:
		end_val=st_val
	low=upper_bound(line,first,last,st_val)
	up=lower_bound(line,low,last,end_val)
	return (low,up)
	