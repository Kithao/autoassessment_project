#!/usr/bin/python
#
# Utterance class definition

import phone

class Utterance(object):
	"""
	Definition of a class Utterance 
	Note: Silent phones are labeld 'SIL'
	Utterance.start 	start of the first non-silent phone
	Utterance.end 		end of the last non-silent phone
	Utterance.nbIntervals 		number of non-silent phones
	Utterance.phoneList 		list of non-silent phones 	
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
		# Set start of audio (timestamp of first non-silent phone)
		if (self.phoneList[0].label).find('SIL') != -1:
			self.start = self.phoneList[1].start
		else:
			self.start = self.phoneList[0].start

		# Set end of audio (timestamp of the last non-silent phone)
		if (self.phoneList[-1].label).find('SIL') != -1:
			self.end = self.phoneList[-1].start
		else:
			self.end = self.phoneList[-1].end