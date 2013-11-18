#!/usr/bin/perl

# get tivo
# Grabs TiVo now playing from TiVo web and converts to list for inclusion on web page
# By Richard Smith
# Placed in the public domain, but credit and linkage to www.chatbear.com is always nice :)

use LWP::Simple;

$page = get("http://your.domain.com:810/nowshowing");

($mainblock) = $page =~ /<TABLE border=0 cellspacing=0 cellpadding=0 >(.*?)<\/TABLE>/sig;
@shows = $mainblock =~ /<TR >(.*?)<\/TR>/sig;

open(OUT, ">/your/path/showlist");

foreach $show (@shows) {
	@columns = $show =~ /<TD>(.*?)<\/TD>/sig;
	
	# Status
	if ($columns[0] eq "&nbsp;") {
		$status = "New";
	} elsif ($columns[0] =~ /ExpireNever/) {
		$status = "Never Delete";
	} elsif ($columns[0] =~ /Recording/) {
		$status = "Recording";
	} elsif ($columns[0] =~ /Suggest/) {
		$status = "Suggestion";
	} elsif ($columns[0] =~ /Expired/) {
		$status = "Expired";
	} else {
		$status = "Unknown";
	}
	
	# Show Name
	$columns[1] =~ s/<.*?>//g;
	$showname = $columns[1];
	
	# Description
	($description) = $columns[2] =~ /A title="(.*?)"/i;
	
	# Episode Name
	$columns[2] =~ s/<.*?>//g;
	$episodename = $columns[2];
	
	# Day
	$columns[3] =~ s/<.*?>//g;
	$day = $columns[3];
	
	# Date
	$columns[4] =~ s/<.*?>//g;
	$date = $columns[4];
	$date =~ s/^\s+//g;
	
	if (length($description) > 50) {
		$description = substr($description, 0, 50) . "...";
	}
	
	print OUT qq|<p><span class="sidebar"><b>$showname</b> ($status)<br><b>$episodename</b><br>$description<br><i>Recorded on $day $date</i></p>|;
	
}
close(OUT);

