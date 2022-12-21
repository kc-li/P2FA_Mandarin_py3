#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Jul  3 14:33:43 2022

@author: kechun
"""

import pandas as pd
df = pd.read_excel("长沙话标注221204.xlsx", sheet_name = "record")
df["text"] = df['annotation'].str.replace('[^\w\s]','')
df.text = df.text.str.join(" ")
df["tokenid"]=df['Speaker']+ df['file']+ df['sentence'] + ".wav"
output = df[['tokenid', 'text']]
output.to_csv("list.txt", sep = " ", header = False, index = False)
