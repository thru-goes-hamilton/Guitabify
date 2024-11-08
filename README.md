# Guitabify: A Guitar Trancription application

Guitabify aims to convert guitar audio to tabs(notes) using AI. It is aimed to be user-friendly application for guitarist to upload audio files or record audio while playing and get the notes that they have played in the form of tabs.
<br><br>**Do you want to know the guitar notes for some guitar audio or song? Just upload its audio in Guitabify!** [Visit Guitabify]([https://bruno-v2.web.app/](https://guitabify.web.app/))<br><br>
<p>
  <img src="[https://github.com/user-attachments/assets/1c6a9b6d-ebaa-4a8c-b7e4-c8bcef27002a](https://github.com/user-attachments/assets/a9e2322e-5252-4c91-ae1f-77b16fc9d806)" width="850" height="500" /> 
</p>
<br>

As of now 3 attempts have been tried for the underlying algorithm for transcribing music.
1. Training a note classifier using ANN with custom recorded dataset(created a dataset from scratch).
2. CNN based model architecture trained on Kaggle dataset.
3. Pretrained model called Basic Pitch for audio-to-midi(a file format to represent what note is played and when it is played).<br>

These appraoches were ideated after going through literature in the topics of AMT(Automatic Music Transcription), monophonic and polyphonic music transcription.
Currently the guitabify application used the Basic Pitch model for prediction.

## Features
- Memory of the current chat, can maintain context through a chat.
- Handles memory uniquely for each session for multiple user simultaneously.
- Contextual chunking to improve to give retrieved chunks more context of their document.
- Ensemble Retrieval to retrieve based on key word match and vector search.
- Streaming result for smooth experience.

## What can Bruno do?
- Upload `.pdf`,`.txt`,`.doc` or `.docx` file and ask any questions about it.
- Delete and upload new file in between the chat whenever required
- Chat with it even without any file being uploaded

## Contextual Retrieval RAG
A variant of Retrieval Augmented Generation that focuses on adding more context to the chunks and improving retrieval with ensemble methods.<br>A jupyter notebook file of how to implement Contextual Retrieval RAG is in `backend`\ `ContextualRetrievalRAGexample.ipynb`. It uses `langchain` and `langgraph` to implement with memory(session state) and streaming.<br><br>
1. Improving retrieval by performing an ensemble of BM25 and Vector retrieval

   <img src="https://github.com/user-attachments/assets/bffd6e1d-b502-4415-af97-e54918eb2494" width="750" height="375" /><br>
    - Break down the knowledge base (the "corpus" of documents) into smaller chunks of text, usually no more than a few hundred tokens
    - Create TF-IDF encodings and semantic embeddings for these chunks
    - Use BM25 to find top chunks based on exact matches
    - Use embeddings to find top chunks based on semantic similarity
    - Combine and deduplicate results from (3) and (4) using rank fusion techniques
    - Add the top-K chunks to the prompt to generate the response
2. Modifying chunks to have context of the document they belong to
   
   <img src="https://github.com/user-attachments/assets/3f4dd94b-7d9e-4b60-8fcb-e6b610335da3" width="750" height="375" /><br>
   - Pass each chunk along with the entire document to an LLM to add context to the chunk
   - Use the prompt
     ```python
     prompt = '''
     <document> 
      {{WHOLE_DOCUMENT}} 
     </document> 
      Here is the chunk we want to situate within the whole document 
      <chunk> 
      {{CHUNK_CONTENT}} 
      </chunk> 
      Please give a short succinct context to situate this chunk within the overall document for the purposes of improving search retrieval of the chunk. Answer only with the succinct context and nothing else. 
     '''
     ```
   - Use the new chunks for TF-IDF encoding and embeddings<br>

<img src="https://github.com/user-attachments/assets/f7b4bfed-8dd2-4195-8962-a9abe2010ddd" width="750" height="375" /><br>


## Working of Contextual Retrieval RAG in Bruno
- ### Upon file upload
    - #### Parsing text from PDF
      Uses `PyPDFLoader` from `langchain` to extract text from each page of a provided PDF file, combining it into a single string.
    - #### Splitting the text into chunks
      Uses `RecursiveCharacterTextSplitter` to split into chunks
    - #### Adding context to chunks
      Run inference on llm for each chunk, by asking it to modify the chunk to contain context with respect to entire document. This step is skipped if document is too big.
    - #### Creating TF-IDF encodings
      Created TF-IDF encodings implicitly while initialising BM25 retriever with new chunks.
    - #### Creating vector embeddings
      Created vector embedding for the new chunks using embeddings model from `sentence-transformer` in HuggingFace.
    - #### Store vector embeddings in Pinecone
      Stores vector embeddings in Pinecone vector database and intialises vector retriever for it.
    - #### Define ensemble retriever
      Creates and ensemble retriever with BM25 retriever and Pinecone vector retriever, implicity perform Rerank and deduplication.
- ### Inference from RAG pipeline
    - #### History based prompt modification
      Modifies prompt based on previous chat message to have their context.
    - #### Retrieving chunks using similarity and key word search
      Uses the new prompt to perform similarity search on vector database and retrieve most relevant chunk. Likewise, use the prompt to retrieve with BM25 retriever to get results.
    - #### Rerank and deduplicate
      Ensemble retriever implicitly handles Rerank all the retrieved chunks and removing duplicates
    - #### LLM prompting after augmentation
      Llama 3 8b is prompted with the new history based prompt and context from pdf(most relevant modified chunk).
    - #### Streaming result and storing to chat history
      The resulting answer is streamed and the original prompt and the answer are appended to temporary chat history
<br>

## Specifications used
1. LLM: Llama3-8b
2. LLM Hosting: Groq
3. Parser: PyPDFLoader from LangChain
4. Chunking: Contextual chunking
5. Embedding model: sentence-transformers/all-mpnet-base-v2 from HuggingFace
6. Retriever: Ensemble retriever (BM25 Retriever, vectordb retriever), implicit reranking
7. Vector database: Pinecone

## Application
- Frontend: Flutter
- Backend: FastAPI
- Frontend deployment: Firebase hosting
- Backend deployment: as Docker image in Render

## Upcoming features in Bruno 3.0
- Handling image and tabular data from PDFs
- Support multiple file upload
- Include authentication and store chats in database
- Resolve memory related bugs when chatting without PDF
- Include web search in it
