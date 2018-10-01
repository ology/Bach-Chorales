# This program was run to create the BWV-keys.txt file.

import os
import music21 as mu

def get_files(path):
    file_list = []

    for fn in os.listdir(path):
        name = path + '/' + fn
    
        if name.endswith('.mid'):
            file_list.append(name)
    
    return file_list

files = get_files('/Users/gene/sandbox/dev/Music/Bach-Chorales/public/chorales')

for f in files:
    song = mu.converter.parse(f)
    key = song.analyze('key').tonicPitchNameWithCase
    print(f + ' ' + key)
