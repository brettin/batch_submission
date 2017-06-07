use strict;
use assemble;
use Getopt::Long; 
use JSON;
use Pod::Usage;
use File::Basename;
use IPC::Run 'run';

my $man  = 0;
my $help = 0;
my ($in, $out);

GetOptions(
	'h'	=> \$help,
        'i=s'   => \$in,
        'o=s'   => \$out,
	'help'	=> \$help,
	'man'	=> \$man,
	'input=s'  => \$in,
	'output=s' => \$out,

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

my $obj = assemble->new();
my $rv  = $obj->batch-assemble();

# create json params object
# submit assembly; assemblies are asyncronous; use awe-active_jobs to see state
# the pattern is to return ws-path of assembly object [tab] ws-path of input objects
# what would be useful is the asesmbly job id. I'd propose returning that too.


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

 

=pod

=head1	NAME

batch-assemble

=head1	SYNOPSIS

batch-assemble <options>

=head1	DESCRIPTION

The batch-assemble command calls the batch-assemble method of a assemble object.

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

=back

=head1	AUTHORS

brettin

=cut

1;

