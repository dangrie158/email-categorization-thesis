# Related Work

## Tools

scipy
Gensim
Keras

mention von sasha can's paper

## Word2Vec

Word2vec is a method to build a Vector Space Model (VSM) in which words can be represented (embedded) which was introduced by [@mikolov2013efficient].
Classical NLP models often use simple bag of words (BOW) approaches to handle words, where each word is treated as a single, atomic symbol. The words then are represented as a numeric ids (e.g. ```car: 350``` and ```truck: 543```) or a single-hot vector. A single-hot vector is a binary sparse vector with the same dimensionality as the length of the vocabulary with only one (single) non-zero (hot) element. These simple BOW approaches however, do not allow the representation of similarities between words (e.g. the word ```car``` and ```truck``` are both motorized transportation devices with 4 or more wheels). Therefore an algorithm using one of these representations cannot take advantage from this knowledge unless it learns them as part of the training, which requires more training data.

Word2vec however tries to embed each word in the vocabulary in a vector space with, compared to the dimensionality of single-hot encodings, very low dimensionality (typically between 100 - 1000). It uses the *distributional hypothesis* which states that words which occur in the same context tend to share a similar meaning [@harris1954distributional]. The algorithm therefore tries to learn dense vectors that have a high (cosine-) similarity for words that cooccure often and a low similarity for words that do not occur in the same context.

Word2Vec uses a *predictive method* that tries to directly predict a word using it's context as an input. Another approach is to use a *count based* model like Latent Semantic Indexing (LSI) that tries to learn the correlation between words by counting the cooccurence and then transform this information into a low-dimensional vector space using Single Value Decomposition (SVD) [@dumais1988using]. However, both, predictive and count based methods can be learned unsupervised on unlabeled training data because the only input is the context of the current word. This allows to use any text corpus in any language where the distributional hypothesis holds true. To train a word2vec model with good vector representations\footnote{good vector representation of words will have a small distance for words with a similar meaning and big distances for words with different meanings}, a big corpus is needed. This is due to the fact that the distributional hypothesis is a statistical model which profits from a big corpus where words occur in their context more than once.

### Learning of the Word Embeddings

Word2Vec uses one of two approaches to learn good vector representations, Skip-Gram or Continuous Bag of Words (CBOW). 


- wordembeddings to learn beziehungen zwischen wörtern


## SVD
used many times (successfully) in NLP categorization tasks (ref to chap. 5 with results (SVD TF-IDF second best))

## Latent Ditrichlet Allocation
