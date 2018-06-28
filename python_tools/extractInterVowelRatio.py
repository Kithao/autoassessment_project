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

import os, glob
import extractDur


def getInterVowelRatio(_textgridFilename):
	"""
	This function extracts the ratio between each pair of vowel
	read from the textGrid file given in input
	"""
	vowelRatio = []
	vowelDur = []
	currUtterance = extractDur.parseTextgrid(_textgridFilename)
	currPhoneList = currUtterance.phoneList
	for phonei in currPhoneList:
		if extractDur.isVowel(phonei).find('-1') != -1 or \
		extractDur.isVowel(phonei).find('0') != -1 or \
		phonei.end == currUtterance.end:
			# print('Pass - nature of phone : ' + extractDur.isVowel(phonei))
			# print('Phone : ' + phonei.label)
			# print('Phone length : ' + str(len(phonei.label)))
			pass
		else:
			# print('Not pass - nature of phone : ' + extractDur.isVowel(phonei))
			# print('Phone : ' + phonei.label)			
			# print('Phone length : ' + str(len(phonei.label)))
			dur = float(phonei.end) - float(phonei.start)
			vowelDur.append(dur)

	for i in range(len(vowelDur)-1):
		for j in range(i+1,len(vowelDur)):
			ratio = vowelDur[j]/vowelDur[i]
			vowelRatio.append(ratio)

	return vowelRatio

def writeRatioText(_textFilename, _textgridList):
	"""
	This function writes ratio info for each file into a text file
	"""
	with open(_textFilename, 'w') as outfile:
		for filei in _textgridList:
			ratios = getInterVowelRatio(filei)
			lineToWrite = [filei[:-9]] + ratios # Don't write extension

			for element in lineToWrite:
				outfile.write(str(element) + '\t')
			outfile.write('\n')

def main():
	ROOT = 'C:\\Users\\QuyThao\\Documents\\Prosody analysis\\Tests_ERJ_TIMIT\\ERJ\\'
	GRID_DIR = ROOT + 'Alignment\\mono_align_words_full\\ERJ.TextGrid\\'
	RES_FILE_RATIO = ROOT + 'Alignment\\mono_align_words_full\\Results\\vowelratio_handseg_erj.txt'
	# RES_FILE_RATIO = 'test_print.txt'
	textgridlist = glob.glob(GRID_DIR + '*.TextGrid')
	# textgridlist = glob.glob('*.TextGrid')

	writeRatioText(RES_FILE_RATIO,textgridlist)

if __name__ == '__main__':
	main()