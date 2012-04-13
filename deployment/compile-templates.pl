#!/usr/bin/perl
use POSIX  qw( strftime );
use Locale::gettext;
use utf8;
use strict;
use feature qw/say/;

use lib qw(../perl);
use NC::Locale;
use NC::Debug;

sub _date_str2 {
	my ($ts)= @_;
	return strftime ('%e/%m/%Y', localtime($ts||0));
}

my $home_dir;
my $out_dir='build/';
my $loc='es_AR.utf8';
my $loc_dir = 'gettext';
my $lang = 'es';
my $country='AR';
my $verbose=0;
my $nocomp=0;
my $devel=0;
my $no_compress=0;
 
my $maindir = '/helloworld';

`touch $maindir`;
my $v='?v='.substr( (stat($maindir))[9], -6);

SWITCH: while (($_=shift @ARGV || undef) && m/^-.*/ ) {
	/^--out$/ && do {
		$out_dir = (shift @ARGV).'/';
		next SWITCH;
	};
	/^--home$/ && do {
		$home_dir = (shift @ARGV).'/';
		next SWITCH;
	};

	/^--no-compress$/ && do {
		$no_compress=1;
		next SWITCH;
	};


	/^--locale$/ && do {
		$loc = shift @ARGV;

        if ($loc =~ /^(..)_(..)/) {
            ($lang, $country) = ($1, $2);

            $lang = 'lang_' .  $lang;
        }
        else {
            die "bad locale $loc";
        }

		next SWITCH;
	};
	/^--devel$/ && do {
		$devel = shift @ARGV;
        $no_compress = 1 if $devel = 0;
		next SWITCH;
	};

	/^-v$/ && do {
		$verbose =1;
		next SWITCH;
	};
}
unshift @ARGV, $_;
die 'no locale given' if !$loc;
$devel ||= 0;

chdir $home_dir or die "Could not open: $home_dir => $!" if $home_dir;

use NC::ImageGenURI;

my @hosts;

if ($devel == 0  || $devel == 1) {
    my $img = NC::ImageGenURI->new(
        maindir => $maindir,
        debug   => 1,
        devel   => $devel,
    );
    @hosts = ( map { $_ . '/' }  @{ $img->hosts() } );
}


else {
    @hosts = ('http://img.loc/');
}

my $i = 0; 
my $j = int (@hosts);
my @endings;

foreach (@hosts) {
    $endings[$i] = '';

    foreach (30..192) {
        next if $_ % $j ne $i;

        next if chr($_) !~ /[A-Za-z0-9]/;   # Simple endings!

        $endings[$i] .= chr($_);
    }
    $i++;
}

my $po_file = "gettext/$loc/LC_MESSAGES/messages.po";
die "Could not find file $po_file" if ! -e $po_file;

set_locale($loc, $loc_dir,undef,1) or die "Fail to set catalog $loc";


die "\nERROR: Locale msg catalog not found. ($loc, $loc_dir) \n * check that \"gettext is not working\" is defined\n * strace me to see search paths\n"
	if _g("gettext is not working") eq  "gettext is not working";


#
# Global tasks
#
mkdir ($out_dir) if ! -d $out_dir;
$out_dir .= $loc.'/';
mkdir ($out_dir) if ! -d $out_dir;

print STDERR <<"EOL";
 * $loc
EOL

# Per file tasks
foreach my $file (@ARGV) {
	die ("$file is not a file\n") if (! -f $file);

	my $out_file = $out_dir.$file;
    my $src_is_newer =  -M $file < -M $out_file  ? 1 : 0;
    my $po_is_newer =  -M $po_file < -M $out_file  ? 1 : 0;

    next if (-e $out_file && !$src_is_newer && !$po_is_newer);

	$nocomp = 1 if $file =~ /^js_/;
	$nocomp = 1 if $no_compress;

    # subdir?
    my $dname = `dirname $out_file`; chomp $dname;
    `mkdir -p $dname` if ! -d $dname;

	print STDERR "\t$file".( $nocomp ? '[NO COMPILE]' : '' )."\t";

	my $mdate = _date_str2( scalar (( stat($file) )[9])),

# opens input file
	open(FH,$file) or die "$file : $!";
	open (FOUT,">".$out_file) or die "$out_file : $!";

	my ($nf)=(1,0);
	my $all;
	while (defined (my $line = <FH>) ){ 
		chomp $line if !$nocomp;
		$all.=$line if (not ($line =~ /^[\s\t]+$/));
	}
	close (FH);


# gettext
	while ($all =~ s/_'([^']+)'(_'([^']+)')?(_'([^']+)')?/ASDFGHJ/ ) {
		my ($base,$arg1,$arg2) = ($1,$3,$5);
		my $m;
		my $old=$base;
		if (!$arg1) {
			if ($base ne 'updated') {
				$m = _g($base);
			}
			else {
				$m = $mdate;
			}
		} else {
			$m = sprintf(_g($base),$arg1,$arg2);
		}
		$all =~ s/ASDFGHJ/$m/;
		$nf++;
		print STDERR "\n$base -> $m" if $verbose;
	}

# HTML Compress
	if (!$nocomp) {
		$all =~ s/\s\s+/ /g;     # spaces
		$all =~ s/\t//g;         # tabs
	}
    $all =~ s/<!--.*?-->//gs;  # comments

    my $ending1=q|!$\'*-0369<?BEHKNQTWZ]`cfilorux{~|;
    my $ending2=q|"%(+.147:=@CFILORUX[^adgjmpsvy\||;
    my $ending3=q|#&),/258;>ADGJMPSVY\_behknqtwz}|;
	
	# IMGS
    foreach (0..$#hosts) {
        my $ending = $endings[$_];
        my $host = $hosts[$_];     

        $all =~ s|IMAGE_URL/([^"]*?[$ending]\.\w{3})([)"])|$host$1$v$2|g;
        $all =~ s|IMAGE_LOCALIZED/([^"]*?[$ending]\....)([)"])|$host$country/$1$v$2|g;
        $all =~ s|IMAGE_LANG/([^"]*?[$ending]\....)([)"])|$host$lang/$1$v$2|g;
    
    }

	print FOUT $all;
	close (FOUT);

	print STDERR "\n\n" if $verbose;
	print STDERR " | Transalted: $nf\n";

}

