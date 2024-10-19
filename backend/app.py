import os
import random
from flask import Flask, request, jsonify
from flask_cors import CORS
from functions import transcribe

app = Flask(__name__)
CORS(app)

# Set the directory to save uploaded audio files
UPLOAD_FOLDER = os.path.join(os.getcwd(), 'data', 'uploaded_audio')

# Ensure the upload folder exists
if not os.path.exists(UPLOAD_FOLDER):
    os.makedirs(UPLOAD_FOLDER)

@app.route('/upload', methods=['POST'])
def upload_file():
    print("Upload endpoint hit!")  # Debug print

    if 'audio' not in request.files:
        return "No file part", 400
    
    audio = request.files['audio']
    if audio.filename == '':
        return "No selected file", 400
    
    # Save the file in the data/uploaded_audio directory
    audio_path = os.path.join(UPLOAD_FOLDER, audio.filename)
    audio.save(audio_path)
    
    return f'File uploaded successfully to {audio_path}', 200

# Endpoint to generate random notes
@app.route('/notes', methods=['GET'])
def get_notes():
    file_name = request.args.get('file_name')
    if file_name:
        audio_path = os.path.join(UPLOAD_FOLDER, file_name)
        if os.path.exists(audio_path):
            list1, list2 = transcribe(audio_path)
            return jsonify({'list1': list1, 'list2': list2})
        else:
            return jsonify({'error': 'File not found'}), 404
    else:
        return jsonify({'error': 'No file name provided'}), 400

# Endpoint to delete an uploaded file
@app.route('/delete', methods=['DELETE'])
def delete_file():
    file_name = request.args.get('file_name')
    if file_name:
        file_path = os.path.join(UPLOAD_FOLDER, file_name)
        if os.path.exists(file_path):
            os.remove(file_path)  # Delete the file
            return jsonify({'message': f'File {file_name} deleted successfully'}), 200
        else:
            return jsonify({'error': 'File not found'}), 404
    else:
        return jsonify({'error': 'No file name provided'}), 400

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')