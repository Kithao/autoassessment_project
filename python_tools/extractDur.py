#!/usr/bin/python
#
# 13 June 2018
# This script generates a text file with 25 sections of durations
# 
# If the segment is a vowel, extract its duration
# One utterance has 25 fields of each parameter (segment nature, duration)
#
# Author: TRUONG Quy Thao
#
#
# Note : Run this script in the directory where the TextGrid are located
#

from __future__ import with_statement

import os, glob

class Phone(object):
	"""
	Definition of a class Phone containing start/end times and a label
	"""

	def __init__(self, _start, _end, _label):
		super(Phone, self).__init__()
		self.start = _start
		self.end = _end
		self.label = _label


class Utterance(object):
	"""
	Definition of a class Utterance 
	"""
	def __init__(self, _phoneList):
		"""
		Only the nb of intervals and the phone list are known 
		"""
		super(Utterance, self).__init__()
		self.start = 0 
		self.end = 0
		self.nbIntervals = len(_phoneList)
		self.phoneList = _phoneList

	def setStartEnd(self):
		# Set start of audio (timestamp of first non silence phone)
		if (self.phoneList[0].label).find('SIL') != -1:
			self.start = self.phoneList[1].start
		else:
			self.start = self.phoneList[0].start

		# Set end of audio
		if (self.phoneList[-1].label).find('SIL') != -1:
			self.end = self.phoneList[-1].start
		else:
			self.end = self.phoneList[-1].end


def parseTextgrid(_textgridFilename):
	"""
	This function parses a textgrid and returns a Textgrid object
	containing the start, end, and phone list of each 
	"""

	phoneList = [] # List of phones found in the textGrid
	with open(_textgridFilename, 'r') as infile:
		lines = infile.readlines()
		#nbIntervals = lines[13][20:] # Number of intervals (sil and non sil)
		xmax = lines[4][7:] # end of audio

		# Store all the info on the phones in a list
		countLines = 0
		interval = 1
		for linei in lines:
			if linei.find('intervals [' + str(interval) + ']') != -1:
				label = lines[countLines+3][10:]
				if label.find('SIL') != -1:
					# Do nothing
					pass
				else:
					xminInterval = lines[countLines+1][10:]
					xmaxInterval = lines[countLines+2][10:]
					phoneList.append(Phone(xminInterval, xmaxInterval, label))
				interval = interval + 1	

			countLines = countLines + 1

	currentUtterance = Utterance(phoneList)
	currentUtterance.setStartEnd()

	return currentUtterance

def isVowel(_Phone):
	# Vowel (Attention: il y a un espace à la fin de chaque label)
	# Beware of 2-sized labels that are not vowels
	if len(_Phone.label) > 4 \
		and (_Phone.label.find('A') != -1 \
		or _Phone.label.find('E') != -1 \
		or _Phone.label.find('I') != -1 \
		or _Phone.label.find('O') != -1 \
		or _Phone.label.find('U') != -1): 
		return "1"
	# Insertion
	elif _Phone.label.find('A') != -1 \
		or _Phone.label.find('E') != -1 \
		or _Phone.label.find('I') != -1 \
		or _Phone.label.find('O') != -1 \
		or _Phone.label.find('U') != -1:
		return "-1"
	# Consonant
	else:
		return "0"

def getDurationVec(_textgridFilename):
	"""
	This function returns the list of 25 durations according to the
	phone nature of the current sample point (vowel, consonant, insertion)
	"""
	listOfNatures = [] # Size should be 25
	durations = [] # Size should be 25
	currentUtterance = parseTextgrid(_textgridFilename)
	# Time step
	timeStep = (float(currentUtterance.end) - float(currentUtterance.start))/26
	# print('Time step: ' + str(timeStep))
	currentPhoneList = currentUtterance.phoneList
	phoneIndex = 0
	for i in range(1,26):
		mid = (timeStep * i - timeStep * (i - 1))/2
		if (float(currentPhoneList[phoneIndex].end)-float(currentPhoneList[0].start) > (timeStep*(i-1) + mid)):
			listOfNatures.append(isVowel(currentPhoneList[phoneIndex]))
			if isVowel(currentPhoneList[phoneIndex]).find('0') != -1 or \
			isVowel(currentPhoneList[phoneIndex]).find('-1') != -1 or \
			phoneIndex == (len(currentPhoneList) -1):
				durations.append(0)
			else:
				dur = float(currentPhoneList[phoneIndex].end)-float(currentPhoneList[phoneIndex].start)
				durations.append(dur)

		else:
			phoneIndex += 1
			listOfNatures.append(isVowel(currentPhoneList[phoneIndex]))
			if isVowel(currentPhoneList[phoneIndex]).find('0') != -1 or\
			isVowel(currentPhoneList[phoneIndex]).find('-1') != -1 or\
			phoneIndex == (len(currentPhoneList) -1):
				durations.append(0)
			else:
				dur = float(currentPhoneList[phoneIndex].end)-float(currentPhoneList[phoneIndex].start)
				durations.append(dur)

	# return (listOfNatures,durations)
	return durations

def getNormDurationVec(_textgridFilename):
	"""
	This function normalises the durations over the duration of the whole utterance
	"""
	currentUtterance = parseTextgrid(_textgridFilename)
	uttDuration = float(currentUtterance.end) - float(currentUtterance.start)
	rawDur = getDurationVec(_textgridFilename)
	normDur = []
	
	for duri in rawDur:
		normDur.append(duri/uttDuration)

	return normDur

def writeTextHeader(_textFilename):
	"""
	This functin writes the header of the text file containing 
	the duration of the 25 sample points 
	"""
	header = ["'Filename'\t"]

	for i in range(1,26):
		header.append("'dur_" + str(i) + "'\t")

	header.append("\n")

	with open(_textFilename, 'w') as outfile:
		outfile.writelines(header)

def writeTextData(_textFilename, _textgridList):
# def writeTextData(_textFilename, _textgridList, _delete):
	"""
	_textFilename: text file in which to write the data
	_textgridList: list of all the textgrid to process
	"""
	writeTextHeader(_textFilename)

	with open(_textFilename, 'a') as outfile:
		for filei in _textgridList:
			durations = getDurationVec(filei)
			# lineToWrite = [filei[:-9]] + durations
			# Delete substring correponding to ROOT
			# index = 0
			# length = len(_delete)
			
			# while filei.find(_delete) != -1:
			# 	index = filei.find(_delete)
			# 	# filename = filei[0:index] + filei[index+length]
			# 	filei = filei[0:index] + filei[index+length]
			# 	print(filei)
			# # print(filei)
			lineToWrite = [filei[:-9]] + durations
			
			for element in lineToWrite:
				outfile.write(str(element) + "\t")
			outfile.write("\n")

def writeNormTextData(_textFilename, _textgridList):
	writeTextHeader(_textFilename)

	with open(_textFilename, 'a') as outfile:
		for filei in _textgridList:
			normDurations = getNormDurationVec(filei)
			lineToWrite = [filei[:-9]] + normDurations
			for element in lineToWrite:
				outfile.write(str(element) + '\t')
			outfile.write('\n')

def main():
	ROOT = "C:\\Users\\QuyThao\\Documents\\Prosody analysis\\Tests_ERJ_TIMIT\\ERJ\\Alignment\\mono_align_words_full\\"
	GRID_DIR = ROOT + "ERJ.TextGrid\\"
	RES_FILE = ROOT + 'Results\\dur_erj_sampled.txt'
	RES_FILE_NORM  = ROOT + 'Results\\durnorm_erj_sampled.txt'
	textgridlist = glob.glob(GRID_DIR + '*.TextGrid')
	# writeTextData(RES_FILE,textgridlist)
	writeNormTextData(RES_FILE_NORM, textgridlist)

if __name__ == '__main__':
	main()