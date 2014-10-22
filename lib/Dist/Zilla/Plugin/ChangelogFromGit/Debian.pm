package Dist::Zilla::Plugin::ChangelogFromGit::Debian;
{
  $Dist::Zilla::Plugin::ChangelogFromGit::Debian::VERSION = '0.08';
}
use Moose;

# ABSTRACT: Debian formatter for Changelogs

extends 'Dist::Zilla::Plugin::ChangelogFromGit';

use DateTime::Format::Mail;
use Text::Wrap qw(wrap fill $columns $huge);


has 'allow_empty_head' => (
    is => 'rw',
    isa => 'Bool',
    default => 1
);


has 'dist_name' => (
    is => 'rw',
    isa => 'Str',
    default => 'stable'
);


has 'maintainer_email' => (
    is => 'rw',
    isa => 'Str',
    default => 'cpan@example.com'
);


has 'maintainer_name' => (
    is => 'rw',
    isa => 'Str',
    default => 'CPAN Author'
);


has 'package_name' => (
    is => 'rw',
    isa => 'Str',
    lazy => 1,
    default => sub {
        my $self = shift;
        return lc($self->zilla->name)
    }
);

sub render_changelog {
    my ($self) = @_;

	$Text::Wrap::huge    = 'wrap';
	$Text::Wrap::columns = $self->wrap_column;
	
	my $changelog = '';
	
	foreach my $release (reverse $self->all_releases) {

        # Don't output empty versions, unless it's HEAD cuz that might matter!
        next if $release->has_no_changes && $release->version ne 'HEAD';
        if($release->version eq 'HEAD') {
            next unless $self->allow_empty_head;
        }

        my $version = $release->version;
        if($version eq 'HEAD') {
            $version = $self->zilla->version;
        }

		my $tag_line = $self->package_name.' ('.$version.') '.$self->dist_name.'; urgency=low';
		$changelog .= (
			"$tag_line\n"
		);

        my $firstchange = undef;
	    foreach my $change (@{ $release->changes }) {
	        unless(defined($firstchange)) {
	            $firstchange = $change;
	        }
	        unless ($change->description =~ /^\s/) {
                $changelog .= fill("  ", "    ", '* '.$change->description)."\n";
            }
	    }
	    if($release->has_no_changes) {
            $firstchange = Software::Release::Change->new(
                description => 'no changes',
                date => DateTime->now
            );
        }
        $changelog .= "\n -- ".$self->maintainer_name.' <'.$self->maintainer_email.'>  '.DateTime::Format::Mail->format_datetime($firstchange->date)."\n\n";
	}
	
	return $changelog;
}


__PACKAGE__->meta->make_immutable;
no Moose;
1;
__END__
=pod

=head1 NAME

Dist::Zilla::Plugin::ChangelogFromGit::Debian - Debian formatter for Changelogs

=head1 VERSION

version 0.08

=head1 SYNOPSIS

    #    [ChangelogFromGit::Debian]
    #    max_age = 365
    #    tag_regexp = ^\d+\.\d+$
    #    file_name = debian/changelog
    #    wrap_column = 72
    #    dist_name = squeeze # defaults to stable
    #    package_name = my-package # defaults to lc($self->zilla->name)

=head1 DESCRIPTION

Dist::Zilla::Plugin::ChangelogFromGit::Debian extends
L<Dist::Zilla::Plugin::ChangelogFromGit> to create changelogs acceptable
for Debian packages.

=head1 ATTRIBUTES

=head2 allow_empty_head

If true then an empty head is allowed. Since this module converts head to
the current dzil version, this might be useful to you for some reason.

=head2 dist_name

The distribution name for this package.

=head2 maintainer_email

The maintainer email for this package.

=head2 maintainer_name

The maintainer name for this package.

=head2 package_name

The package name for this package.

=head1 AUTHOR

Cory G Watson <gphat@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Infinity Interactive, Inc.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

