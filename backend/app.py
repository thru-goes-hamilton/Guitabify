import os
from typing import Dict, List, Tuple, Union
from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from functions import transcribe

app = FastAPI()

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Set the directory to save uploaded audio files
UPLOAD_FOLDER = os.path.join(os.getcwd(), 'data', 'uploaded_audio')

# Ensure the upload folder exists
if not os.path.exists(UPLOAD_FOLDER):
    os.makedirs(UPLOAD_FOLDER)

# List all files in the UPLOAD_FOLDER
for filename in os.listdir(UPLOAD_FOLDER):
    if os.path.isfile(os.path.join(UPLOAD_FOLDER, filename)):
        print(filename)

# Delete all files in the UPLOAD_FOLDER
for filename in os.listdir(UPLOAD_FOLDER):
    file_path = os.path.join(UPLOAD_FOLDER, filename)
    # Check if it's a file and delete it
    if os.path.isfile(file_path):
        os.remove(file_path)
        print(f"Deleted file: {filename}")

@app.post("/upload")
async def upload_file(audio: UploadFile = File(...)) -> Dict[str, str]:
    print("Upload endpoint hit!")  # Debug print
    # List all files in the UPLOAD_FOLDER
    for filename in os.listdir(UPLOAD_FOLDER):
        if os.path.isfile(os.path.join(UPLOAD_FOLDER, filename)):
            print(filename)
        else:
            print(f"Directory: {filename}")
    

    # Delete all files in the UPLOAD_FOLDER
    for filename in os.listdir(UPLOAD_FOLDER):
        file_path = os.path.join(UPLOAD_FOLDER, filename)
        # Check if it's a file and delete it
        if os.path.isfile(file_path):
            os.remove(file_path)
            print(f"Deleted file: {filename}")

    if not audio:
        raise HTTPException(status_code=400, detail="No file provided")
    
    if audio.filename == '':
        raise HTTPException(status_code=400, detail="No selected file")
    
    # Save the file in the data/uploaded_audio directory
    audio_path = os.path.join(UPLOAD_FOLDER, audio.filename)
    
    try:
        contents = await audio.read()
        with open(audio_path, 'wb') as f:
            f.write(contents)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error saving file: {str(e)}")
    
    return {"message": f"File uploaded successfully to {audio_path}"}

@app.get("/notes")
async def get_notes(file_name: str) -> Dict[str, Union[List[str], List[int]]]:
    if not file_name:
        raise HTTPException(status_code=400, detail="No file name provided")
    
    audio_path = os.path.join(UPLOAD_FOLDER, file_name)
    if not os.path.exists(audio_path):
        raise HTTPException(status_code=404, detail="File not found")
    
    try:
        list1, list2 = transcribe(audio_path)
        print(list1)
        print(list2)
        return {"list1": list1, "list2": list2}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error processing file: {str(e)}")

@app.delete("/delete")
async def delete_file(file_name: str) -> Dict[str, str]:
    if not file_name:
        raise HTTPException(status_code=400, detail="No file name provided")
    
    file_path = os.path.join(UPLOAD_FOLDER, file_name)
    if not os.path.exists(file_path):
        raise HTTPException(status_code=404, detail="File not found")
    
    try:
        os.remove(file_path)  # Delete the file
        return {"message": f"File {file_name} deleted successfully"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error deleting file: {str(e)}")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=5000)