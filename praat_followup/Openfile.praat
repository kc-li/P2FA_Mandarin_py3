# Specify name
# Female: S1, S3, S8, S12 (some are missing), S4
# Male: S2, S22, S28, S27, S29
name$ = "S1diaC5"

soundname$ = name$ + ".wav"
textgridname$ = name$ +".wav.TextGrid"
sounddir$ = "/Volumes/S8/Chengdu/chengdu_P2FA/individual_original_wav/"
textgriddir$ = "/Volumes/S8/Chengdu/chengdu_P2FA/results/"

soundid = Read from file: sounddir$ + soundname$
textgridid = Read from file: textgriddir$ + textgridname$

select 'soundid'
plus 'textgridid'
#View & Edit