#!/usr/bin/perl
#Author : sumesh k k
#Date 	: 08mar2013
#Purpose: move copy and delete a file currently playing in vlc

die "Capture::Tiny missing!" unless(eval{require Capture::Tiny});
die "Tk missing!" unless(eval{require Tk});
use Capture::Tiny qw/capture/;
use strict;
use warnings;
use Tk;
use File::Copy;

#create Window
my $mw = MainWindow->new(-title => "sumesh's copy program");
#$mw->geometry("500x200");
#create Menu bar
my $menu = $mw->Menu(-title => 'file copy pgm');
my $file_menu = $menu->cascade(-label => 'File');
$file_menu->command(-label => 'Exit', -command => sub {exit});
my $help_menu = $menu->cascade(-label => 'Help');
$help_menu->command(-label => 'Help', -command=> sub {print "\n c-: copy d-: delete "});
$mw->configure(-menu => $menu);

# create Widgets
my $button_move =  $mw->Button(-text => 'Move', -command => \&move_file);
my $button_copy =  $mw->Button(-text => 'Copy', -command => \&copy_file);
my $button_delete =  $mw->Button(-text => 'Delete', -command => \&delete_file);
my $label = $mw->Label(-text => 'Nothing done',-borderwidth =>2, -height => 5, -width => 100 ,-relief=>"groove");
my $label_file = $mw->Label(-text => '',-borderwidth =>2, -height => 1, -width => 100 ,-relief=>"groove");

#geometry management
my $entry = $mw->Entry(-background => 'white', -foreground => 'black', -width => 100)->pack(-side => "top");
#my $textbox = $mw->Text(-background => 'white', -foreground => 'black', -width => 100, -height => 20)->pack(-side => "top");

$label->pack(-padx =>10,-pady => 10,-ipadx => 10, -ipady=>10);
$label_file->pack(-padx =>10,-pady => 10,-ipadx => 10, -ipady=>10);
$button_move->pack(-padx => 5);

$button_delete->pack(-padx =>10,-sid => 'right');
$button_copy->pack(-padx =>10,-side => 'right');
#key bindings

$mw->bind("<Alt-F4>" => sub {exit});
$mw->bind("<Alt-m>" => \&move_file);

#event loop
MainLoop();

#create callbacks

our $playing_file = undef;
 
sub move_file {
	print "--------move sub ---------------\n";
	my $copy_to_dir = undef;
	$playing_file = `lsof -c vlc -a -d\'1-999\' | grep \"^.*\/media\" | awk \'\{i=9\;while \(NF\>\=i\) \{printf\(\"\%s \"\, \$i\)\;i++}\;printf \"\\n\"\}'`;
	#lsof -c vlc -a -d '1-999' | grep "^.*\/media" | awk '{i=9;while (NF>=i) {printf("%s ", $i);i++};printf "\n"}'
	$copy_to_dir = $entry->get;
	$playing_file =~ s/\n$//;
	open(FH,">./tmp");
	open (FH2,">>./inform_bakup.txt");
	print FH "$playing_file\*$copy_to_dir";
	print "Playing file in VLC is: $playing_file";
	print "\n Copy to location is: $copy_to_dir";
	if ( (-d $copy_to_dir) && $playing_file) {
		$label_file->configure(-text => "Currently playing file is: $playing_file");
		print "\ncopy to location : $copy_to_dir\n";
		#my $move = `python ./perl_integ.py` || die "cant open the python command";
		my ($stdout, $stderr) = capture {
 			system ( "python ./perl_integ.py" );		#shell command execution using python file
		};
		print "\nIn Python Program\n..........Sucess........\n$stdout\n..........Failure............\n$stderr \n";
		if ($stdout) {
			#select(FH2);
			#$~ = "MYFORMAT";
			#write;					
			$label->configure(-text => "Copied : $playing_file  to Location: $copy_to_dir error: $stderr");					
		}
		#elsif($stderr) { $label->configure(-text => "$stderr"); }
	}
	elsif (!$copy_to_dir || (!-d $copy_to_dir)) {
		if (!$copy_to_dir) { 
			$label->configure(-text => "To where i should copy the file!!!!!!"); 
		} else {
			$label->configure(-text => "Given location is not a directory!!!!!!"); 
		} #else
	} # first elseif					
	elsif(!$playing_file ||(-f $playing_file)) {
		if (!$playing_file) {
			$label->configure(-text => "Nothing playing in VLC player"); 
		} else {
			$label->configure(-text => "The playing file in VLC is not a valid file"); 
		} #else
	} #second elseif
	close (FH);
}

sub copy_file {
	print "\n ..........Copy sub..............";
        my $entry_message = $entry->get;
        my $playing_file = `ls -l`;
        print "playing file is: ".$playing_file;
        $label->configure(-text => "copied : file to location: $entry_message");
        }

sub delete_file {
	print "\n .........Deleting sub............";
        #my $entry_message = $entry->get;
        #my $playing_file = `ls -l`;
	$playing_file = `lsof -c vlc -a -d\'1-999\' | grep \"^.*\/media\" | awk \'\{i=9\;while \(NF\>\=i\) \{printf\(\"\%s \"\, \$i\)\;i++}\;printf \"\\n\"\}'`;
	$playing_file =~ s/\n$//;
	$playing_file =~ s/\s+$//;
	print "\n$playing_file";
	if ($playing_file) {
		if (unlink($playing_file)) {
			print "$playing_file deleted\n";
			$label->configure(-text => "file deleted with zero error");
		} else {
			$label->configure(-text => "File not deleted error $!");
		}
	} #main if 
	else { $label->configure(-text => "Nothing playing in VLC to DELETE"); }
}



