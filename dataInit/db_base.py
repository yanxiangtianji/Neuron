import mysql.connector,string,math
from mysql.connector import errorcode


DB_CONFIG={
	'user':'zt',
	'password':'123456',
	'host':'localhost',
	'database':'neuron'
}

def get_db_con(conf=DB_CONFIG):
	try:
		conn=mysql.connector.connect(**conf)
	except mysql.connector.Error as err:
		if err.errno == errorcode.ER_ACCESS_DENIED_ERROR:
			print("Something is wrong with your user name or password")
		elif err.errno == errorcode.ER_BAD_DB_ERROR:
			print("Database does not exists")
		else:
			print(err)
	else:
		return conn
		
def create_tables(table_name_base,quantile_points,conn=None):
	data_sql=("CREATE TABLE `"+table_name_base+"` ("
"  `nid` int(11) NOT NULL,"
"  `time` float NOT NULL,"
"  PRIMARY KEY (`nid`,`time`)"
") ENGINE=MyISAM DEFAULT CHARSET=utf8")
	beh_sql=("CREATE TABLE `"+table_name_base+"_beh` ("
"  `id` int(11) NOT NULL AUTO_INCREMENT,"
"  `type` smallint(6) NOT NULL,"
"  `begin` float NOT NULL,"
"  `end` float NOT NULL,"
"  `duration` float NOT NULL,"
"  `rest` float DEFAULT NULL COMMENT 'Time between this end to next begin, i.e. begin(i)+rest(i)=begin(i+1).',"
"  PRIMARY KEY (`id`)"
") ENGINE=MyISAM AUTO_INCREMENT=107 DEFAULT CHARSET=utf8")
	neuron_sql=("CREATE TABLE `"+table_name_base+"_neuron` ("
"  `nid` int(11) NOT NULL,"
"  `count` int(11) DEFAULT NULL,"
"  `beg_time` float DEFAULT NULL,"
"  `end_time` float DEFAULT NULL,"
"  `duration` float DEFAULT NULL,"
"  `dif_min` float DEFAULT NULL,"
"  `dif_max` float DEFAULT NULL,"
"  `dif_mode` float DEFAULT NULL COMMENT 'most often value',"
"  `dif_mode_count` int(11) DEFAULT NULL,"
"  `dif_mean` double DEFAULT NULL COMMENT 'First moment',"
"  `dif_std` double DEFAULT NULL COMMENT 'Square root of Second central moment.\n(dif_cm2=std^2)',"
"  `dif_cm3` double DEFAULT NULL COMMENT 'Third central moment.\nSkewness=cm3/std^3 (third standardized moment).',"
"  `dif_cm4` double DEFAULT NULL COMMENT 'Fourth central moment.\nKurtosis=cm4/std^4 (fourth standardized moment) WITHOUT \"-3\".\n(kurtosis >= skewness^2 + 1).\n',"
"  PRIMARY KEY (`nid`),"
"  UNIQUE KEY `nid_UNIQUE` (`nid`)"
") ENGINE=InnoDB DEFAULT CHARSET=utf8")
	n_dig=int(math.ceil(-math.log10(min(quantile_points))))
	scale=10**n_dig
	q_base_sql="  `q_%0"+str(n_dig)+"d` float NULL, "
	col_sql_base=("CREATE TABLE `"+table_name_base+"` ("
"  `first` int(11) NOT NULL,"
"  `second` int(11) NOT NULL,"
"  `count` int(11) DEFAULT NULL,"
"  `zero_count` int(11) DEFAULT NULL,"
"  `min` float DEFAULT NULL,"
"  `max` float DEFAULT NULL,"
"  `mode` float DEFAULT NULL,"
"  `mode_count` int(11) DEFAULT NULL,"
"  `mean` float DEFAULT NULL,"
"  `std` double DEFAULT NULL,"
"  `cm3` double DEFAULT NULL,"
"  `cm4` double DEFAULT NULL,"
+"\n"+string.join([(q_base_sql%(v*scale)) for v in quantile_points],'\n')+"\n"
"  PRIMARY KEY (`first`,`second`)"
") ENGINE=MyISAM DEFAULT CHARSET=utf8")
	col_j_sql=col_sql_base.replace(table_name_base,table_name_base+'_col_j')+" COMMENT='CA (co-active): smallest time interval from an activation of the first neuron to the nearest activation of the second neuron, without jumping any other activation of the first neuron. i.e. the second neuron''s activation is the nearest one AFTER first neuron''s.'"
	col_nj_sql=col_sql_base.replace(table_name_base,table_name_base+'_col_nj')+" COMMENT='CANJ (co-active no jump): smallest time interval from an activation of the first neuron to the nearest activation of the second neuron, without jumping any other activation of the first neuron. i.e. the second neuron''s activation is the nearest one AFTER first neuron''s, and the first activation of the first neuron is also the nearest one BEFORE the second''s.'"
	if conn==None:
		con=get_db_con()
	else:
		con=conn
	try:
		cur=con.cursor()
		print 'creating raw data table'
		cur.execute(data_sql)
		print 'creating beh data table'
		cur.execute(beh_sql)
		print 'creating neuron info table'
		cur.execute(neuron_sql)
		print 'creating correlation (jump) info table'#,col_j_sql
		cur.execute(col_j_sql)
		print 'creating correlation (no-jump) info table'#,col_nj_sql
		cur.execute(col_nj_sql)
	except mysql.connector.Error as err:
		con.rollback()
		print 'Error:',err
	else:
		con.commit()
	finally:
		if conn==None:
			con.close()

def insert_template(data,table,conn=None):
	length=len(data[0])
	insert_sql="INSERT INTO "+table+" VALUES(%s"+",%s"*(length-1)+")"
	print insert_sql
	if conn==None:
		con=get_db_con()
	else:
		con=conn
	cursor=con.cursor()
	count=0
	for t in data:
		#print t
		cursor.execute(insert_sql,t)
		count+=1
		if count%10000==0:
			print count,'pieces processed'
	print count,'pieces processed'
	con.commit()
	if conn==None:
		con.close()

def import_to_db(file_name,func_read,table_name):
	print 'reading',file_name
	data=func_read(file_name)
	print 'finish reading :',len(data),'in all'
	print 'inserting',table_name
	insert_template(data,table_name);
	print 'finish inserting'
	return data

def init_neuron(table_name_base,conn=None):
	#put initial values to the neuron table using the data in raw data table.
	sql=("insert into `"+table_name_base+"_neuron`(nid,count,beg_time,end_time,duration) "
"select nid,count(*),min(time),max(time), max(time)-min(time) from `"+table_name_base+"` group by nid order by nid")
	if conn==None:
		con=get_db_con();
	else:
		con=conn
	print sql
	cur=con.cursor()
#	cur.execute("select nid,count(*),min(time),max(time), max(time)-min(time) from `"+table_name_base+"` group by nid order by nid")
#	for line in cur:
#		print line
	try:
		cur.execute(sql);
	except mysql.connector.Error as err:
		con.rollback()
		print 'Error:',err
	else:
		con.commit();
	if conn==None:
		con.close()

def update_neuron_dif(data,table_name_base,conn=None):
	update_sql=("update `"+table_name_base+"_neuron` set "
				"dif_min=%s,dif_max=%s,dif_mode=%s,dif_mode_count=%s,"
				"dif_mean=%s,dif_std=%s,dif_cm3=%s,dif_cm4=%s "
				"where nid=%s");
	print update_sql
	if conn==None:
		con=get_db_con();
	else:
		con=conn
	cursor=con.cursor();
	nid=0;
	try:
		for t in data:
			nid+=1
			cursor.execute(update_sql,
						   (t['min'],t['max'],t['mode'],t['mode_count'],
							t['mean'],t['std'],t['cm3'],t['cm4'],nid))
			print nid,'neuron updated.'
	except mysql.connector.Error as err:
		con.rollback()
		print 'Error:',err
	else:
		con.commit();
	if conn==None:
		con.close()

def insert_dif(data_mat,table_name_base,noJump,conn=None):
	table_name=table_name_base+('_col_nj' if noJump else '_col_j')
	n=len(data_mat)
	length=len(data_mat[0][0])-1+len(data_mat[0][0]['quantile'])
	insert_sql=("insert into `"+table_name+"` values(%s,%s,%s"+",%s"*(length-1)+")")
#	print insert_sql
	if conn==None:
		con=get_db_con();
	else:
		con=conn
	cur=con.cursor()
	try:
		for i in range(n):
			for j in range(n):
				t=data_mat[i][j]
				v=[i+1,j+1,t['count'],t['zero_count'],t['min'],t['max'],t['mode'],t['mode_count'],
					t['mean'],t['std'],t['cm3'],t['cm4']]
				v.extend(x for x in t['quantile'])
				cur.execute(insert_sql,v);
	except mysql.connector.Error as err:
		con.rollback()
		print 'Error:',err
	else:
		con.commit();
	if conn==None:
		con.close()


if __name__=='__main__':
	basic_table_name='r108_122911'
	#create_tables(basic_table_name)
	#after inserting some dummy data, run:
	#init_neuron(basic_table_name)
