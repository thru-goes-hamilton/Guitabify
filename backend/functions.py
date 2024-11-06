import numpy as np
import os
import librosa
import librosa.display
import matplotlib.pyplot as plt
import soundfile as sf
from scipy.signal import butter, filtfilt
from basic_pitch.inference import predict
from basic_pitch import ICASSP_2022_MODEL_PATH

def butter_bandpass(lowcut, highcut, fs, order=5):
    nyq = 0.5 * fs
    low = lowcut / nyq
    high = highcut / nyq
    b, a = butter(order, [low, high], btype='band')
    return b, a

def apply_bandpass_filter(data, lowcut, highcut, fs, order=5):
    b, a = butter_bandpass(lowcut, highcut, fs, order=order)
    y = filtfilt(b, a, data)
    return y

def midi_pitch_to_guitar_tab(pitch):
    # Standard guitar tuning (from low to high)
    guitar_tuning = [40, 45, 50, 55, 59, 64]  # E2, A2, D3, G3, B3, E4


    best_string = 0
    best_fret = float('inf')

    for string, open_pitch in enumerate(guitar_tuning):
        if pitch >= open_pitch:
            fret = pitch - open_pitch
            if fret < best_fret:
                best_string = string
                best_fret = fret

    return 6-best_string, best_fret

def analyze_midi_guitar(midi_data):
    notes = midi_data.instruments[0].notes
    sorted_notes = sorted(notes, key=lambda x: x.start)

    string_names = ['E', 'A', 'D', 'G', 'B', 'e']

    tab_data = []
    for note in sorted_notes:
        string, fret = midi_pitch_to_guitar_tab(note.pitch)
        if string != 1:  # Skip notes on the highest string (e)
            new_note = ({
                'pitch': note.pitch,
                'string': string,
                'fret': fret,
                'string_name': string_names[6-string],
                'start': note.start,
                'end': note.end,
                'duration': note.end - note.start,
                'velocity': note.velocity
            })

            # Check if this note can be merged with the previous one
            if tab_data and tab_data[-1]['pitch'] == new_note['pitch'] and \
               tab_data[-1]['string'] == new_note['string'] and \
               tab_data[-1]['fret'] == new_note['fret'] and \
               abs(tab_data[-1]['end'] - new_note['start']) < 0.1:  # Adjust this threshold as needed
                # Merge with previous note
                tab_data[-1]['end'] = new_note['end']
                tab_data[-1]['duration'] = tab_data[-1]['end'] - tab_data[-1]['start']
                tab_data[-1]['velocity'] = max(tab_data[-1]['velocity'], new_note['velocity'])
            else:
                # Add as a new note
                tab_data.append(new_note)

    return tab_data

def transcribe(file_path):

    # Load the audio file
    y, sr = librosa.load(file_path)

    # Apply bandpass filter
    lowcut = 80  # Hz
    highcut = 5000  # Hz
    y_filtered = apply_bandpass_filter(y, lowcut, highcut, sr)

    filtered_file_name = 'temp-filtered.wav' 

    sf.write(filtered_file_name, y_filtered, sr)

    _, midi_data, _ = predict(filtered_file_name)

    os.remove(filtered_file_name)

    # Assuming midi_data is your MIDI data object
    tab_result = analyze_midi_guitar(midi_data)

    list1 = []
    for note in tab_result:
        note = f"{note['string']}{note['fret']}"
        list1.append(note)
    
    print(f"No. of notes detected: {len(list1)}")

    list2 = ["1" for _ in range(len(list1) - 1)]
    return list1, list2
