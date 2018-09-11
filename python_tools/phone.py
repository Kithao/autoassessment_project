#!/usr/bin/python
#
# Phone class definition

class Phone(object):
	"""
	Definition of a class Phone containing start/end times of the phone and its label
	The label corresponds to the ARPAbet symbol of the phone
	"""

	def __init__(self, _start, _end, _label):
		super(Phone, self).__init__()
		self.start = _start
		self.end = _end
		self.label = _label