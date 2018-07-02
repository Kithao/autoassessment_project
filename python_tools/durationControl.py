#!/usr/bin/python
#
# 2 July 2018
# This script generates a text file with the information
# concerning the ratio between each syllable nuclei
# 
# Author: TRUONG Quy Thao
#
#

from __future__ import with_statement

import os, glob
import extractDur

NAT_TO_ERJ = {
	'_01' : ['W5_189','W1_181'], '_02' : ['W5_190','W1_182'], '_03' : ['W5_191','W1_183'], '_04' : ['W5_192','W1_184'],
	'_05' : ['W2_181','W1_185'], '_06' : ['W2_182','W1_186'], '_07' : ['W2_183','W1_187'], '_08' : ['W2_184','W1_188'],
	'_09' : ['W3_181','W2_185'], '_10' : ['W3_182','W2_186'], '_11' : ['W3_183','W2_187'], '_12' : ['W3_184','W2_188'],
	'_13' : ['W3_185','W4_181'], '_14' : ['W3_186','W4_182'], '_15' : ['W3_187','W4_183'], '_16' : ['W3_188','W4_184'],
	'_17' : ['W4_185','W5_185'], '_18' : ['W4_186','W5_186'], '_19' : ['W4_187','W5_187'], '_20' : ['W4_188','W5_188'],
	'_21' : ['W5_197','W1_189'], '_22' : ['W5_198','W1_190'], '_23' : ['W1_191','W5_199'], '_24' : ['W2_189','W1_192'],
	'_25' : ['W1_193','W2_190'], '_26' : ['W2_191','W1_194'], '_27' : ['W3_189','W2_192'], '_28' : ['W3_190','W2_193'],
	'_29' : ['W3_191','W2_194'], '_30' : ['W4_189','W3_192'], '_31' : ['W4_190','W3_193'], '_32' : ['W4_191','W3_194'],
	'_33' : ['W4_192','W5_193'], '_34' : ['W4_193','W5_194'], '_35' : ['W4_194','W5_195'], '_36' : ['W5_196','W4_195']
	}

def extractVowelDur(_textgridFilename):
	currUtterance = extractDur.parseTextgrid(_textgridFilename)
	currPhoneList = currUtterance.phoneList
	vowelDur = []
	for phonei in currPhoneList:
		if extractDur.isVowel(phonei).find('-1') != -1 or \
		extractDur.isVowel(phonei).find('0') != -1 or \
		phonei.end == currUtterance.end:
			pass
		else:
			dur = float(phonei.end) - float(phonei.start)
			vowelDur.append(dur)
	return vowelDur

def ratioOrder(_nbOfWords, _path):
	"""
	This function returns a dictionary of the size of _nbOfWords
	{ 'word_id1' : [x x], 'word_id2' : [x x]} where the key value represents the
	order in which to calculate the vowel ratio for each word
	Note: filenames have to be indexed by numerical value
	The order is decided depending on the mean value of the ratio for all the native spks
	"""
	def getNbVowels(_utt):
		i = 0
		for phone in _utt.phoneList:
			if extractDur.isVowel(phone).find('-1') != -1 or \
			extractDur.isVowel(phone).find('0') != -1 or \
			phone.end == _utt.end:
				pass
			else:
				i = i + 1
				# print(phone.label)
		return i

	wordToOrder = {}
	for i in range(1,_nbOfWords+1):
		if i < 10:
			word_id = '_0' + str(i)
		else:
			word_id = '_' + str(i)
		# print('First word id: ' + word_id)
		fileList = glob.glob(_path + '*' + word_id + '*.TextGrid')
		# print('First file: ' + fileList[0])
		orderVec = [] # Order with which to calculate the ratios
		# Determine the number of pairs in the word
		nbPairs = getNbVowels(extractDur.parseTextgrid(fileList[0])) - 1
		# print('Nb of pairs : ' + str(nbPairs))
		nbSpks = len(fileList)
		# print('Nb of spks : ' + str(nbSpks))
		# Matrix of ratios for all speakers
		allSpkRatios = [[0 for x in range(nbPairs)] for y in range(nbSpks)] 
		# Extract ratios for all speakers
		# phone(i+1)/phone(i)
		for spk in range(nbSpks):
			vowelDur = extractVowelDur(fileList[spk])
			# print('Word '  + word_id + ' Dur ' + str(vowelDur))
			for k in range(nbPairs):
				ratio = vowelDur[k+1]/vowelDur[k]
				allSpkRatios[spk][k] = ratio
		# print(allSpkRatios)

		# Compute mean ratio of all speakers for each pair
		for pair in range(nbPairs):
			mean = 0;
			for spk in range(nbSpks):
				mean = mean + allSpkRatios[spk][pair]
			mean = mean / nbSpks
			if mean > 1:
				orderVec.append(1)
			else:
				orderVec.append(0)

		# print(orderVec)

		wordToOrder[word_id] = orderVec

	return wordToOrder	

def convertNatToL2(_wordToOrder,_natToL2):
	"""
	Converts the keys of wordToOrder dictionary to the word ids of L2 utterances
	"""
	converted = {}
	for key in _natToL2:
		for i in range(len(_natToL2[key])):
			converted[_natToL2[key][i]] = _wordToOrder[key]

	return converted

def computePairRatio(_textgridFilename,_orderVec):
	"""
	Computes the ratio between consecutive vowels according to the order vec
	"""
	pairRatio = []
	vowelDur = extractVowelDur(_textgridFilename)
	for i in range(len(_orderVec)):
		if _orderVec[i]:
			ratio = vowelDur[i+1]/vowelDur[i]
		else:
			ratio = vowelDur[i]/vowelDur[i+1]
		pairRatio.append(ratio)
	return pairRatio

def writeRatioText(_textFilename, _textgridList,_orderVec):
	"""
	This function writes ratio info for each file into a text file
	"""
	with open(_textFilename, 'a') as outfile:
		for filei in _textgridList:
			ratios = computePairRatio(filei,_orderVec)
			lineToWrite = [filei[:-9]] + ratios # Don't write extension

			for element in lineToWrite:
				outfile.write(str(element) + '\t')
			outfile.write('\n')

def main():
	# Verify the dictionaries
	ROOT = 'C:\\Users\\QuyThao\\Documents\\Prosody analysis\\Tests_ERJ_TIMIT\\ERJ\\'
	GRID_DIR_NAT = ROOT + 'Native\\Alignment\\mono_ali_native_newwords\\TextGrid\\'
	RES_FILE_NAT = ROOT + 'Native\\Alignment\\mono_ali_native_newwords\\Results\\durationcontrol_native.txt'
	GRID_DIR_ERJ = ROOT + 'Alignment\\mono_align_words_full\\ERJ.TextGrid\\'
	RES_FILE_ERJ = ROOT + 'Alignment\\mono_align_words_full\\Results\\durationcontrol_erj.txt'
	# textgridList = glob.glob(GRID_DIR + '*.TextGrid')

	wordToOrder = ratioOrder(36,GRID_DIR_NAT)
	wordToOrder_L2 = convertNatToL2(wordToOrder,NAT_TO_ERJ)

	# Native
	for key in wordToOrder:
		textgridList = glob.glob(GRID_DIR_NAT + '*' + key + '*.TextGrid')
		writeRatioText(RES_FILE_NAT,textgridList,wordToOrder[key])

	# Non native
	for key in wordToOrder_L2:
		textgridList = glob.glob(GRID_DIR_ERJ + '*' + key + '*.TextGrid')
		writeRatioText(RES_FILE_ERJ,textgridList,wordToOrder_L2[key])

if __name__ == '__main__':
	main()