# This script read files in the folder and call other script to do things
# By Katrina Li 2022.09.04

# Trail dir
#textgriddir$ = "/Users/kechun/GitHub/P2FA_Mandarin_py3/praat_followup/try"
#sounddir$ = "/Users/kechun/GitHub/P2FA_Mandarin_py3/praat_followup/try"

# Full dir
textgriddir$ = "/Volumes/S8/Chengdu/chengdu_P2FA/results"
sounddir$ = "/Volumes/S8/Chengdu/chengdu_P2FA/individual_original_wav"

#f0settign will be passed to script2: 1 = Male, 2 = Female (3 = Custom, but parameter needs to be modified in script 2)
f0setting$ = "Custom"

script1$ = "1 Onset_rime_boudaries.praat"
script2$ = "2 segment-syllable-sentence.praat"

textgridstrings = Create Strings as file list: "list", textgriddir$ + "/*.TextGrid"
if textgridstrings
  numberOfFiles = Get number of strings
  n = 0
  writeInfoLine: "There are ", numberOfFiles, " Files."
  for ifile to numberOfFiles
    n = n+1
    selectObject: textgridstrings
    textgridName$ = Get string: ifile
    soundName$ = textgridName$ - ".TextGrid"
    textgridID = Read from file: textgriddir$ + "/" + textgridName$
    soundID = Read from file: sounddir$ + "/" + soundName$
    appendInfoLine: textgridName$, "+", soundName$

    select 'textgridID'
    # Run script to modify textgrid
    runScript: script1$
	plus 'soundID'
    runScript: script2$, f0setting$
  endfor
endif
