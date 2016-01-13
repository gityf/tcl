load libOratcl25.so

set DBLogon 0
set DBHandle 0
set DBSQL     orasql
set DBNEXT    orafetch
set DBCOMMIT  oracommit
set DBCLOSE   oraclose
set DBLOGOFF  oralogoff

# Connect to oracle.  
proc connectdb { dbuser } {
	global DBLogon
	global DBHandle
	if {[catch {oralogon $dbuser} DBLogon]} {
		puts "connected failed,please check your oracle user name and password"
		puts "dbuser:\[$dbuser\] logonstatus:\[$DBLogon\]"
		exit 1
	}
	if {[catch {oraopen $DBLogon} DBHandle ]} {
		puts "open cursor failed"
		exit 1
	}
}

# execut sql statement.  
proc execsql { sql } {
	global DBSQL
	global DBCOMMIT
	global DBHandle
	$DBSQL $DBHandle $sql;
	$DBCOMMIT $DBHandle	
	if { [expr $::oramsg(rc) != 0] } {
		#check information failed
		puts "Sqlcommand exec failed.The statement is \n$sql"
		exit 1
	}
}

# close database.  
proc closedb {} {
	global DBCLOSE
	global DBLogon
	global DBLOGOFF
	global DBHandle
	$DBCLOSE $DBHandle
	$DBLOGOFF $DBLogon	
}