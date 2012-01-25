on run argv
	
	tell application "/Applications/CoverStory.app"
	    quit
		activate
		set x to open (item 1 of argv)
		tell x to export to HTML in (item 2 of argv)
		quit
	end tell
	
	return item 1 of argv & "|" & item 2 of argv
	
end run