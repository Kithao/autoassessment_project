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
		# Set start of audio
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
	if len(_Phone.label) > 4: 
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

def writeTextHeader(_textFilename):
	"""
	This functin writes the header of the text file containing 
	the duration of the 25 sample points 
	"""
	header = ["'Filename'\t\t"]

	for i in range(1,26):
		header.append("'F0_" + str(i) + "'\t\t")

	header.append("\n")

	with open(_textFilename, 'w') as outfile:
		outfile.writelines(header)

def writeTextData(_textFilename, _textgridList):
	"""
	_textFilename: text file in which to write the data
	_textgridList: list of all the textgrid to process
	"""
	writeTextHeader(_textFilename)
	# durations = getDurationVec(_textgridList[0])
	# print(durations)
	# return durations	

	with open(_textFilename, 'a') as outfile:
		for filei in _textgridList:
			durations = getDurationVec(filei)
			lineToWrite = [filei[:-9]] + durations
			for element in lineToWrite:
				outfile.write(str(element) + "\t\t")
			outfile.write("\n")


def main():
	textfile = 'exampletext.txt'
	textgridlist = glob.glob('*.TextGrid')
	writeTextData(textfile,textgridlist)

if __name__ == '__main__':
	main()