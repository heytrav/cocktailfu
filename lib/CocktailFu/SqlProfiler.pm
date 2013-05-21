package CocktailFu::SqlProfiler;

use strict;
use warnings;
use parent qw(DBIx::Class::Storage::Statistics);

use Time::HiRes qw/time/;

my $start;

sub query_start {
    my $self   = shift;
    my $sql    = shift;
    my @params = @_;
    my $params = join ', ' => @params;
    $sql =~ s/((?:(?: LEFT|INNER )\s+)?JOIN)/\n    $1/xgi;
    $sql =~ s/(SELECT|WHERE|FROM|ORDER\s+BY)\s+/$1\n    /xgi;
    $sql =~ s/(FROM|WHERE|ORDER|LIMIT|OFFSET)/\n$1/xgi;
    $sql =~ s/(,|AND)\s/$1\n    /xgi;
    $self->print( "\nExecuting:\n$sql\nParameters:\t" . $params . "\n" );
    $start = time;
}

sub query_end {
    my $self    = shift;
    my $sql     = shift;
    my @params  = @_;
    my $elapsed = sprintf "%0.4f", ( time - $start );
    $self->print("Execution took $elapsed seconds.\n");
    $start = undef;
}

1;

__END__
