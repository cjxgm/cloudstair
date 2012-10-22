#!/usr/bin/perl
use CGI;
use CGI::Carp qw(fatalsToBrowser);
use MIME::Base64;
use Proc::Daemon;
use LWP::UserAgent;

my $PROJ_HOME = '/tmp/';
chdir $PROJ_HOME;

my $q = CGI->new;

defined $q->param('get') and do {
	my $proj = decode_46esab($q->param('proj'));
	open my $f, "< dl_$proj" or die "unable to read file.";
	print $q->header(-type=>'binary/octet-stream',
			-attachment=>$proj,
			-content_length=>-s"dl_$proj");
	while (<$f>) { print }
	close $f;
	exit;
};

print $q->header(-charset=>'utf-8');

defined $q->param('add') and do {
	my $proj = decode_46esab($q->param('proj'));
	my $addr = decode_46esab($q->param('addr'));
	write_to_file("url_$proj", $addr);
	write_to_file("status_$proj", -2);
	exit;
};

defined $q->param('query') and do {
	&init_46esab;
	&query_project and &query_no_project;
	&flush_46esab;
	exit;
};

defined $q->param('start') and do {
	my $proj = decode_46esab($q->param('proj'));
	read_from_file("status_$proj") == -2 or die "Project already started.";
	start_download($proj);
	exit;
};

defined $q->param('stop') and do {
	my $proj = decode_46esab($q->param('proj'));
	write_to_file("do_$proj", 'STOP');
	sleep 2;
	write_to_file("status_$proj", -2);
	unlink "dl_$proj";
	exit;
};

defined $q->param('delete') and do {
	my $proj = decode_46esab($q->param('proj'));
	write_to_file("do_$proj", 'STOP');
	write_to_file("status_$proj", -2);
	unlink "dl_$proj";
	unlink "url_$proj";
	unlink "status_$proj";
	unlink "do_$proj";
	exit;
};


print << "EOF";
<!doctype html>
<meta charset="utf-8">

<title>Cloud Stair</title>
<link rel="stylesheet" href="css/index.css">
<script src="js/util.js"></script>
<script src="js/46esab.js"></script>
<script src="js/index.js"></script>

<div id="header">
	<h1>Cloud Stair</h1>
	<small>
		Copyfree (C) eXerigumo Clanjor, 2012.<br>
		The source code of this web site is licensed under CC-BY 3.0.
	</small>
</div>

<div id="browser" class="relative browser">
	<div class="button btn-add">
		<div style="width: 30px; float: right;">+</div>
		<input id="proj" type="text" placeholder="project name">
		<input id="addr" type="text" placeholder="address">
	</div>
	<div id="content" class="content">
	</div>
</div>

<div id="loading" class="modal modal-hide">
	<div id="loading-content" class="loading">
		<div id="loading-text"><br></div>
		<progress></progress>
	</div>
</div>
EOF


######################################################################
# 46esab - the reversed base64
#

my $esab_data = '';

sub encode_46esab
{
	scalar reverse encode_base64(shift, '');
}

sub decode_46esab
{
	decode_base64(scalar reverse shift);
}

sub init_46esab
{
	$esab_data = '';
}

sub print_46esab
{
	foreach (@_) { $esab_data .= $_ }
}

sub flush_46esab
{
	print encode_46esab($esab_data);
}


######################################################################
# query
#

sub query_project
{
	my @f = <url_*>;
	return 1 unless scalar @f;
	foreach (@f) {
		s/^url_//g;
		query_progress($_);
	}
	undef;
}

sub query_no_project
{
	print_46esab << "EOF";
		<div id="download" class="download">
			<h1>No Project.</h1>
		</div>
EOF
}

sub query_progress
{
	my $proj = shift;
	my $p46  = encode_46esab($proj);
	my $prog = read_from_file("status_$proj");

	$prog eq '' and do {
		print_46esab << "EOF";
			<div id="download" class="download">
				<div style="float: right">
				<div class="button" style="width: 60px;" onclick="delete_project('$p46');">DELETE</div>
				</div>
				<b>$proj</b><br>
				<font color=red>Read status failed.</font>
			</div>
EOF
		return;
	};

	$prog =~ /^-?[0-9]+$/ or do {
		print_46esab << "EOF";
			<div id="download" class="download">
				<div style="float: right">
				<div class="button" style="width: 60px;" onclick="delete_project('$p46');">DELETE</div>
				</div>
				<b>$proj</b><br>
				<font color=red>Error: $prog</font>
			</div>
EOF
		return;
	};

	$prog == -2 and do {
		print_46esab << "EOF";
			<div id="download" class="download">
				<div style="float: right">
				<div class="button" style="width: 60px;" onclick="start_project('$p46');">START</div>
				<div class="button" style="width: 60px;" onclick="delete_project('$p46');">DELETE</div>
				</div>
				<b>$proj</b><br>
				<i>Not started yet.</i>
			</div>
EOF
		return;
	};

	$prog == -1 and do {
		print_46esab << "EOF";
			<div id="download" class="download">
				<div style="float: right">
				<div class="button" style="width: 60px;" onclick="stop_project('$p46');">STOP</div>
				<div class="button" style="width: 60px;" onclick="delete_project('$p46');">DELETE</div>
				</div>
				<b>$proj</b><br>
				<progress></progress>
			</div>
EOF
		return;
	};

	$prog == 100 and do {
		print_46esab << "EOF";
			<div id="download" class="download">
				<div style="float: right">
				<div class="button" style="width: 60px;" onclick="get_project('$p46');">GET</div>
				<div class="button" style="width: 60px;" onclick="delete_project('$p46');">DELETE</div>
				</div>
				<b style="color: #2a2;">$proj</b><br>
				Done.
			</div>
EOF
		return;
	};

	print_46esab << "EOF";
		<div id="download" class="download">
			<div style="float: right">
			<div class="button" style="width: 60px;" onclick="stop_project('$p46');">STOP</div>
			<div class="button" style="width: 60px;" onclick="delete_project('$p46');">DELETE</div>
			</div>
			<b>$proj</b><br>
			<progress max=100 value=$prog></progress> <i>$prog%</i>
		</div>
EOF
}


######################################################################
# misc
#

sub write_to_file
{
	my $fname = shift;
	my $data  = shift;
	while (-e "lock_$fname") {}
	`touch lock_$fname`;
	open my $f, "> $fname" or die "unable to write file.";
	print $f $data;
	close $f;
	unlink "lock_$fname";
}

sub read_from_file
{
	my $fname = shift;
	while (-e "lock_$fname") {}
	`touch lock_$fname`;
	my $data = '';
	open my $f, "< $fname" or die "unable to read file.";
	while (<$f>) { $data .= $_ }
	close $f;
	unlink "lock_$fname";
	$data;
}

sub start_download
{
	my $proj = shift;
	write_to_file("status_$proj", -1);
	write_to_file("do_$proj", "");

	my $pid = fork;
	defined $pid or die "unable to fork.";
	return if $pid;		# parent

	####### child #######
	Proc::Daemon::Init();
	chdir $PROJ_HOME;

	open my $f, "> dl_$proj" or do {
		write_to_file("status_$proj", "unable to write file.");
		exit 1;
	};
	binmode $f;

	my $ua = LWP::UserAgent->new;
	my $len;
	my $nrecv = 0;
	my $url = read_from_file("url_$proj");
	my $req = $ua->request(HTTP::Request->new(GET => $url), sub {
		read_from_file("do_$proj") eq 'STOP' and do {
			write_to_file("status_$proj", -2);
			exit;
		};

		my ($chunk, $res) = @_;
		$nrecv += length($chunk);
		$len = $res->content_length unless defined $len;
		$len = 0 unless defined $len;

		if ($len) {
			write_to_file("status_$proj", int(99 * $nrecv / $len));
		}
		else {
			write_to_file("status_$proj", -1);
		}

		print $f $chunk;
	});
	close $f;
	if ($req->status_line =~ /^200\s.*/) {
		write_to_file("status_$proj", 100);
	}
	else {
		write_to_file("status_$proj", $req->status_line);
	}
}

