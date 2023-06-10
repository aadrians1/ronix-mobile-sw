package GetDate;

use DynaLoader;
use Exporter;
require "ctime.pl";
@ISA = qw(Exporter DynaLoader);
@EXPORT = qw(&get_date &get_time);

bootstrap GetDate;

sub get_date {
    my $str = &ctime(&get_time(@_));
    chop($str);
    return $str;
}

1;

__END__
