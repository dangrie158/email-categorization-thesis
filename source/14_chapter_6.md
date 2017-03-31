# Introducing new classes to a classifier

The classifiers evaluated in the previous chapter perform better (have higher accuracy on the validation set) when trained with more data ([Figure @fig:class-performance]). When working with email data however, it is expected that new classes can be introduced which have very little training data. This may happen because a new project requires a new folder in the inbox for all communication associated with it.

When enough data is available, a new derived word2vec model can be trained and used for classification alongside the previous model as described in the previous chapter. However, it is to be expected that training data is very rare for a newly introduced class. For this reason this chapter will present a way to create additional training data based on very few real data points which can then be used to train a temporary classifier.

## Approach

The general idea is that language is very rich in a way that often words can be replaced without changing the meaning of the sentence. The words that can be replaced with each other are then synonymous. Furthermore, sometimes words can be replaced with other words that are not synonymous, however the sentence is still about the same topic. For example a document about soccer where each occurrence of the word soccer is replaced with baseball is still about the general topic sports.

This connection between words is also reflected by the ditributional hypothesis (@harris1954distributional) and therefore is learned by a word2vec model. In fact, word2vec learns word vectors that have a short distance (for cosine similarity) to words that are synonymous or thematically related. For example, in the model learned on the wikipedia corpus, closest to the vector of the word ```president``` are the vectors for the words ```chairman```, ```chancellor```and ```commissioner```, all representing a political topic.

To leverage this property, the following method was tested to create additional training data with the same topic:

1. tokenize and stopword flter the documents
2. sort the tokens by their relevance
3. use a natural word2vec model to find synonymes / words with the same topic for the most relevant words (keywords)
4. create a new document by replacing every occurrence of the keyword with the synonym
5. add the new document to the training set

## Practical Implementation

As a natural corpus, the wikipedia corpus and the news corpus without the documents from the test category was used, since this is all the data that would be available in this scenario.

To sort the tokens by their relevance, the TF-IDF of every token could be calculated. However, this would require a pass over the complete natural corpus to find the IDFs. Therefore the total term frequency (TTF) over the corpus was used in place of the IDF, since this information is already available in the word2vec model due to the construction of the huffman tree for the hierarchical softmax optimization and the subsampling. The significance of a word is therefore calculated by (@tf-ittf) with $tf_d$ being the term frequency in the document and $ttf$ being the word frequency in the complete corpus.

(@tf-ittf) $$ tf-ittf(w,d)=\frac { { tf }_{ d }(w) }{ ttf(w) } $$

The 10 most relevant tokens according to this measure were then used as keywords for the document. For each keyword, the 2 closest words according to the cosine similarity of the vectors in the word2vec model were used as a synonym. For each synonym, a new document was then created by replacing each occurrence of the keyword with the synonym. This process therefore creates at most 20 new documents from a single document.

## Problems with synthetic Languages

The test was performed on the german wikipedia and news corpus. German is a synthetic, fusional language, that often forms specific words using a composition of unspecific words.For example the word ```orange juice``` is translated into german ```Orangensaft```. This synthetic property proved to be a problem for the algorithm described above, since it depends on the keywords being present in the corpus to find synonyms for it. However, often specific words that are a composition of multiple words were picked as keywords due to their low TTF. Therefore, often the keyword did not appear in the word2vec model and thus, no new document could be created.

To overcome this issue, the words need to be decomposed and split into their more general parts. For the word ```Orangensaft``` these parts are ```Orange``` and ```Saft```.

The algorithm used for splitting the words can be described by the following pseudocode:

    split_word_into_partitions
    In: word, vocabulary
    out: [[partitions]]

    start = 0
    end = start + 1
    partitions = []

    forever:
      current_partition = []
      while end < len(word):
        if word[start:end] in vocabulary and not in parts:
          current_partition.push(word[start:end])
          start = end
        end++

      if start != end:
        current_partition.push(word[start:end])

      if len(current_partition) > 0:
        partitions.push(current_part)
      else:
        end forever

This function returns a list of possible partitions of the word where each part, except for the last, is in the vocabulary of the base corpus. The last part is excluded from the presence requirement, since it is proved to often be a suffix rather than a word.

Each found partition is then scored and the partition with the highest score is chosen as the correct split. @koehn2003empirical suggest the geometric mean of the word occurrences of all parts as a score function, however this often yielded partitions with very short parts. For example the word ```Orangensaft``` was split into the parts ```Orange```, ```nsa``` and ```ft```. Therefore, the product of part frequency and length was used for the weighting instead (@geom-mean-ttf-len) which proved to yield better results.

(@geom-mean-ttf-len) $$\underset { S }{ argmax } ({ \prod_{ { p }_{ i }\in S }^{  }{ count({ p }_{ i }) * len({ p }_{ i }) }  }^{ \frac { 1 }{ n }  })$$

To get synonyms for the compound word from the found partition, the sum of the vectors for the parts is used to find close vectors in the embedding space. This works because the word2vec model learn linear relations between words as demonstrated by @mikolov2013efficient.

[Table @tbl:keyword-synonymes] shows some examples of the output of this algorithm.

| Compound Word      | Found Partition      | Found Synonyms              |
|--------------------|----------------------|-----------------------------|
| grenzschutzbehörde | grenz-schutz-behörde | dienststelle, bundesbehörde |
| strafzölle         | straf-zölle          | importzölle, einfuhrzölle   |
| nachrichtenagentur | nachrichten-agentur  | zeitung, tageszeitung       |
| befestigungsanlage | befestigungs-anlage  | wallanlage, ummauerung      |
| konzeptstudien     | konzept-studien      | modelle, prototypen         |
Table: Examples of split compound words and their closest found synonymes {#tbl:keyword-synonymes}

This decomposition algorithm is only applied when the keyword is not in the base model.

## Results

As a newly introduced category, the ```Sport``` category was arbitrary chosen. However, since the method will be evaluated against the same classifier and category without the additional documents, this choice is insignificant.

Since a multinomial naive Bayes classifier performed best when trained with only 10 data points for each class (see [Chapter @sec:classifier-result]), this classifier will be trained and evaluated on the created data.

Since the performance of a multinomial naive Bayes classifier over a varying training set size was already evaluated in the previous chapter, the training data for all other classes is limited to 100 elements per class.

[Figure @fig:extended-performace] shows the performance difference between the classifier with and without the additionally created training data over a varying size of original training data. As one can see, the classifier that was trained on the original and created training data has up to 15% better accuracy on the data when trained with only 20 data points.

One can also see that when more data is available, the performance difference gets smaller and finally the extended classifier performs worse compared to the one trained only on the original data.

![Comparison of a multinomial naive Bayes classifier when trained with and without created training data](source/figures/extended_performace.pdf "Extended classifier performance"){width=100% #fig:extended-performace}

## Using the extended Data with other classifiers

In [chapter @sec:auto-classification], the maximization of the likelihood using word2vec models proved to be a classifier that is easily extendable with new classes and performs better than the multinomial naive Bayes on larger training sets. Therefore, it is desirable to combine the benefits of the classifier with additional training data with the benefits of the likelihood maximization.

To achieve this goal, the naive Bayes classifier can be trained for a binary classification problem so that it only predicts if a new document is part of the new class or not. This can be accomplished by sampling elements from the other classes randomly and assigning them all with a common label (e.g. ```negative```). This data is then used for training in conjunction with the extended training data of the real class to create a binary classifier.

If this classifier predicts the document to be of the ```negative``` class, the word2vec classifier can be used to predict the true label among all other classes.

When enough training data is available, a new word2vec model on the data can be learned which is the used for classification. However, the point where enough training data is available that a word2vec model has higher accuracy than the binary classifier is not predictable, since no evaluation data for the class is available.

The expected accuracy of the compound classifier in the product of accuracies for each classifier.

[Figure @fig:extended-performace-neg-sampling] shows the accuracy of a binary classifier with a varying number of training samples with and without the additionally generated training data when using 100 samples of each negative class. As one can see, the difference in accuracy between the classifiers is very close to [figure extended-performace].

![Comparison of a multinomial naive Bayes classifier for a binary classification problem when trained with and without created training data](source/figures/extended_performace_only_negative.pdf "Extended classifier performance with negative sampling"){width=100% #fig:extended-performace-neg-sampling}
