#!/usr/bin/perl
use CGI;
use CGI::Carp qw(fatalsToBrowser);

my $q = CGI->new;
print $q->header(-charset=>'utf-8');
print $q->redirect('http://cjprods.org');
print $q->title('Labs for Clanjor Prods.');
print $q->h1("This is the Labs for Clanjor Prods.");
print $q->h2("You should have not accessed this!");

