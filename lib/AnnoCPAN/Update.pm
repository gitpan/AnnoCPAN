package AnnoCPAN::Update;

$VERSION = '0.20';

use strict;
use warnings;

=head1 NAME

=head1 SYNOPSYS

    use AnnoCPAN::Config 'config.pl';
    use AnnoCPAN::Update;
    AnnoCPAN::Update->run(verbose => 1);

=head1 DESCRIPTION

This module is used for updating an annocpan database from a local CPAN
mirror.

=head1 METHODS

=over

=cut

use File::Find qw(find);
use AnnoCPAN::Config;
use AnnoCPAN::Dist qw(:all);

=item new

Construct an AnnoCPAN::Update object. Options

=over 

=item cpan_root

The directory containing the local CPAN mirror.

=item dist_class

The name of the class used to construct CPAN distribution objects. Defaults to
L<AnnoCPAN::Dist>.

=back

=cut

sub new {
    my ($class, %opts) = @_;
    bless \%opts, $class;
    $opts{cpan_root} ||= AnnoCPAN::Config->option('cpan_root');
    $opts{path} = $opts{cpan_root};
    $opts{path} .= '/authors/id' unless $opts{path} =~ m|/authors/id|;
    $opts{cpan_root} =~ s|/authors/id.*||;
    $opts{dist_class} = $opts{dist_class}
        || AnnoCPAN::Config->option('dist_class')
        || 'AnnoCPAN::Dist';
    \%opts;
}

=item run

Does everything: loads the new modules, deletes the modules that no longer
exist, and collects the garbage.

If called as a class method, it calls the constructor automatically.

=cut

sub run {
    my $self = shift;
    return $self->new(@_)->run unless ref $self;
    $self->load_db;
    $self->delete_missing;
    $self->garbage_collect;
}


=item load_db

Load the new modules into the database. Modules that are already loaded are not
affected.

=cut

sub load_db {
    my ($self) = @_;

    my $it = AnnoCPAN::DBI::DistVer->retrieve_all;
    my %seen;
    while (my $dv = $it->next) {
        $seen{$dv->path}++;
    }
    $self->{seen} = \%seen;

    find(
        {wanted => sub { $self->load_dist($_) }, no_chdir => 1 }, 
        $self->{path},
    );
}

=item load_dist($fname)

Load a specific distribution. If it is already in the database, does nothing.

=cut

sub load_dist {
    my ($self, $fname) = @_;

    return unless $fname =~ m{(authors/id/.*(\.tar\.gz|\.zip))$};
    return if $self->{seen}{$1};

    print "$fname\n" if $self->verbose;
    if (my $dist = $self->{dist_class}->new(
        $fname, verbose => $self->verbose)) 
    {
        my ($distver, $status) = $dist->extract;
        if ($distver and $status == DIST_ADDED and not $self->{new}) {
            # this is a new dist; check if notes have to be propagated
            $distver->translate_notes;
        }
    }
}

=item delete_missing

Delete from the database all the distributions that no longer exist in the
CPAN mirror.

=cut

sub delete_missing {
    my ($self) = @_;
    my $it = AnnoCPAN::DBI::DistVer->retrieve_all;
    my $cpan = $self->{cpan_root};
    while (my $distver = $it->next) {
        my $path = $distver->path;
        #print "checking $path\n";
        unless (-e "$cpan/$path") {
            print "deleting entry for $path from database\n" if $self->verbose;
            $distver->delete;
        }
    }
}

=item garbage_collect

Delete from the database the Pods and Dists that no longer exist in any
version.

=cut

sub garbage_collect {
    my ($self) = @_;
    AnnoCPAN::DBI::Pod->garbage_collect;
    AnnoCPAN::DBI::Dist->garbage_collect;
}

sub verbose     { shift->{verbose} }

=back

=head1 SEE ALSO

L<AnnoCPAN::DBI>, L<AnnoCPAN::Config>, L<AnnoCPAN::Dist>

=head1 AUTHOR

Ivan Tubert-Brohman E<lt>itub@cpan.orgE<gt>

=head1 COPYRIGHT

Copyright (c) 2005 Ivan Tubert-Brohman. All rights reserved. This program is
free software; you can redistribute it and/or modify it under the same terms as
Perl itself.

=cut

1;

