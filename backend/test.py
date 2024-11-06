import librosa
from pydub import AudioSegment

def transcribe(audio_path):
# Load the audio file
    # audio = AudioSegment.from_file(audio_path)

    # # Convert to a format compatible with librosa
    # audio.export("temp.wav", format="wav")

    # Now load with librosa
    return librosa.load(audio_path)


if __name__=='__main__':
    y ,sr= transcribe(r'data\uploaded_audio\c-chord.wav')
    print(y[0])