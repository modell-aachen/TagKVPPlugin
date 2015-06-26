# See bottom of file for default license and copyright information

package Foswiki::Plugins::TagKVPPlugin;

use strict;
use warnings;

use Foswiki::Func    ();    # The plugins API
use Foswiki::Plugins ();    # For the API version

our $VERSION = '1.0';
our $RELEASE = '1.0';

our $SHORTDESCRIPTION = 'Tag topics';

our $NO_PREFS_IN_TOPIC = 1;

sub initPlugin {
    my ( $topic, $web, $user, $installWeb ) = @_;

    # check for Plugins.pm versions
    if ( $Foswiki::Plugins::VERSION < 2.0 ) {
        Foswiki::Func::writeWarning( 'Version mismatch between ',
            __PACKAGE__, ' and Plugins.pm' );
        return 0;
    }

    Foswiki::Func::registerRESTHandler( 'tag', \&restTag );

    # Plugin correctly initialized
    return 1;
}

sub restTag {
    my ( $session, $subject, $verb, $response ) = @_;

    my $query = Foswiki::Func::getCgiQuery();
    my @tagArray = $query->param('tags'); # this might be an array from jqtextboxlist or a simple string or a combination
    my $tags = join(',', @tagArray); # now it's definitely a string
    $tags =~ s#^\s*|\s*$##g;
    @tagArray = split(/\s*,\s*/, $tags);
    $tags = join(',', grep { /\S+/ } unique(@tagArray));
    my $webtopic = $query->param('webtopic');
    unless( $webtopic ) {
        die "Missing parameter: webtopic";
    }

    my ($web, $topic) = Foswiki::Func::normalizeWebTopicName(undef, $webtopic);
    unless( Foswiki::Func::topicExists($web, $topic) ) {
        die "Topic does not exist: $web.$topic";
    }

    my ($meta, $text) = Foswiki::Func::readTopic($web, $topic);

    my $condition = $Foswiki::cfg{Plugins}{TagKVPPlugin}{condition};
    die 'Please set {Plugins}{TagKVPPlugin}{condition} in configure' unless defined $condition;
    $condition = Foswiki::Func::expandCommonVariables($condition, $topic, $web, $meta);
    return "You are not allowed to tag '$web.$topic'" unless Foswiki::Func::isTrue($condition);

    my $oldTags = $meta->get('FIELD', 'Tags');
    if (!$oldTags || !$oldTags->{value} || $oldTags->{value} ne $tags) {
        $meta->putKeyed('FIELD', { name => 'Tags', title => 'Tags', value => $tags });

        my $context = Foswiki::Func::getContext();
        my $oldContext = $context->{IgnoreKVPPermission};
        $context->{IgnoreKVPPermission} = 1;
        Foswiki::Func::saveTopic($web, $topic, $meta, $text, { forcenewrevision => 1, ignorepermissions => 1, dontlog => 1, minor => 1 });
        $context->{IgnoreKVPPermission} = $oldContext;
    }

    Foswiki::Func::redirectCgiQuery(undef, Foswiki::Func::getScriptUrl($web, $topic, 'view'));
}

sub unique {
    my %seen;
    grep !$seen{$_}++, @_;
}

1;

__END__
Foswiki - The Free and Open Source Wiki, http://foswiki.org/

Copyright (C) 2008-2014 Foswiki Contributors. Foswiki Contributors
are listed in the AUTHORS file in the root of this distribution.
NOTE: Please extend that file, not this notice.

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version. For
more details read LICENSE in the root of this distribution.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

As per the GPL, removal of this notice is prohibited.
