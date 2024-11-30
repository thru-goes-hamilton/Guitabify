# Guitabify: A Guitar Transcription application

Guitabify is a user-friendly application that aims to convert guitar audio to tabs(notes) using AI. Guitarists can record a guitar audio or upload recorded audio and get the tabs of the notes.
<br><br>**Do you want to know the guitar notes for some guitar audio or song? Just upload its audio in Guitabify!** [Visit Guitabify](https://guitabify.web.app/)<br><br>
<p>
  <img src="https://github.com/user-attachments/assets/a9e2322e-5252-4c91-ae1f-77b16fc9d806" width="1000" height="500" /> 
</p>
<br>
<p>
  <img src="https://github.com/user-attachments/assets/4a4083d7-ea50-404d-b10f-c01354f985fd" width="500" height="250" /> 
  <img src="https://github.com/user-attachments/assets/ddc47059-0bad-43cb-9a98-1d47ef76f8bc" width="500" height="250" /> 
</p>

As of now, 3 approaches have been tried for the underlying algorithm for transcribing music.
1. Training a note classifier using ANN with custom recorded dataset(created a dataset from scratch).
2. CNN based model architecture trained on Kaggle dataset.
3. Pretrained model called Basic Pitch for audio-to-midi(midi is a file format to represent what note is played and when it is played).<br>

These approaches were ideated after going through literature in the topics of AMT(Automatic Music Transcription), monophonic and polyphonic music transcription. Automatic Music Transcription is still a challenging research problem that is yet to be solved because of complex nature of music audio. It varies based on the environment it is recorded. Many notes sound very similar and have very slight difference that it takes years of practice to identify.

Currently the guitabify application used the Basic Pitch approach for prediction as this approach gave the best result.
<br><br>
## Features
- Record guitar audio by playing.
- Upload pre-recorded guitar audio
- Display tabs from recorded or uploaded audio.
- Can handle only monophonic transcriptions. 

Note: Saving audios and tabs, and authentication is yet to be included in the application.
<br><br>
## How to use Guitabify?

- Upload .wav or .mp3 audio file or record a live audio by playing guitar and click the corresponding Upload button
- Click on Transcribe button and wait for tabs
- If you want to record again, click on Record button
<br><br>

## Approach 1: Note Classifier with custom recorded dataset
Example notebook at `backend`/`transcription_model_attempt1.ipynb`.<br>
Dataset can be found at `backend`/`dataset`/`Custom Recorded - Notes(single,0-4)`<br>
Trained a note classificaton model using custom recorder dataset for all possible single notes(monophonic notes) in the fret broard from fret 1 to 4. Predict the notes for an audio by performing onset detection to split it into chunks and then classify the notes. The time gap between the detected notes is binned to whole numbers(seconds) to capture temporal information.
### Training
- Onset detection is performed on each datapoint in the collected dataset and the audio is chunked to ensure silent audio parts are removed.
- The chunks are padded or trimmed to required shape.
- Mel-Frequency Cepstral Coefficients (MFCCs) are calculated for each chunk and fed to the model.
- A neural network with 5 Dense layers and Leaky Relu activation is trained to predict the class (Note: due to small dataset, train dataset is used for both train and val, however for testing a completely new audio is used).
### Prediction
- Onset detection is performed(detecting when a note is played) on an audio file to split it into chunks. Time gap between onset is binned based on ratio into integers.
- Chunks are padded with 0 or trimmed, then Mel-Frequency Cepstral Coefficients (MFCCs) are calculated for each chunk and fed to the model.
- Model predicts notes for each set of MFCC.
- Predicted class is decoded from the model output and shown for each note.
- Result is two list one for notes and another for the ratio of timegap between the notes being played.
### Conclusion
The result were very close to the expected notes when testing on completely new monophonic(single note) data that is within the range of 0-4 frets. However, the dataset needed to be expanded and more extensive testing caused the model to break.
### Future improvements
An approach to use frequency-domain information directly with a CNN could lead to better results as information might be lost while performing MFCC. Increasing dataset could improve the results.
<br><br>

## Approach 2: Custom CNN model trained on Kaggle dataset
Example notebook at `backend`/`transcription_model_attempt2.ipynb`<br>
Dataset can be found at `backend`/`dataset`/`Kaggle Dataset`<br>
Trained a note classifier with CNN architecture using an acoustic guitar dataset and perform inference on audio file with trained model.
### Training
- Audio is converted from time-domain to frequency-domain using mel_spectogram.
- The mel_spectorgram values are normalized.
- The normalized mel_spectogram values are passed through 4 convolutional blocks, a flatten layer followed by fully connected network of 2 layers.
### Prediction
- Audio is converted from time-domain to frequency-domain using mel_spectogram.
- Onset detection is performed using frequency domain data and split into chunks of data.
- Each chunk is either cropped or padded with 0s until they are of the required input size of the model.
- Inference on model.
- Predicted class is decoded from the model output and shown for each note.
### Conclusion
The results predicted were overall better compared to the previous approach, all the notes were in and around the neigbourhood on the correct note. Both model complexity and dataset needed to be improved to better the result.
### Future improvements
One approach forward could be to improve the dataset and scale up the network to see if performance improves. Another alternative is to reimplementing a different architecture (basic pitch) that can handle onset and note detection with one network with high quality personalised dataset.

## Approach 3: Basic Pitch
Basic Pitch is a open-source, pretrained model with a CNN based architecture to predict midi file from an audio. It was created by Spotify's Audio Intelligence Lab. It predicts 3 outputs, note, onset and pitch.
<br>
### Architecture
![image](https://github.com/user-attachments/assets/8c3d6371-c41b-4006-9618-0047df3d5775)
<br>
### Working
- Convert audio to time-frequency representation with frequency bins based on harmonics. This is achieved using constant harmonic Q transform.
- Feed the information to:
  - Convolution 2D layer with 16 filters of 5x5, followed by Batch Normalisation and Relu.
  - Conv2D layer with 18 filters of 3x39 again followed by Batch Norm and ReLu.
  - Conv2D layer with 1 filter of 5x5 followed by sigmoid.
  This predicts a **pitch posteriorgram**(a matrix where rows correspond to different classes and columns to time).
- The pitch posteriorgram is fed to:
  - Conv2D layer with 32 filters of 7x7 with a stride of 1x3(meaning slides 3 steps when sliding horizontally) followed by ReLu.
  - Conv2D layer with 1 filter of 7x3 followed by sigmoid.
  This predicts a **note posteriorgram**.
- The information from constant harmonic Q transform is meanwhile also fed to:
  - Conv2D layer with 32 filters of 5x5 with a stride of 1x3, followed by Batch Normalisation and ReLu.
  - The above result and note posteriorgram are combined using a Concatenation layer.
  - Conv2D layer with 1 filter of 3x3 followed by sigmoid.
  This predicts the **onset posteriorgram**.
<br><br>
## Application
- Frontend: Flutter
- Backend: FastAPI
- Frontend deployment: Firebase hosting
- Backend deployment: as Docker image in Render
<br><br>
## Upcoming features in Guitabify
- Including authentication
- Saving audio files and tabs
- Imporve algorithm by
  - creating bigger custom dataset
  - train with basic pitch model architecture on custom dataset(currently under preparation)
<br><br>
If you are interesting in contributing to the dataset collection process and join me on the journey to make Guitabify better, feel free to contact me at kamalu211211@gmail.com.
