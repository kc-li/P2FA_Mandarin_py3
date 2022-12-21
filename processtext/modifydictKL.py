#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sat Aug 13 21:02:39 2022

@author: kechun
"""
file = "model/dict_original"
f = open(file, "rt")
out = open("model/dict", "w")

text = f.readlines()
deletelist = ["得  d &","都  d u","还  h w @ n","差  C @ y"]
# Add new entries
out.write("啷  l a N\n")
out.write("喃  l e y\n")
out.write("噻  s e y\n")
out.write("映  y i N\n")
out.write("矬  c w >\n")
for line in text:
    # remove trailing space
    newline = line.strip()
    # Delet unwanted pronuncations
    if newline in deletelist:
        newline = ""
    if not newline: continue   
    # Replace certain characters 
    if newline == "的  d &":
        newline = "的  l e y"
    if newline == "热  r &":
        newline = "热  z E"
    # No retroflex zh ch sh
    newline = newline.replace(" S ", " s ")
    newline = newline.replace(" Z ", " z ")
    newline = newline.replace(" C ", " c ")
    # Make sure the names have the same transcription
    newline = newline.replace(" i n", " i N")
    newline = newline.replace(" @ n", " E")
    # r -> z
    newline = newline.replace(" r ", " z ")
   
    print(newline)
    out.write(newline + "\n")
