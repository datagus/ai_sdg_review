#Importing the necessary libraries

import os
import pickle
from unstructured.partition.pdf import partition_pdf
from unstructured.staging.base import elements_to_json
from tqdm.notebook import tqdm
import nltk
from nltk.tokenize import word_tokenize
from nltk.corpus import stopwords, words, wordnet
from nltk.stem import WordNetLemmatizer
from nltk import pos_tag
nltk.download('punkt')
nltk.download('averaged_perceptron_tagger')
nltk.download('stopwords')
nltk.download('maxent_ne_chunker')
nltk.download('words')
nltk.download('words')
nltk.download('wordnet')


#Importing pdfs into python
folder = "your_folder_with_pdfs"
pdfs = []
names = []
for filename in tqdm(os.listdir(folder), desc="Processing..."):
    if filename.startswith('.') == False and filename.endswith('.pdf') == True:
        names.append(filename[:-4])
        file_path = os.path.join(folder, filename)
        pdfs.append(file_path)
    else:
        pass

#Partitioning all pdfs
documents = []
for pdf in tqdm(pdfs, desc="Partitioning pdfs:"):
    if pdf.startswith(f'{folder}.') == False and pdf.endswith('.pdf') == True:
        try: 
            elements = partition_pdf(
                filename=pdf,                  # mandatory
                strategy="auto"                 
                )
            documents.append(elements)
        except:
            print(f"{pdf} could not be partitioned")
            pass
    else:
        pass

#extracting the text elements
text_elements = []
for document in documents:
    paragraphs = []
    for i in range(0,len(document)):
        if document[i].category == 'NarrativeText':
            paragraphs.append(document[i].text)
        else:
            pass
    text_elements.append(paragraphs)


#Using NLTK
#Tokenizing and pos tagging text elements
token_elements = []
for text_element in tqdm(text_elements, desc="Pos_tagging text elements"):
    tagged_tokens = []
    for element in text_element:
        token = word_tokenize(element)
        tagged_tokens.append(pos_tag(token))
        
    token_elements.append(tagged_tokens)

#Filtering tokens only for nouns
# Load stopwords
stop_words = set(stopwords.words('english'))

# Additional stopwords
additional_stopwords = {'et', 'al', 'etc', 'ie', 'ISSN', 'http', 'https'}
stop_words.update(additional_stopwords)

#valid_words = set(words.words())
valid_words = set(lemma.name() for synset in wordnet.all_synsets() for lemma in synset.lemmas())

named_entities = set()

#lemmatizing
lemmatizer = WordNetLemmatizer()

transformed_documents = []

for token_element in tqdm(token_elements, desc="filtering tokens..."):
    # Filtered paragraphs
    filtered_paragraphs = []

    # Named Entity Recognition (NER)

    for tagged_token in token_element:
        filtered_tokens = []
        for chunk in nltk.ne_chunk(tagged_token):
            if hasattr(chunk, 'label'):
                named_entities.update(c[0] for c in chunk)
        
        for word, tag in tagged_token:
            word = lemmatizer.lemmatize(word.lower())
            if (word.isalpha() and len(word) > 2 and 
                tag in ('NN') and 
                word.lower() not in stop_words and 
                word not in named_entities and 
                word.lower() in valid_words):
                filtered_tokens.append(word)
                
        filtered_paragraphs.append(filtered_tokens)
        
    transformed_documents.append(filtered_paragraphs)

#creating the text objects
text_files = []
for transformed_document in transformed_documents:
    outputs = []
    for document in transformed_document:
        outputs.append(" ".join(document))
        text = " ".join(outputs)
        text = text.replace("  ", " ")
    text_files.append(text)

#creating the text files
folder_txt = "your_folder_with_text_files"
for i in range(len(text_files)):
    #file_name = f'leuphana_text/{i+1:04}.txt'
    with open(f"{folder_txt}{names[i]}.txt", 'w', encoding='utf-8') as file:
    # Write the string to the file
        file.write(text_files[i])
