# Version 1
# Extraction parameters: inensity, duration
# By Katrina Li (2021.1.19)
# ----
# Version 2
# Based on selected sound & textgrid files
# f0&intesnsity&duration from the segment tier, duration of the corresponding syllable, as well as all the labels
# pointprocess optional
# Suitable for the three-tier system of Cantonese project (2021.3.16)
# Allow using sound name as the name for new files
# ---
# Version 3
# Introduce normalised f0
# ---
# Version 4 (2022.1.19)
# Fix bugs when there is no point process file
# ---
# Version 5 (2022.4.26)
# Incoporate default settings on f0 (male vs. female)
# ---
# Version 6 (2022.9.4)
# Adapt to the p2fa version, massive changes:
# - reduce the form variables, so that the arguments when calling the functions are less
# - no sentence tier, but we only extract and compose the content from the first segment tier
# - some symbols seems not recognized as label (%), therefore only check if not empty
# We keep one sentence has an output file, instead of putting them into one file.

form Extract f0 statistics from labelled intervals of selected tiers
	optionmenu f0setting: 1
		option Male
		option Female
		option Custom
endform

dir$ = "data_chengdu_p2fa/"
pointprocess_dir$ = ""

# Modify the of checking point process file later!
pointprocess = 0 

segment_tier =1
character_tier = 2
rhyme_tier = 3
npoints = 10
# If use custom f0 (default min: male=75, female=100; default max: male=300,female=600)
minf0 = 75
maxf0 = 600

textGridID = selected("TextGrid")
soundID = selected("Sound")
soundname$ = selected$("Sound")


filename$ = soundname$+"_data.txt"
pointprocessname$ = soundname$ + ".PointProcess"

resultsfile$ = dir$ + filename$
if fileReadable(resultsfile$)
  deleteFile: resultsfile$
endif


writeFileLine: resultsfile$,  "interval", tab$, "rhyme_lab", tab$, "character_lab", tab$, "syllable_lab", tab$, "rhyme_dur", tab$, "character_dur", tab$, "f0mean", tab$, "f0min", tab$, "f0max", tab$, "f0min_point", tab$, "f0max_point", tab$, "intmean", tab$,
... "intmin", tab$, "intmax", tab$, "f0_1", tab$, "f0_2", tab$, "f0_3",tab$, "f0_4", tab$, "f0_5", tab$, "f0_6", tab$, "f0_7", tab$, "f0_8", tab$, "f0_9", tab$, "f0_10"

if f0setting == 1
	min_f0 = 75
	max_f0 = 300
elsif f0setting == 2
	min_f0 = 100
	max_f0 = 600
else
	min_f0 = minf0
	max_f0 = maxf0
endif


if pointprocess
	pointprocessID = Read from file: pointprocessdir$ + "/" +
	select 'pointprocessID'
	To PitchTier... 0.02
	pitchtierID = selected("PitchTier")
	select 'pitchtierID'
	To Pitch... 0.02 min_f0 max_f0
	pitchID = selected("Pitch")
else
	select 'soundID'
	To Pitch... 0.02 min_f0 max_f0
	pitchID = selected("Pitch")
endif

select 'soundID'
Scale peak... 0.99
To Intensity... min_f0 0.01 1
intensityID = selected("Intensity")

select 'textGridID'
nintervals = Get number of intervals... rhyme_tier
interval = 1

for m from 1 to nintervals
	select 'textGridID'
	rhyme_lab$ = Get label of interval... rhyme_tier m
	if rhyme_lab$ <> ""
		start = Get starting point... rhyme_tier m
		end = Get end point... rhyme_tier m
		mid = (start + end)/2
		rhyme_dur = end - start

		# Get character information
		character_interval = Get interval at time: character_tier, mid
		character_lab$ = Get label of interval: character_tier, character_interval

		character_start = Get starting point... character_tier character_interval
		character_end = Get end point... character_tier character_interval
		character_dur = character_end - character_start

		# Get corresponding transcriptions of this character
		# Determine the rhyme text
  		segment_interval_start = Get high interval at time: segment_tier, character_start
  		segment_interval_end = Get low interval at time: segment_tier, character_end
		syllable_lab$ = ""
		for q from segment_interval_start to segment_interval_end
			label_segment$ = Get label of interval: segment_tier, q
			syllable_lab$ = syllable_lab$ + label_segment$
		endfor

		select 'pitchID'
		if pointprocess
			f0mean = Get mean... start end Hertz
			f0min = Get minimum... start end Hertz Parabolic
			f0max = Get maximum... start end Hertz Parabolic
			f0min_time = Get time of minimum... start end Hertz Parabolic
			f0min_point = (f0min_time-start)/rhyme_dur
			f0max_time = Get time of maximum... start end Hertz Parabolic
			f0max_point = (f0max_time-start)/rhyme_dur
		else
			f0mean = Get mean: start, end, "Hertz"
			f0min = Get minimum... start end Hertz Parabolic
			f0max = Get maximum... start end Hertz Parabolic
			f0min_time = Get time of minimum... start end Hertz Parabolic
			f0min_point = (f0min_time-start)/rhyme_dur
			f0max_time = Get time of maximum... start end Hertz Parabolic
			f0max_point = (f0max_time-start)/rhyme_dur
		endif

 		select 'intensityID'
 		intmean = Get mean: start, end, "dB"
		intmin = Get minimum: start, end, "Parabolic"
		intmax = Get maximum: start, end, "Parabolic"

		# extract normalised f0
		f0s# = zero#(npoints)
		for x from 1 to npoints
			normtime = start + rhyme_dur*(x-1)/(npoints-1)
			select 'pitchID'
			f0s#[x] = Get value at time... normtime "Hertz" linear
		endfor

		appendFileLine: resultsfile$, interval, tab$, rhyme_lab$, tab$, character_lab$, tab$, syllable_lab$, tab$, rhyme_dur, tab$, character_dur, tab$, f0mean, tab$, f0min, tab$, f0max, tab$, f0min_point, tab$, f0max_point, tab$,
		... intmean, tab$, intmin, tab$, intmax, tab$, f0s#[1], tab$, f0s#[2], tab$, f0s#[3], tab$, f0s#[4], tab$, f0s#[5], tab$, f0s#[6], tab$, f0s#[7], tab$, f0s#[8], tab$, f0s#[9], tab$, f0s#[10]
		interval = interval + 1
	endif
endfor

select 'pitchID'
plus 'intensityID'
if pointprocess
	plus 'pitchtierID'
endif
Remove
