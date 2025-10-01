//Modify this file to change what commands output to your statusbar, and recompile using the make command.
static const Block blocks[] = {
	/*Icon*/	/*Command*/		/*Update Interval*/	/*Update Signal*/

	/* DWMBLOCKS STATUS SCRIPTS */
	// System stats, e.g., CPU, RAM
	{"", "~/dotfiles/scripts/dwmblocks_systemstats", 1, 0},

	// Disk usage
	{"", "~/dotfiles/scripts/dwmblocks_disks", 30, 0},

	// Now playing music
	{"", "~/dotfiles/scripts/dwmblocks_musicplaying", 1, 0},

	// Recording icon
	//{"", "cat /tmp/recordingicon 2>/dev/null",	0,	9},

	//network icon 
	{"", "~/dotfiles/scripts/dwmblocks_network.sh" ,15, 4 },

	// Clock and Date
	{"", "~/dotfiles/scripts/dwmblocks_timedate", 5, 9}
};

//Sets delimiter between status commands. NULL character ('\0') means no delimiter.
static char *delim = " | ";
