#!/usr/bin/perl

use v5.10.1;
use strict;
use MIME::Lite;
use File::MMagic;
use Getopt::Std;

my %opt = ();
getopts('a:', \%opt);
my $attachment_dirname = $opt{a};

my $mm = new File::MMagic;

my $dirname = $ARGV[0];
my $dir;
my @dircontents;
opendir($dir, $dirname) || die "cannot open $dirname: $!";
@dircontents = readdir($dir);
close($dir);

my $message = MIME::Lite->new(
	Type		=> 'multipart/mixed',
);
foreach my $file (@dircontents) {
	$file =~ '^\.' && (print STDERR "skipping $file" && next);
	my $filepath = $dirname . '/' . $file;
	my $mimetype = $mm->checktype_filename($filepath);
	$message->attach(
		Type		=> $mimetype,
		Path		=> $filepath,
		Filename	=> $file,
		Encoding	=> 'base64',
		Disposition	=> 'inline',
	),
}

if ($attachment_dirname ne '') {
	opendir($dir, $attachment_dirname) || die "cannot open $dirname: $!";
	@dircontents = readdir($dir);
	close($dir);
	foreach my $file (@dircontents) {
		$file =~ '^\.' && (print STDERR "skipping $file" && next);
		my $filepath = $attachment_dirname . '/' . $file;
		my $mimetype = $mm->checktype_filename($filepath);
		$message->attach(
			Type		=> $mimetype,
			Path		=> $filepath,
			Filename	=> $file,
			Encoding	=> 'base64',
			Disposition	=> 'attachment',
		),
	}
}

print $message->as_string;
