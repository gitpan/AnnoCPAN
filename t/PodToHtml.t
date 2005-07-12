use strict;
use warnings;
use Test::More;
use AnnoCPAN::Config 't/config.pl';
use AnnoCPAN::PodToHtml;

#plan 'no_plan';
plan tests => 3;

my $parser = AnnoCPAN::PodToHtml->new;
isa_ok( $parser, 'AnnoCPAN::PodToHtml' );

my $html = $parser->verbatim(" aaa");
is ( $html, qq{<div class="content"><div><pre> aaa</pre></div></div>\n}, "pre" );

$html = $parser->ac_i_L("My::Pod");
is ( $html, qq{\0<a href="/perldoc?My::Pod"\0>My::Pod\0</a\0>}, "L<My::Pod>" );
