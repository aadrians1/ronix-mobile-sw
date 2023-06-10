# SCCS ID @(#)MD5.pm	1.2 94/11/07
package MD5;

require Exporter;
require DynaLoader;
@ISA = qw(Exporter DynaLoader);
# Items to export into callers namespace by default
@EXPORT = qw();
# Other items we are prepared to export if requested
@EXPORT_OK = qw();


bootstrap MD5;

sub addfile
{
    my ($self, $handle) = @_;
    my ($len, $data);

    while ($len = read($handle, $data, 1024))
    {
	$self->add($data);
    }
}

sub hexdigest
{
    my ($self) = shift;

    unpack("H*", ($self->digest()));
}

1;
