package Dist::Zilla::Plugin::ChangelogFromGit::Debian;
{
  $Dist::Zilla::Plugin::ChangelogFromGit::Debian::VERSION = '0.03';
}
use Moose;

# ABSTRACT: Debian formatter for Changelogs

extends 'Dist::Zilla::Plugin::ChangelogFromGit';

use DateTime::Format::Mail;
use Text::Wrap qw(wrap fill $columns $huge);

has 'package_name' => (
    is => 'rw',
    isa => 'Str',
    required => 1
);

sub render_changelog {
    my ($self) = @_;

	$Text::Wrap::huge    = 'wrap';
	$Text::Wrap::columns = $self->wrap_column;
	
	my $changelog = '';
	
	foreach my $release (reverse $self->all_releases) {

        # Don't output empty versions.
        next if $release->has_no_changes;

        my $version = $release->version;
        if($version eq 'HEAD') {
            $version = $self->zilla->version;
        }

		my $tag_line = $self->package_name.' ('.$version.') stable; urgency=low';
		$changelog .= (
			"$tag_line\n"
		);

	    foreach my $change (@{ $release->changes }) {
	        
	        unless ($change->description =~ /^\s/) {
                $changelog .= fill("    ", "    ", $change->description)."\n\n";
            }
            $changelog .= ' -- '.$change->author_name.' <'.$change->author_email.'>  '.DateTime::Format::Mail->format_datetime($change->date)."\n\n";

	    }
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

version 0.03

=head1 SYNOPSIS

    [ChangelogFromGit::Debian]
    max_age = 365
    tag_regexp = ^\d+\.\d+$
    file_name = debian/changelog
    wrap_column = 72
    package_name = my-package # required!!

=head1 DESCRIPTION

Dist::Zilla::Plugin::ChangelogFromGit::Debian extends
L<Dist::Zilla::Plugin::ChangelogFromGit> to create changelogs acceptable
for Debian packages.

=head1 AUTHOR

Cory G Watson <gphat@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Infinity Interactive, Inc.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

