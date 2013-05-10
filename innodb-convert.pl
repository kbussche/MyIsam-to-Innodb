#!/usr/bin/perl
use DBI;
use strict;

##
#       MyIsam to Innodb Conversion Script
#       Usage: perl innodb_convert.pl <database name>
##

## Replace the below values to match your database
my $MYSQL_USER = "root";
my $MYSQL_PASS = "your_luggage_combination";
## End Config

my $database = shift || die "no database meat head\n";

my $dbh = dbConnect($database);



##
# Goes table by table for the db, finds the PRI collumn for the initial alter statement
##
my $ref = $dbh->selectall_arrayref("show tables");
my $tab = "";
my $key_col = 0;
my $desc = ();

foreach my $row(@{$ref}) {
  $tab = $row->[0];
  $key_col = 0;
  $desc = $dbh->selectall_arrayref("desc $tab");
  foreach my $col(@{$desc}) {
        if($col->[3] eq 'PRI') {$key_col = $col->[0]; }
  }

  print "Working table $tab \tkey = $key_col\n";

  if($key_col) {
        $dbh->do("ALTER table $tab order by $key_col");
        print "\t\t$tab is re-ordered\n";
  }

  $dbh->do("ALTER table $tab ENGINE = INNODB");
  print "\t\t$tab is converted\n";
}





sub dbConnect {
  my $database = shift;
  my $db = DBI->connect("DBI:mysql:database=$database",$MYSQL_USER,$MYSQL_PASS)
      or die ("Unable to connect to DB");
  return $db;
}

