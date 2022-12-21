# Praat script to work with P2FA
# Basically, we can extract

# Read the textgrid files from the folder
# Store the file name as a variable - it needs to output in the datafile
# Add tier 3 (if not already has one)
# Loop over Tier 2 (characters):
# locate the start time and end time and end boundaries
# then based on this time, find the high interval in tier 1, then read the end time of the interval, also add a boundary at tier3
# parameter extraction 1: rime
# parameter extraction 2: onset+rime if sonorant

textgrid = selected("TextGrid")
textgrid$ = selected$("TextGrid")

char_tier = 2
seg_tier = 1

tiers = Get number of tiers
if tiers == 2
  Insert interval tier: 3, "rhyme"
elsif tiers == 3
  Remove tier: 3
  Insert interval tier: 3, "rhyme"
else
  exitScript: "Number of tiers is not 2 or 3"
endif

char_intervals = Get number of intervals: char_tier

# the loop is from beginnign to end, for it is not always ending with 'sp'
for i from 1 to char_intervals

  #label_char$ = Get label of interval: char_tier, i
  start_char = Get start time of interval: char_tier, i
  end_char = Get end time of interval: char_tier, i
  # check if it is the start of the file (it will not be recognised as an interval boundary)
  isstart = Get interval boundary from time: char_tier, start_char
  # check if there is already an boudnary (e.g.zero onset syllables)
  isboundary = Get interval boundary from time: 3, start_char
  if isstart != 0 & isboundary = 0
  	Insert boundary: 3, start_char
  endif

  # Find the onset ending time, and add the boundary
  onset_interval = Get high interval at time: seg_tier, start_char
  onset_end = Get end time of interval: seg_tier, onset_interval

  # check if it is the end of the file (it will not be recognised as an interval boundary)
  isend = Get interval boundary from time: seg_tier, onset_end
  if isend != 0
	# Determine the rhyme text
  	rhyme_interval_start = Get high interval at time: seg_tier, onset_end
  	rhyme_interval_end = Get low interval at time: seg_tier, end_char
	# If it is a zero onset
  	if rhyme_interval_start == rhyme_interval_end + 1
		rhyme_label$ = Get label of interval: seg_tier, rhyme_interval_end
	else
		rhyme_label$ = ""
  		for m from rhyme_interval_start to rhyme_interval_end
			label_seg$ = Get label of interval: seg_tier, m
			rhyme_label$ = rhyme_label$ + label_seg$
  		endfor
	endif

	# check if there is already an boudnary (e.g.zero onset syllables)
	isboundary = Get interval boundary from time: 3, onset_end
	if isboundary = 0
  		Insert boundary: 3, onset_end
    endif

	# The method of setting interval text: get the interval index of tier 3 based on end_char time
	#interval_count = 2*i-1
	# If the label is sp, then discard
	if rhyme_label$ != "sp"
		interval_count = Get low interval at time: 3, end_char
		Set interval text: 3, interval_count, rhyme_label$
	endif
  endif
endfor
