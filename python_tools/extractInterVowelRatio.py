#!/usr/bin/python
#
# 28 June 2018
# This script generates a text file with the information
# concerning the ratio between each syllable nuclei
# 
# Author: TRUONG Quy Thao
#
#

from __future__ import with_statement

import os 
import glob

import utils
from utterance import Utterance
from phone import Phone

def getInterVowelRatio(_textgridFilename):
	"""
	This function extracts the ratio between each pair of vowel
	read from the textGrid file given in input
	"""
	vowelRatio = []
	vowelDur = []
	currUtterance = utils.parseTextgrid(_textgridFilename)
	currPhoneList = currUtterance.phoneList
	for phonei in currPhoneList:
		if utils.isVowel(phonei).find('-1') != -1 or \
		utils.isVowel(phonei).find('0') != -1 or \
		phonei.end == currUtterance.end:
			pass
		else:
			dur = float(phonei.end) - float(phonei.start)
			vowelDur.append(dur)

	for i in range(len(vowelDur)-1):
		for j in range(i+1,len(vowelDur)):
			ratio = vowelDur[j]/vowelDur[i]
			vowelRatio.append(ratio)

	return vowelRatio

def getConsecutiveVowelRatio(_textgridFilename):
	"""
	This function extracts the ratio between each consecutive pair of vowel
	read from the textGrid file given in input
	"""
	vowelRatio = []
	vowelDur = []
	currUtterance = utils.parseTextgrid(_textgridFilename)
	currPhoneList = currUtterance.phoneList
	for phonei in currPhoneList:
		if utils.isVowel(phonei).find('-1') != -1 or \
		utils.isVowel(phonei).find('0') != -1 or \
		phonei.end == currUtterance.end:
			pass
		else:
			dur = float(phonei.end) - float(phonei.start)
			vowelDur.append(dur)

	for i in range(len(vowelDur)-1):
		ratio = vowelDur[i+1]/vowelDur[i]
		vowelRatio.append(ratio)

	return vowelRatio

def writeRatioText(_textFilename, _textgridList):
	"""
	This function writes ratio info for each file into a text file
	"""
	with open(_textFilename, 'w') as outfile:
		for filei in _textgridList:
			# ratios = getInterVowelRatio(filei)
			ratios = getConsecutiveVowelRatio(filei)
			lineToWrite = [filei[:-9]] + ratios # Don't write extension

			for element in lineToWrite:
				outfile.write(str(element) + '\t')
			outfile.write('\n')

def main():
	ROOT = 'C:\\Users\\QuyThao\\Documents\\Prosody analysis\\Tests_ERJ_TIMIT\\ERJ\\'
	GRID_DIR = ROOT + 'Native\\Alignment\\mono_ali_native_newwords\\TextGrid\\'
	RES_FILE_RATIO = ROOT + 'Native\\Alignment\\mono_ali_native_newwords\\Results\\vowelratio_handseg_native.txt'
	RES_FILE_RATIO_CONS = ROOT + 'Native\\Alignment\\mono_ali_native_newwords\\Results\\vowelratioconsecutive_handseg_native.txt'
	# RES_FILE_RATIO = 'test_print.txt'
	textgridlist = glob.glob(GRID_DIR + '*.TextGrid')
	# textgridlist = glob.glob('*.TextGrid')

	# writeRatioText(RES_FILE_RATIO,textgridlist)
	writeRatioText(RES_FILE_RATIO_CONS,textgridlist)

if __name__ == '__main__':
	main()