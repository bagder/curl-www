require "CGI.pm";

our $root="/var/www/html";

sub stitle {
    my ($title)=@_;
    return "<h1 class=\"pagetitle\">".CGI::escapeHTML($title)."</h1>";
}

sub title {
    my $title=$_[0];
    print stitle($title);
}

sub subtitle {
    my $title=$_[0];
    print "<h2>".CGI::escapeHTML($title)."</h2>";
}

sub where {
    my @args = @_;
    my $name;
    my $link;
    my $pic="/";

    print "<div class=\"where\"><a href=\"/\">curl</a> $pic";
    while(1) {
        $name = shift @args;
        $link = shift @args;
        if($name) {
            # things look ok
            if($link) {
                print " <a href=\"$link\">".CGI::escapeHTML($name)."</a> $pic";
            }
            else {
                print " <b>".CGI::escapeHTML($name)."</b>";
            }
        }
        else {
            last; # get out of loop
        }
    }
    print "</div>\n";
}

# catfile assumes a HTML-encoded file!
sub catfile {
    open (CAT, $_[0]);
    while(<CAT>) {
        print $_;
    }
    close(CAT);
}

# <pre>-print a file, convert to HTML encoding
sub precatfile {
    open (CAT, $_[0]);
    print "<pre>\n";
    while(<CAT>) {
        print CGI::escapeHTML($_);
    }
    close(CAT);
    print "</pre>\n";
}

sub header {
    my ($ihead)=@_;
    my $head = CGI::escapeHTML($ihead);

    open(HEAD, "<$root/head.html");
    while(<HEAD>) {
        $_ =~ s/\<title\>curl\<\/title\>/<title>curl: $head<\/title>/;
        print $_;
    }
    close(HEAD);
}

sub footer {
    open(FOOT, "<$root/foot.html");
    while(<FOOT>) {
        print $_;
    }
    close(FOOT);
}

1;
