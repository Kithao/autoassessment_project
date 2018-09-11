#!/usr/bin/python
#
# 13 June 2018
# This script generates a text file with 25 durations features (25 sampled points)
# The extracted durations correspond to the duration of the phone at the i-th sampled point 
# Each TextGrid file is parsed and vowel durations are extracted
# 
# Author: TRUONG Quy Thao
#
#

from __future__ import with_statement

import os
import glob

import utils
from phone import Phone
from utterance import Utterance


def getDurationVec(_textgridFilename):
	"""
	This function returns the list of 25 durations according to the
	phone nature of the current sample point (vowel, consonant, insertion)
	Input
		_textgridFilename 	filename of the textgrid file to parse
	Output
		durations 			list of 25 durations 
	"""
	listOfNatures = [] # Size should be 25
	durations = [] # Size should be 25
	currentUtterance = utils.parseTextgrid(_textgridFilename)
	# Time step
	nbPoints = 25
	timeStep = (float(currentUtterance.end) - float(currentUtterance.start))/nbPoints
	currentPhoneList = currentUtterance.phoneList
	phoneIndex = 0
	for i in range(1,nbPoints+1):
		mid = (timeStep * i - timeStep * (i - 1))/2
		if (float(currentPhoneList[phoneIndex].end)-float(currentPhoneList[0].start) > (timeStep*(i-1) + mid)):
			listOfNatures.append(utils.isVowel(currentPhoneList[phoneIndex]))
			if utils.isVowel(currentPhoneList[phoneIndex]).find('0') != -1 or \
			utils.isVowel(currentPhoneList[phoneIndex]).find('-1') != -1 or \
			phoneIndex == (len(currentPhoneList) -1):
				durations.append(0)
			else:
				dur = float(currentPhoneList[phoneIndex].end)-float(currentPhoneList[phoneIndex].start)
				durations.append(dur)
		else:
			phoneIndex += 1
			listOfNatures.append(utils.isVowel(currentPhoneList[phoneIndex]))
			if utils.isVowel(currentPhoneList[phoneIndex]).find('0') != -1 or\
			utils.isVowel(currentPhoneList[phoneIndex]).find('-1') != -1 or\
			phoneIndex == (len(currentPhoneList) -1):
				durations.append(0)
			else:
				dur = float(currentPhoneList[phoneIndex].end)-float(currentPhoneList[phoneIndex].start)
				durations.append(dur)
	return durations

def getNormDurationVec(_textgridFilename):
	"""
	This function normalises the phones durations over the duration of the whole utterance
	Input:
		_textgridFilename 	filename of the textgrid file to parse
	Output
		normDur 			list of 25 normalised durations
	"""
	# print(_textgridFilename)
	currentUtterance = utils.parseTextgrid(_textgridFilename)
	uttDuration = float(currentUtterance.end) - float(currentUtterance.start)
	rawDur = getDurationVec(_textgridFilename)
	normDur = []
	
	for duri in rawDur:
		normDur.append(duri/uttDuration)

	return normDur


def writeTextHeader(_textFilename):
	"""
	This function writes the header of the text file containing 
	the duration of the 25 sampled points 
	Input
		_textFilename 	filename of the desired text file
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
	This function writes textgrid file data into text files
	Input
		_textFilename 	 text file in which to write the data
		_textgridList 	 list of all the textgrid to process
	"""
	writeTextHeader(_textFilename)

	with open(_textFilename, 'a') as outfile:
		for filei in _textgridList:
			durations = getDurationVec(filei)
			lineToWrite = [filei[:-9]] + durations
			
			for element in lineToWrite:
				outfile.write(str(element) + "\t")
			outfile.write("\n")

def writeNormTextData(_textFilename, _textgridList):
	"""
	This function writes normalised durations into text files
	Input
		_textFilename 	text file in which to write the data
		_textgridList 	list of textgrid files to process
	"""
	writeTextHeader(_textFilename)

	with open(_textFilename, 'a') as outfile:
		for filei in _textgridList:
			normDurations = getNormDurationVec(filei)
			lineToWrite = [filei[:-9]] + normDurations
			for element in lineToWrite:
				outfile.write(str(element) + '\t')
			outfile.write('\n')

def main():
	ROOT = "C:\\Users\\QuyThao\\Documents\\Prosody analysis\\Tests_ERJ_TIMIT\\ERJ\\"
	GRID_DIR = ROOT + "Alignment\\mono_align_words_full\\ERJ.TextGrid\\"
	RES_FILE = ROOT + 'Alignment\\mono_align_words_full\\Results\\dur_handseg_910.txt'
	RES_FILE_NORM  = ROOT + 'Alignment\\mono_align_words_full\\Results\\durnorm_handseg_910.txt'
	textgridlist = glob.glob(GRID_DIR + '*.TextGrid')
	# RES_FILE_NORM = 'test_print.txt'
	# textgridlist = glob.glob('*.TextGrid')

	# writeTextData(RES_FILE,textgridlist)
	writeNormTextData(RES_FILE_NORM, textgridlist)

if __name__ == '__main__':
	main()