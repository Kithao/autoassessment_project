# January 23, 2017
# Modified by TQT

# This script is used to compute prosodic features (F0, intensity) at 25 equally spaced sampled points over an utterance
# The locations of the audio files, their corresponding TextGrid files and the resulting text files have to be specified
# The audio files and their corresponding TextGrid files have to be named accordingly 
# The results for F0 and intensity features are separated into 2 independent text files
# ATTENTION: This script has to be used for phone-labeled TextGrid files

form Get pitch intensity and duration from labeled segments in file
	comment Directory of sound files. Be sure to include the final "/"
	text sound_directory C:/Users/QuyThao/Documents/Prosody analysis/Tests_ERJ_TIMIT/ERJ/Native/All/
	sentence Sound_file_extension .wav
	comment Directory of TextGrid files. Be sure to include the final "/"
	text textGrid_directory C:/Users/QuyThao/Documents/Prosody analysis/Tests_ERJ_TIMIT/ERJ/Native/Alignment/mono_ali_native_newwords/TextGrid/
	sentence TextGrid_file_extension .TextGrid
	comment Full path of the resulting F0 text file:
	text resultsfile C:/Users/QuyThao/Documents/Prosody analysis/Tests_ERJ_TIMIT/ERJ/Native/Alignment/mono_ali_native_newwords/Results/F0_handseg_native.txt
	comment Full path of the resulting Intensity text file:
	text resultsfile_int C:/Users/QuyThao/Documents/Prosody analysis/Tests_ERJ_TIMIT/ERJ/Native/Alignment/mono_ali_native_newwords/Results/int_handseg_native.txt
	comment Which tier do you want to analyze?
	integer Tier 1
	comment Formant analysis parameters
	positive Time_step 0.01
	integer Maximum_number_of_formants 5
	positive Maximum_formant_(Hz) 5500
	positive Window_length_(s) 0.025
	real Preemphasis_from_(Hz) 50
	comment Pitch analysis parameters
	positive Pitch_time_step 0.01
	positive Minimum_pitch_(Hz) 75
	positive Maximum_pitch_(Hz) 300
endform

# This lists everything in the directory into what's called a Strings list
# and counts how many there are
Create Strings as file list... list 'sound_directory$'*'sound_file_extension$'
numberOfFiles = Get number of strings

# Checks whether the results file already exists. If so, delete it
if fileReadable (resultsfile$)
	pause The file 'resultsfile$' already exists! Do you want to overwrite it?
	filedelete 'resultsfile$'
endif

if fileReadable (resultsfile_int$)
	pause The file 'resultsfile_int$' already exists! Do you want to overwrite it?
	filedelete 'resultsfile_int$'
endif

# Creates a header in the pitch results file (25 values of F0)
header$ = "'Filename' 'tab$' 'F0_1' 'tab$' 'F0_2' 'tab$' 'F0_3' 'tab$' 'F0_4' 'tab$' 'F0_5' 'tab$'
	... 'F0_6' 'tab$' 'F0_7' 'tab$' 'F0_8' 'tab$' 'F0_9' 'tab$' 'F0_10' 'tab$' 'F0_11' 'tab$' 'F0_12' 'tab$' 'F0_13' 'tab$' 
	... 'F0_14' 'tab$' 'F0_15' 'tab$' 'F0_16' 'tab$' 'F0_17' 'tab$' 'F0_18' 'tab$' 'F0_19' 'tab$' 'F0_20' 'tab$' 'F0_21' 'tab$'
	... 'F0_22' 'tab$' 'F0_23' 'tab$' 'F0_24' 'tab$' 'F0_25' 'newline$'"
fileappend "'resultsfile$'" 'header$'

# Creates header in the intensity results file
header_int$ = "'Filename' 'tab$' 'int_1' 'tab$' 'int_2' 'tab$' 'int_3' 'tab$' 'int_4' 'tab$' 'int_5' 'tab$' 
	... 'int_6' 'tab$' 'int_7' 'tab$' 'int_8' 'tab$' 'int_9' 'tab$' 'int_10' 'tab$' 'int_11' 'tab$' 'int_12' 'tab$' 'int_13' 'tab$' 
	... 'int_14' 'tab$' 'int_15' 'tab$' 'int_16' 'tab$' 'int_17' 'tab$' 'int_18' 'tab$' 'int_19' 'tab$' 'int_20' 'tab$' 'int_21' 'tab$'
	... 'int_22' 'tab$' 'int_23' 'tab$' 'int_24' 'tab$' 'int_25' 'newline$'"
fileappend "'resultsfile_int$'" 'header_int$'

# Process each file in the specified directory
for ifile to numberOfFiles
	appendInfoLine: "Number of files found : 'numberOfFiles'"
	appendInfoLine: "Processing file number : 'ifile'"
	filename$ = Get string... ifile
	appendInfoLine: "Filename : 'filename$'"
	
	Read from file... 'sound_directory$''filename$'

	soundname$ = selected$ ("Sound",1)

	gridfile$ = "'textGrid_directory$''soundname$'.TextGrid"
	
	if fileReadable (gridfile$)
		Read from file... 'gridfile$'

		select Sound 'soundname$'
		To Pitch... pitch_time_step minimum_pitch maximum_pitch

		select Sound 'soundname$'
		To Intensity... minimum_pitch time_step

		select TextGrid 'soundname$'
		numberOfIntervals = Get number of intervals... tier

		# Check
		#appendInfoLine: "Nb of intervals 'numberOfIntervals'"

		# Get the duration of the spoken utterance
		for interval to numberOfIntervals
			label$ = Get label of interval... tier interval
			# Get start time of utterance
			if label$ == "SIL" and interval == 1
				start = Get end point... tier interval
			endif
			if label$ <> "SIL" and interval == 1
				start = Get starting point... tier interval
			endif
			# Get end time of utterance
			if label$ == "SIL" and interval == numberOfIntervals
				end = Get starting point... tier interval
			endif
			if label$ <> "SIL" and interval == numberOfIntervals
				end = Get end point... tier interval
			endif
		endfor

		# Check start and end times
		#appendInfoLine: "start of utterance: 'start' s, end of utterance: 'end' s"
		utt_dur = (end - start)

		# Define time step to sample 25 points
		sample_step = utt_dur / 24 

		nameline$ = "'soundname$' 'tab$'"
		fileappend "'resultsfile$'" 'nameline$'
		fileappend "'resultsfile_int$'" 'nameline$'

		# Pitch
		select Pitch 'soundname$'
		for ipitch to 25
			pitch_time = ( (ipitch - 1) * sample_step ) + start
			f0 = Get value at time... pitch_time Hertz Linear
			pitchline$ = "'f0:1' 'tab$'"
			fileappend "'resultsfile$'" 'pitchline$'
		endfor
		fileappend "'resultsfile$'" 'newline$'

		# Intensity
		select Intensity 'soundname$'
		for iintensity to 25
			intensity_time =  ( (iintensity - 1) * sample_step ) + start
			intensity = Get value at time... intensity_time Cubic
			intensityline$ = "'intensity:1' 'tab$'"
			fileappend "'resultsfile_int$'" 'intensityline$'
		endfor
		fileappend "'resultsfile_int$'" 'newline$'

	endif
	select TextGrid 'soundname$'
	plus Pitch 'soundname$'
	plus Intensity 'soundname$'
	plus Sound 'soundname$'
	Remove
	select Strings list
	
endfor

Remove
				 
				
