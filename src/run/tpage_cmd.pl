
my $user = $ARGV[0] or die "usage: $0 <username> <data_table> <template>";
my $ws_base = '/' . $user . '@patricbrc.org/home/',

open IN, $ARGV[1] or die "";

my $template = $ARGV[2];
$template = "ws-create.tt" unless -e $template;

my $recipe = $ARGV[3];
$recipe = "auto" unless $recipe;

while(<IN>) {
	chomp;
	my ($dir,$dest,$source)=split/\t/;
	my ($read1,$read2) = split /,/,$source;
	$read1 = $ws_base . $read1;
	$read2 = $ws_base . $read2;

	my $folder = $ws_base . $dir;
	my $params_file = "param-data." . $$ . "." . ++$i;
	open P, ">$params_file" or die "";
	print P `tpage --define folder=$folder --define dest=$dest --define read1=$read1 --define read2=$read2 --define recipe=$recipe < $template`;
	print "appserv-start-app GenomeAssembly $params_file $ws_base > $$.$i.log\n";
	close P;
}
