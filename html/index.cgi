#!/home/ivan/bin/perl
#!/home/ivan/bin/speedy
#!/usr/bin/perl

use strict;
use warnings;

use lib qw(../lib /home/ivan/perl);
use CGI;
use CGI::Carp 'fatalsToBrowser';
use Template;
use AnnoCPAN::Config '../config.pl';
use AnnoCPAN::Control;

AnnoCPAN::Control->new->run;

