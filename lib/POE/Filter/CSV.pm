# Author Chris "BinGOs" Williams
#
# This module may be used, modified, and distributed under the same
# terms as Perl itself. Please see the license that came with your Perl
# distribution for details.
#

package POE::Filter::CSV;

use strict;
use warnings;
use Text::CSV;
use vars qw($VERSION);
use base qw(POE::Filter);

$VERSION = '1.14';

sub new {
  my $class = shift;
  my $self = {};
  $self->{BUFFER} = [];
  $self->{csv_filter} = Text::CSV->new(@_);
  bless $self, $class;
}

sub get {
  my ($self, $raw) = @_;
  my $events = [];

  foreach my $event ( @$raw ) {
    my $status = $self->{csv_filter}->parse($event);
    push @$events, [ $self->{csv_filter}->fields() ] if $status;
  }
  return $events;
}

sub get_one_start {
  my ($self, $raw) = @_;
  push @{ $self->{BUFFER} }, $_ for @$raw;
}

sub get_one {
  my $self = shift;
  my $events = [];

  my $event = shift @{ $self->{BUFFER} };
  if ( defined $event ) {
    my $status = $self->{csv_filter}->parse($event);
    push @$events, [ $self->{csv_filter}->fields() ] if $status;
  }
  return $events;
}

sub put {
  my ($self,$events) = @_;
  my $raw_lines = [];

  foreach my $event ( @$events ) {
    if ( ref $event eq 'ARRAY' ) {
      my $status = $self->{csv_filter}->combine(@$event);
      push @$raw_lines, $self->{csv_filter}->string() if $status;

    } 
    else {
	warn "non arrayref passed to put()\n";
    }
  }
  return $raw_lines;
}

sub clone {
  my $self = shift;
  my $nself = { };
  $nself->{$_} = $self->{$_} for keys %{ $self };
  $nself->{BUFFER} = [ ];
  return bless $nself, ref $self;
}

1;
__END__

=head1 NAME

POE::Filter::CSV - A POE-based parser for CSV based files.

=head1 SYNOPSIS

    use POE::Filter::CSV;

    my $filter = POE::Filter::CSV->new();
    my $arrayref = $filter->get( [ $line ] );
    my $arrayref2 = $filter->put( $arrayref );

=head1 DESCRIPTION

POE::Filter::CSV provides a convenient way to parse CSV files. It is
a wrapper for the module L<Text::CSV>.

A more comprehensive demonstration of the use to which this module can be
put to is in the examples/ directory of this distribution.

=head1 CONSTRUCTOR

=over

=item new

Creates a new POE::Filter::CSV object. Any arguments given are passed through to the constructor for
L<Text::CSV>.

=back

=head1 METHODS

=over

=item get

=item get_one_start

=item get_one

Takes an arrayref which is contains lines of CSV formatted input. Returns an arrayref of lists of
fields.

=item put

Takes an arrayref containing arrays of fields and returns an arrayref containing CSV formatted lines.

=item clone

Makes a copy of the filter, and clears the copy's buffer.

=back

=head1 AUTHOR

Chris "BinGOs" Williams

=head1 LICENSE

Copyright (C) Chris Williams

This module may be used, modified, and distributed under the same terms as Perl itself. Please see the license that came with your Perl distribution for details.

=head1 SEE ALSO

L<POE>

L<Text::CSV>

L<POE::Filter>

L<POE::Filter::Line>

L<POE::Filter::Stackable>

=cut
