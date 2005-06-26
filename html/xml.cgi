#!/usr/bin/perl

use CGI qw(param escapeHTML);
my $in = escapeHTML(scalar <>);

my $xml = 1;
if ($xml) {
    print qq{Content-type: text/xml\n\n<?xml version="1.0" encoding="UTF-8"?>\n};
    print <<END;
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
<title>a</title>
</head>
<body>
END
} else {
    print "Content-type: text/html\n\n";
}

print <<END;
<div class="note">
    <div class="note_header"> 
        123.123.123.123
        (2005-02-25 16:25:10)
</div> <!-- note_header -->
<div class="note_body">
    this is a sample xml note
    ($in)
</div>
</div> <!-- note -->
END

if ($xml) {
    print "</body>\n</html>\n";
}
