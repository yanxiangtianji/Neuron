import string,time

def change_name(name,pad,ext):
    r=name.rfind('.');
    res=name[0:r]
    res+=pad+'.'+ext
    return res

def for_plot(filename,sep_char=' ',DO_DIF=True):
    #complement & differentiate
    if sep_char==',':
        newname_c=change_name(filename,'-com','csv')
        newname_d=change_name(filename,'-dif','csv')
    elif sep_char==' ':
        newname_c=change_name(filename,'-com','txt')
        newname_d=change_name(filename,'-dif','txt')
    else:
        print 'Error separate char:',sep_char
        exit(0);
    fin=open(filename,'r');
    length=fin.readline().count(',')+1;
    fin.seek(0);
    print length
    fout_c=open(newname_c,'w');
    if DO_DIF:
        last=[0.0 for i in range(length)];
        now=list(last);
        dif=['' for i in range(length)];
        fout_d=open(newname_d,'w');
    count=0;
    for line in fin:
        items=line.split(',');
        for i in range(length):
            if items[i]=='' or items[i]=='\n':
                items[i]='0'+items[i];
                now[i]=last[i];#deal with the jumping when value disappear
            else:
                now[i]=float(items[i]);
            if DO_DIF:
                dif[i]=str(now[i]-last[i]);
        nline=string.join(items,sep_char)
        fout_c.write(nline)
        if DO_DIF:
            nline=string.join(dif,sep_char)
            fout_d.write(nline)
            fout_d.write('\n')
        count+=1;
        if count%10000==0:
            print count,'pieces processed'
    print count,'pieces processed'
    fin.close()
    fout_c.close()
    if DO_DIF:
        fout_d.close()

if __name__=='__main__':
    print 'start'
    filename='R108-122911-spike.csv';
    t1=time.time()
    for_plot(filename,' ',True);
    print time.time()-t1
    print 'finish'

