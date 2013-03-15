#!/usr/bin/env perl

use strict;
use warnings;
use utf8;
use LWP::UserAgent;
use HTML::TreeBuilder 5 -weak;
use URI;

use constant LANG => qw(en es fr);

# Force UTF8 output
binmode(STDOUT, ":utf8");

# Define which kiosko root page we're taking
@ARGV == 1 or usage();
my ($lang) = @ARGV;
grep { $_ eq $lang } (LANG) or usage();

my $kiosko_url = "http://$lang.kiosko.net";

# top page
my $tree = HTML::TreeBuilder->new_from_url($kiosko_url);

# Get HTML::Entities from top page
# Look for <a> tags with 
# - a defined href 
# - a title Periodicos
my @a_tags = $tree->look_down(
    '_tag', 'a',
    sub { 
        defined $_[0]->attr('href')  && 
        defined $_[0]->attr('title') && $_[0]->attr('title') =~ /^Periodicos de/ 
    },
);

# Get a sorted unique list of country codes
# Exclude geo links as we will get it afterwards looking into the country pages
my %uniq;
my @country_pages = 
    grep { ! $uniq{$_}++ } 
        sort grep { ! m:/geo/: } map { $_->attr('href') } @a_tags;

# @ouput array of arrays
my @output = (
    [qw(Country Country_code Newspaper_name Newspaper_code Newspaper_url)]
);

for my $country_page (@country_pages) {
    my $p_uri = URI->new_abs($country_page, $kiosko_url);
    my $p_tree = HTML::TreeBuilder->new_from_url($p_uri->as_string);

    # We search through all the newspaper types in titPpal class
    my @tit_ppal = $p_tree->look_down(
        '_tag', 'div', sub {
            defined $_[0]->attr('class') && 
            $_[0]->attr('class') eq 'titPpal' 
         }
    );

    push @output, get_thcover_data($p_uri, @tit_ppal);

    # Search also in all geo papers in the class auxCol. We will remove
    # duplicates afterwards
    my $aux_col = $p_tree->look_down(
        '_tag', 'div', sub {
            defined $_[0]->attr('class') && 
            $_[0]->attr('class') eq 'auxCol' 
         }
    );

    my @li_aux_col = $aux_col->look_down(
        '_tag', 'li', sub { 
            defined $_[0]->attr('class') && 
            $_[0]->attr('class') eq 'reg' 
        }
    );

    push @output, get_thcover_data($p_uri, @li_aux_col);

}

# sort @output to get unique members
# we stringify the array refs as they will be printed to
# compare entries.
%uniq = ();
my @output_sorted = 
    grep { ! $uniq{$_}++ } 
    map  { join ',', @$_ }
    @output;

print "$_\n" for @output_sorted;

sub usage {
    die sprintf "Usage: $0 <%s>\n", join '|', (LANG);
}

sub get_thcover_data {
    my ($p_uri, @elements) = @_;

    my @thcover_data;
    for my $e (@elements) {
        my $a_top = $e->look_down('_tag', 'a', sub { defined $_[0]->attr('href') } );
        defined $a_top or next;
        my $top_uri = URI->new_abs($a_top->attr('href'), $p_uri);

        my $tree = HTML::TreeBuilder->new_from_url($top_uri);

        # Links of the newspapers are in the a tags having
        # class=thcover and the attribute href defined
        my @a_tags = $tree->look_down(
            '_tag', 'a',
            sub {
                defined $_[0]->attr('class') && 
                $_[0]->attr('class') eq 'thcover' &&
                defined $_[0]->attr('href')
            }
        );

        for my $a (@a_tags) {
            my $n_uri = URI->new_abs($a->attr('href'), $kiosko_url);
            my $n_tree = HTML::TreeBuilder->new_from_url($n_uri->as_string);

            my $n_title_tag = $n_tree->look_down('_tag', 'title');

            # Get newspaper name
            # Newspaper pages names have the format, i.e
            # "Periódico Diario Libre (R. Dominicana). Periódicos de R. Dominicana. Toda la prensa de hoy. Kiosko.net"
            my $n_name;
            my $country;
            if ($n_title_tag->as_text =~ /
                (?:Periódico|Newspaper|Journal)\s
                ( [^(]+ )\s                         # Newspaper name
                \( ( [^)]+ ) \) \.                  # Country
            /x) {
                $n_name  = $1;
                $country = $2;
            }
            else {
                die "Cannot parse page ", $n_uri->as_string, " title";
            }

            # Get newspaper code
            # newspaper links have the format: /fr/np/presseocean.html
            my (undef, $country_page, undef, $n_code) = split /\//, $a->attr('href');
            $n_code =~ s/\.html//;

            # Get newspaper url
            # Newspapers links are inside frontPageImage div classes,
            # in the href attr of the only <a> tag inside
            my $n_fpi = $n_tree->look_down(
                '_tag', 'div', sub {
                    defined $_[0]->attr('class') && 
                    $_[0]->attr('class') eq 'frontPageImage' 
                }
            );

            my $url_ent; # entity that contains newspaper url

            if (defined $n_fpi) {
                $url_ent = $n_fpi->look_down('_tag', 'a');
            }
            else {
                # We haven't found a frontPageImage div class
                # we'll try an alternative approach. We'll look for
                # <a> tags with an href and a title as "Portada del periodico
                $url_ent = $n_tree->look_down(
                    '_tag', 'a', sub {
                        defined $_[0]->attr('href') &&
                        defined $_[0]->attr('title') &&
                        $_[0]->attr('title') =~ /Portada del peri/;
                    }
                );
            }

            my $n_url;
            if (defined $url_ent) {
                $n_url = $url_ent->attr('href');
                $n_url =~ s/"//g; # remove quotes from the url
            }
            else {
                $n_url = 'UNKNOWN';
            }
                
            push @thcover_data, [$country, $country_page, $n_name, $n_code, $n_url];
        }
    }

    return @thcover_data;
}
