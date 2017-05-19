
my $user = $ARGV[0] or die "";
my $ws_base = '/' . $user . '@patricbrc.org/home/',

open IN, $ARGV[1] or die "";

my $template = $ARGV[2];
$template = "ws-create.tt" unless -e $template;

while(<IN>) {
	chomp;
	my ($dir,$dest,$source)=split/\t/;
	$folder = $ws_base . $dir;
	print `tpage --define folder=$folder --define dest=$dest --define source=$source < $template`;
}
