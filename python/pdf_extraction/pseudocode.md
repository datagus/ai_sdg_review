# Pseudocode for PDF Processing and Text Extraction

This pseudocode outlines the steps in the script to load PDF files from a folder, extract text using a PDF partitioner, process the text with NLTK (tokenization, POS tagging, Named Entity Recognition, and lemmatization), and then save the final cleaned text into separate text files.

---

## 1. Import and Setup

- **Import Libraries:**
  - File handling (`os`)
  - Data serialization (`pickle`)
  - PDF partitioning (`partition_pdf`)
  - JSON formatting (`elements_to_json`)
  - Progress tracking (`tqdm`)
  - Natural Language Processing (NLP) with `nltk`
  
- **Download NLTK Data Resources:**
  - 'punkt' for tokenization
  - 'averaged_perceptron_tagger' for POS tagging
  - 'stopwords' for common words removal
  - 'maxent_ne_chunker' for named entity recognition
  - 'words' for English words list
  - 'wordnet' for lemmatization

---

## 2. Load PDF Files

- **Define the Folder:**
  - Set the folder path for PDFs (e.g., `"your_folder_with_pdfs"`).

- **Initialize Two Lists:**
  - `pdfs`: to store the full file paths of PDFs.
  - `names`: to store the file names (without the `.pdf` extension).

- **For Each File in the Folder:**
  - If the file name **does not** start with '.' (skip hidden files) **and** ends with '.pdf':
    - Append the file name (minus the extension) to `names`.
    - Get the full file path and add it to `pdfs`.

---

## 3. Partition PDFs into Documents

- **Initialize an Empty List:**
  - `documents`: to store the output from partitioning each PDF.

- **For Each PDF in `pdfs`:**
  - If the file does not have incorrect naming or extension:
    - Try to run the PDF partitioning function with the file path.
    - If partitioning works:
      - Append the resulting elements to `documents`.
    - If partitioning fails:
      - Print an error message indicating the PDF could not be processed.
      - Skip the file.

---

## 4. Extract Narrative Text Elements

- **Initialize an Empty List:**
  - `text_elements`: to store text extracted from each document.

- **For Each Document in `documents`:**
  - Create an empty list called `paragraphs`.
  - **For Each Element in the Document:**
    - If the element's category is `'NarrativeText'`:
      - Append the element’s text to `paragraphs`.
  - Add `paragraphs` to `text_elements`.

---

## 5. Tokenize and POS-Tag Text

- **Initialize an Empty List:**
  - `token_elements`: to store tokens with their parts-of-speech tags.

- **For Each Collection of Paragraphs in `text_elements`:**
  - For each paragraph:
    - **Tokenize** the paragraph into words.
    - **POS-tag** the tokens.
    - Save the list of (word, tag) pairs.
  - Append the list of tagged tokens for each paragraph to `token_elements`.

---

## 6. Filter, Lemmatize, and Extract Relevant Tokens (Nouns)

- **Load and Update Stopwords:**
  - Load English stopwords from NLTK.
  - Update the stopword list with extra words such as: `'et'`, `'al'`, `'etc'`, `'ie'`, `'ISSN'`, `'http'`, `'https'`.

- **Prepare a Set of Valid Words:**
  - Generate a set of valid words using all lemma names from WordNet synsets.

- **Set Up for Named Entity Recognition (NER):**
  - Create an empty set `named_entities` to store any recognized named entities.
  - Initialize a lemmatizer.

- **Initialize an Empty List:**
  - `transformed_documents` to hold the filtered tokens for each document.

- **For Each Tokenized Paragraph in `token_elements`:**
  - Initialize a list `filtered_paragraphs` for storing tokens from each paragraph.
  - **For Each Tagged Sentence (list of tokens with POS tags):**
    - Use a Named Entity Recognition method:
      - If a token group is recognized as an entity, update the `named_entities` set.
    - **For Each Token and Its Tag:**
      - Convert the word to lowercase and lemmatize it.
      - Check that:
        - The word contains only alphabet letters.
        - The word length is greater than 2 characters.
        - The word is tagged as a noun (e.g., `'NN'`).
        - The word is not in the stopwords list.
        - The word is not in the recognized named entities.
        - The word exists in the valid words set.
      - If all conditions are met, add the word to the list of filtered tokens.
    - Append the filtered tokens for the sentence to `filtered_paragraphs`.
  - Append `filtered_paragraphs` to `transformed_documents`.

---

## 7. Create Clean Text Strings

- **Initialize an Empty List:**
  - `text_files`: to store the final text for each PDF.

- **For Each Transformed Document in `transformed_documents`:**
  - Initialize an empty string or list for concatenating sentences.
  - **For Each List of Filtered Tokens in the Document:**
    - Join the tokens with spaces to form a sentence.
  - Join all sentences to create a complete text.
  - Replace any double spaces with single spaces.
  - Append the complete text to `text_files`.

---

## 8. Write Text Files to Disk

- **Define Output Folder:**
  - Set a folder path for saving text files (e.g., `"your_folder_with_text_files"`).

- **For Each Text in `text_files`:**
  - Use the corresponding name from `names` to create a file name.
  - Open or create a text file with UTF-8 encoding.
  - Write the text string into the file.
  
---

**End of Pseudocode**