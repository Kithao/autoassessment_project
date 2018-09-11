#!/usr/bin/python
#
# utils.py

from __future__ import with_statement

import os
import glob

from phone import Phone
from utterance import Utterance

def parseTextgrid(_textgridFilename):
	"""
	This function parses a textgrid file and returns an instance of the correponding Utterance
	Input
		_textgridFilename 	filename of the textgrid to parse
	Output
		currentUtterance 	instance of class Utterance 
	"""
	phoneList = [] # List of phones found in the textGrid
	with open(_textgridFilename, 'r') as infile:
		lines = infile.readlines()
		xmaxLine = 4 # Line where xmax is read in the texgrid file
		xmaxStart = 7 # Where to start reading time 
		xmax = lines[xmaxLine][xmaxStart:] # end of audio

		# Store all the info on the phones in a list
		countLines = 0
		interval = 1
		for linei in lines:
			if linei.find('intervals [' + str(interval) + ']') != -1:
				# label = lines[countLines+3][10:]
				lblLine = 3 # nb of lines after 'intervals [.]', where the text label is specified
				lblStart = 19 # where to start reading the label
							   # 19 if tabs are converted into spaces, 10 otherwise
				label = lines[countLines+lblLine][lblStart:]
				if label.find('SIL') != -1:
					# Do nothing
					pass
				else:
					lblStartLine = 1 	# nb of lines after 'intervals [.]'
									 	# where the start time of the phone is specified
					lblEndLine = 2 	# nb of lines after 'intervals [.]'
								   	# where the end time of the phone is specified
					timeStart = 19 	# where to start reading the timestamp
							   		# 19 if tabs are converted into spaces, 10 otherwise
					xminInterval = lines[countLines+lblStartLine][timeStart:]
					xmaxInterval = lines[countLines+lblEndLine][timeStart:]
					phoneList.append(phone.Phone(xminInterval, xmaxInterval, label))
				interval = interval + 1	

			countLines = countLines + 1

	currentUtterance = utterance.Utterance(phoneList)
	currentUtterance.setStartEnd()

	return currentUtterance

def isVowel(_Phone):
	"""
	This function returns an integer depending on the nature of the phone
	Input
		_Phone 		instance of the class Phone
	Output
		integer 	1 if it is a vowel
				   -1 		   a vowel insertion
				    0 		   a consonant
	"""
	# Vowel
	# Beware of 2-sized labels that are not vowels ("JH","CH"...)
	vowelLength = 5 # Vowel = 2 letters (including A,E,I,O,U) + "" + space
	if len(_Phone.label) > vowelLength \
		and (_Phone.label.find('A') != -1 \
		or _Phone.label.find('E') != -1 \
		or _Phone.label.find('I') != -1 \
		or _Phone.label.find('O') != -1 \
		or _Phone.label.find('U') != -1): 
		return "1"
	# Insertion (1-letter vowel)
	elif _Phone.label.find('A') != -1 \
		or _Phone.label.find('E') != -1 \
		or _Phone.label.find('I') != -1 \
		or _Phone.label.find('O') != -1 \
		or _Phone.label.find('U') != -1:
		return "-1"
	# Consonant
	else:
		return "0"