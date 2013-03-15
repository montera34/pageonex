#!/usr/bin/env perl

use strict;
use warnings;
use utf8;
use LWP::UserAgent;
use HTML::TreeBuilder 5 -weak;
use URI;

use constant LANG => qw(en es fr);

# No stdout buffering
$|++;

# Force UTF8 output
binmode(STDOUT, ":utf8");

# Define which kiosko root page we're taking
@ARGV == 1 or usage();
my ($lang) = @ARGV;
grep { $_ eq $lang } (LANG) or usage();

my $kiosko_url = "http://$lang.kiosko.net";

# Regexps to get countries
my %regexp = (
    es => q|Periódicos de (.+?)\. Toda la prensa de hoy|,
    en => q|Newspapers in (.+?)\. Today's press covers|,
    fr => q|Les Unes des journaux de (.+?)\. Toute la presse d'aujourd'hui|,
);

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

# Header
print "Country,Country code,Newspaper name,Newspaper code,Newspaper url\n";

for my $country_page (@country_pages) {
    my $p_uri = URI->new_abs($country_page, $kiosko_url);
    my $p_tree = HTML::TreeBuilder->new_from_url($p_uri->as_string);

    # Get title of this page to have the country
    # Title of pages have the format i.e 
    # "Periódicos de Argentina. Toda la prensa de hoy. Kiosko.net"
    # "Periódicos de R. Dominicana. Toda la prensa de hoy. Kiosko.net"
    my ($p_title_tag) = $p_tree->look_down('_tag', 'title');
    
    # Cannot do it this way due to Dominican Republic :(
    #my ($country) = (split /\s/, (split /\./, $p_title_tag->as_text)[0])[-1];

    my ($country) = ($p_title_tag->as_text =~ qr|$regexp{$lang}|) ? $1 : $p_title_tag->as_text;

    # We search through all the newspaper types in titPpal class
    my @tit_ppal = $p_tree->look_down(
        '_tag', 'div', sub {
            defined $_[0]->attr('class') && 
            $_[0]->attr('class') eq 'titPpal' 
         }
    );

    # TODO: Search also in all geo papers in the class auxCol. Then sort as we may have
    # duplicates with those fetched in the titPpal class 

    for my $t (@tit_ppal) {
        my $a_tit_ppal = $t->look_down('_tag', 'a', sub { defined $_[0]->attr('href') } );

        defined $a_tit_ppal or next;

        my $tit_ppal_uri = URI->new_abs($a_tit_ppal->attr('href'), $p_uri);
        my $titppal_tree = HTML::TreeBuilder->new_from_url($tit_ppal_uri->as_string);

        # Links of the newspapers are in the a tags having
        # class=thcover and the attribute href defined
        my @titppal_a_tags = $titppal_tree->look_down(
            '_tag', 'a',
            sub {
                defined $_[0]->attr('class') && 
                $_[0]->attr('class') eq 'thcover' &&
                defined $_[0]->attr('href')
            }
        );

        for my $a (@titppal_a_tags) {
            my $n_uri = URI->new_abs($a->attr('href'), $kiosko_url);
            my $n_tree = HTML::TreeBuilder->new_from_url($n_uri->as_string);

            my $n_title_tag = $n_tree->look_down('_tag', 'title');

            # Get newspaper name
            # Newspaper pages names have the format, i.e
            # "Periódico Diario Libre (R. Dominicana). Periódicos de R. Dominicana. Toda la prensa de hoy. Kiosko.net"
            my $n_name = $n_title_tag->as_text;
            $n_name =~ s/ \(.+//;
            $n_name =~ s/[^\s]+\s//;

            # Get newspaper code
            # newspaper links have the format: /fr/np/presseocean.html
            my ($n_code) = ( split /\//, $a->attr('href') )[-1];
            $n_code =~ s/\.html//;

            # Remove slashes from country_page
            $country_page =~ s:/::g;

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

            my $newspaper_url;
            if (defined $url_ent) {
                $newspaper_url = $url_ent->attr('href');
                $newspaper_url =~ s/"//g; # remove quotes from the url
            }
            else {
                $newspaper_url = 'UNKNOWN';
            }
                
            print join(',', $country, $country_page, $n_name, $n_code, $newspaper_url), "\n";
        }
    }
}

sub usage {
    die sprintf "Usage: $0 <%s>\n", join '|', (LANG);
}
