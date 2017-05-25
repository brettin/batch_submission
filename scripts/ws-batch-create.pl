use strict;
use Getopt::Long; 
use JSON;
use Pod::Usage;
use File::Basename;
use IPC::Run 'run';

my $man  = 0;
my $help = 0;
my ($in, $out);
my ($user, $type);

GetOptions(
	'h'	=> \$help,
    'i=s'   => \$in,
    'o=s'   => \$out,
	'help'	=> \$help,
	'man'	=> \$man,
	'input=s'  => \$in,
	'output=s' => \$out,
	'u=s'    => \$user,
	'user=s' => \$user,
	't=s'	 => \$type,
	'type=s' => \$type,

) or pod2usage(0);


pod2usage(-exitstatus => 0,
	  -output => \*STDOUT,
	  -verbose => 1,
	  -noperldoc => 1,
	 ) if $help;

pod2usage(-exitstatus => 0,
          -output => \*STDOUT,
          -verbose => 2,
          -noperldoc => 1,
         ) if $man;


# do a little validation on the parameters


my ($ih, $oh);

if ($in) {
    open $ih, "<", $in or die "Cannot open input file $in: $!";
}
else {
    $ih = \*STDIN;
}
if ($out) {
    open $oh, ">", $out or die "Cannot open output file $out: $!";
}
else {
    $oh = \*STDOUT;
}


# main logic
my $ws_base = '/' . $user . '@patricbrc.org/home';

while(<$ih>) {
	chomp;
	my ($remote_path, $local_path);
	eval {
		($remote_path,$local_path) = split /\t/;
		my $dirname  = dirname($remote_path);
		die "local_path $local_path does not exist" unless -e $local_path;

		my $cmd1 = ["ws-create", "-u", "$ws_base/$dirname", "Folder"];
		# print STDERR join (" ", @$cmd1), "\n";
		run_cmd($cmd1);
	
		my $cmd2 = ["ws-create",  "-u", "$ws_base/$remote_path", "$type", $local_path];
		# print STDERR join(" ", @$cmd2), "\n";
		run_cmd($cmd2);
	};
	if($@) {
		die $@, "\n";
	}
	else {
		print $oh "$remote_path\t$local_path\n";
	}
}

sub serialize_handle {
	my $handle = shift or
		die "handle not passed to serialize_handle";
	my $oh = shift or
		die "output file handle not passed to serialize_handle";
        my $json_text = to_json( $handle, { ascii => 1, pretty => 1 } );
	print $oh $json_text;
}	


sub deserialize_handle {
	my $ih = shift or
		die "in not passed to deserialize_handle";
	my ($json_text, $perl_scalar);
	$json_text .= $_ while ( <$ih> );
	$perl_scalar = from_json( $json_text, { utf8  => 1 } );
}

sub run_cmd {
	my ($cmd) = @_;
	my ($out, $err);
	run($cmd, '>', \$out, '2>', \$err)
		or die "Error running cmd=@$cmd, stdout:\n$out\nstderr:\n$err\n";
	# print STDERR "STDOUT:\n$out\n";
	# print STDERR "STDERR:\n$err\n";
	return ($out, $err);
}


=pod

=head1	NAME

batch-create

=head1	SYNOPSIS

batch-create <options>

=head1	DESCRIPTION

The batch-create command calls the batch-create method of a batch-create object.

=head1	OPTIONS

=over

=item	-h, --help

Basic usage documentation

=item   --man

More detailed documentation

=item   -i, --input

The input file, default is STDIN

=item   -o, --output

The output file, default is STDOUT

=item	-u, --user

Your PATRIC username

=item	-t, --type

The type of file being uploaded. Values can be 'contigs' or reads'.

=back

=head1	AUTHORS

brettin

=cut

1;

