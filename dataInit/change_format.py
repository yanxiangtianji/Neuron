import string,time,os,re

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

#format convert

def text2lines_spk(data,sep_item=',',sep_line='\n'):
    n=len(data[0:data.find(sep_line)].split(sep_item));
    res=[[] for i in range(n)];
    for line in data.split(sep_line):
        if len(line)==0:
            continue;
        items=line.split(sep_item);
        for i in range(n):
            if len(items[i])!=0:
                res[i].append(items[i]);
    return res;

def text2lines_beh(data,sep_item=',',sep_line='\n'):
    #input:  start_time, cue_id/event_id(3 is end of cue)
    #output: cue_id, start_time, end_time, interval_to_next_time
    res=[];
    last_time=0.0;
    last_state=0;
    for line in data.split(sep_line):
        if len(line)==0: continue;
        items=line.split(sep_item);
        time=float(items[0]);
        state=int(items[1]);
        if state==3:
            res.append([last_state,last_time,time]);
        last_time=time;
        last_state=state;
    for i in range(1,len(res)):
        res[i-1].append(res[i][1]-res[i-1][2])
    res[-1].append(0)
    return res;

def write_lines_spk(filename,data):
    f2=open(filename,'w');
    for j in range(len(data)):
        line=data[j];
        f2.write(str(j)+' '+str(len(line))+'\n');
        for v in line:
            f2.write(' ')
            f2.write(str(v))
        f2.write('\n')
    f2.close()

def write_lines_beh(filename,data):
    f2=open(filename,'w');
    for line in data:
        f2.write(str(line[0]))
        for i in range(1,len(line)):
            f2.write(' ')
            f2.write(str(line[i]))
        f2.write('\n')
    f2.close()

def transAmp(data,amp,line_start=0):
    for i in range(len(data)):
        line=data[i];
        for j in range(line_start,len(line)):
            data[i][j]=int(amp*float(data[i][j]));
    return data

def csv2lineTxt_spk(filename,amp=1,sep_line='\n'):
    f=open(filename);
    data=text2lines_spk(f.read(),',',sep_line);
    f.close();
    data=transAmp(data,amp,0);
    fn2=re.sub('\.csv$','.txt',filename);
    if filename==fn2: fn2=filename+'.txt';
    write_lines_spk(fn2,data);

def csv2lineTxt_beh(filename,amp=1,sep_line='\n'):
    f=open(filename);
    data=text2lines_beh(f.read(),',',sep_line);
    f.close();
    data=transAmp(data,amp,1);
    fn2=re.sub('\.csv$','.txt',filename);
    if filename==fn2: fn2=filename+'.txt';
    write_lines_beh(fn2,data);

def enumFileExt(folder,ext):
    l=[];
    regstr=ext.replace('.','\.')+'$';
    for name in os.listdir(folder):
        if os.path.isdir(folder+'/'+name): continue;
        elif re.search(regstr,folder+'/'+name)==None: continue;
        l.append(name)
    return l;

def transAll2txt(folder,n_amp=5):
    fn_list=enumFileExt(folder,'.csv')
    fn_spk=[];fn_beh=[];
    amp=10**n_amp;
    for name in fn_list:
        if name.find('-spike')!=-1:
#            csv2lineTxt_spk(folder+'/'+name,amp,'\n')
            fn_spk.append(name);
        elif name.find('-beh')!=-1:
            csv2lineTxt_beh(folder+'/'+name,amp,'\n')
            fn_beh.append(name);
        else:
            print folder+'/'+name, 'not support'
    return (fn_spk,fn_beh)

def merge_spikes(folder,fn_spk,fn_out):
    fout=open(folder+'/'+fn_out,'w')
    for fn in fn_spk:
        f=open(folder+'/'+fn_spk);
        fout.write(f.read());
        f.close();
    fout.close();

if __name__=='__main__':
    print 'start'
    filename='R108-122911-spike.csv';
    t1=time.time()
    #for_plot(filename,' ',True);
    #transAll2txt('PL/',5)
    print time.time()-t1
    print 'finish'

