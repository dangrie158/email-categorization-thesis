# Introducing new classes to a classifier {#sec:new-classes}

The classifiers evaluated in the previous chapter perform better (have higher accuracy on the validation set) when trained with more data ([Figure @fig:class-performance]). When working with email data, however, it is expected that new classes can be introduced which have only little training data. This may happen because a new project requires a new folder in the inbox for all communication associated with it.

When enough data is available, a new derived word2vec model can be trained and used for classification alongside the previous model as described in the previous chapter. However, it is to be expected that training data is very rare for a newly introduced class. For this reason, this chapter will present a way to create additional training data based on very few real data points which can then be used to train a temporary classifier.

## Approach

The general idea is that language is very rich in a way that words can often be replaced without changing the meaning of the sentence. The words that can be substituted for each other are then synonymous. Furthermore, sometimes words can be replaced with other words that are not synonymous; however, the sentence is still about the same topic. For example, a document about soccer where each occurrence of the word soccer is replaced with baseball is still about the overall theme sports.

This connection between words is also reflected by the distributional hypothesis (@harris1954distributional) and therefore is learned by a word2vec model. In fact, word2vec learns word vectors that have a short distance (for cosine similarity) to words that are synonymous or thematically related. For example, in the model learned on the Wikipedia corpus, closest to the vector of the word ```president``` are the vectors for the words ```chairman```, ```chancellor``` and ```commissioner```, all representing a political role.

To leverage this property, the following method was tested to create additional training data with the same theme:

1. tokenize and stopword filter the documents
2. sort the tokens by their relevance
3. use a natural word2vec model to find synonyms / words with the same topic for the most relevant words (keywords)
4. create a new document by replacing every occurrence of the keyword with the words found in the last step
5. add the new document to the training set

## Practical Implementation {#sec:new-classes-practical}

As a natural corpus, the Wikipedia corpus and the news corpus without the articles from the test category were used, since this is all the data that is available in this scenario.

To sort the tokens by their relevance, the tf-idf of every token could be calculated. However, this would require a pass over the complete natural corpus to find the IDFs. Therefore, the total term frequency (ttf) over the corpus was used in place of the IDF since this information is already available in the word2vec model due to the construction of the Huffman tree for the hierarchical softmax optimization and the subsampling. The significance of a word is therefore calculated by (@tf-ittf) with $tf_d$ being the term frequency in the document and $ttf$ being the word frequency in the complete corpus.

(@tf-ittf) $$ tf\text{-}ittf(w,d)=\frac { { tf }_{ d }(w) }{ ttf(w) } $$

The ten most relevant tokens according to this measure were then used as keywords for the document. For each keyword, the two closest words according to the cosine similarity of the vectors in the word2vec model were used as a replacement for the keyword. For each similar word, a new document was then created by replacing each occurrence of the keyword with the similar word. This process therefore creates at most 20 new documents from a single document.

## Problems with synthetic Languages

The test was performed on the German Wikipedia and news corpus. German is a synthetic, fusional language, which often forms specific words using a composition of unspecific words. For example, the word ```orange juice``` is translated into German ```Orangensaft```. This synthetic property proved to be a problem for the algorithm described above since it depends on the keywords being present in the corpus to find similar words for it. However, often specific words that are a composition of multiple words were picked as keywords due to their low ttf. Therefore, the keyword often did not appear in the word2vec model, and thus, no new document could be created. To overcome this issue, the words need to be decomposed and split into their more general parts. For the word ```Orangensaft```, these parts are ```Orange``` and ```Saft```.

The algorithm used for splitting the words can be described by the following pseudocode:
\newpage

    split_word_into_partitions
    In: word, vocabulary
    out: [[partitions]]

    start = 0
    end = start + 1
    partitions = []

    forever:
      current_partition = []
      while end < len(word):
        if word[start:end] in vocabulary and not in partitions:
          current_partition.push(word[start:end])
          start = end
        end++

      if start != end:
        current_partition.push(word[start:end])

      if len(current_partition) > 0:
        partitions.push(current_part)
      else:
        end forever

This function returns a list of possible partitions of the word where each part, except for the last, is in the vocabulary of the base corpus. The last part is excluded from the presence requirement since it proved to be often a suffix rather than a word.

Each found partition is then scored and the partition with the highest score is chosen as the correct split. @koehn2003empirical suggest the geometric mean of the word occurrences of all parts as a score function. However, this method often yielded partitions with very short parts. For example, the word ```Orangensaft``` was split into the parts ```Orange```, ```nsa``` and ```ft```. Therefore, the product of part frequency and length was used for the weighting instead (@geom-mean-ttf-len) which proved to yield better results.

(@geom-mean-ttf-len) $$\underset { S }{ argmax } ({ \prod_{ { p }_{ i }\in S }^{  }{ count({ p }_{ i }) * len({ p }_{ i }) }  }^{ \frac { 1 }{ n }  })$$

To get similar words for the compound word from the found partition, the sum of the vectors of the parts is used to find close vectors in the embedding space. This summarized vector works for finding alike words because the word2vec model learns linear relations between words as demonstrated by @mikolov2013efficient.

[Table @tbl:keyword-synonymes] shows some examples of the output of this algorithm.

| Compound Word      | Found Partition      | Found Synonyms              |
|--------------------|----------------------|-----------------------------|
| grenzschutzbehörde | grenz-schutz-behörde | dienststelle, bundesbehörde |
| strafzölle         | straf-zölle          | importzölle, einfuhrzölle   |
| nachrichtenagentur | nachrichten-agentur  | zeitung, tageszeitung       |
| befestigungsanlage | befestigungs-anlage  | wallanlage, ummauerung      |
| konzeptstudien     | konzept-studien      | modelle, prototypen         |
Table: Examples of split compound words and their closest found replacements {#tbl:keyword-synonymes}

This decomposition algorithm is only applied when the keyword is not in the base model.

## Results

As a newly introduced category, the ```Sport``` category was chosen arbitrary. However, since the method will be evaluated against the same classifier and category without the additional documents, this choice is insignificant.

Since a multinomial Naive Bayes classifier performed best when trained with only 10 data points for each class (see [chapter @sec:classifier-result]), this classifier will be trained and evaluated on the created data.

Since the performance of a multinomial Naive Bayes classifier over a varying training set size was already evaluated in the previous chapter, the training data for all other classes is limited to 100 elements per class.

[Figure @fig:extended-performace] shows the performance difference between the classifier with and without the additionally created training data over a varying size of original training data. As one can see, the classifier that was trained on the original and created training data has up to 15% better accuracy on the data when trained with only 20 data points.

One can also see that when more data is available, the performance difference gets smaller and finally the extended classifier performs worse compared to the one trained only on the original data.

![Comparison of a multinomial Naive Bayes classifier when trained with and without created training data](source/figures/extended_performace.pdf "Extended classifier performance"){width=90% #fig:extended-performace}

## Using the Extended Data with other classifiers

In [chapter @sec:auto-classification], the maximization of the likelihood using word2vec models proved to be a classifier that is easily extendable with new classes and performs better than the multinomial Naive Bayes on larger training sets. Therefore, it is desirable to combine the benefits of the classifier with additional training data with the advantages of the likelihood maximization.

To achieve this goal, the Naive Bayes classifier can be trained for a binary classification problem so that it only predicts if a new document is part of the new class or not. This binary classification objective can be accomplished by sampling elements from the other categories randomly and assigning them all with a common label (e.g. ```negative```). This data is then used for training in conjunction with the extended training data of the real class to create a binary classifier.

If this classifier predicts the document to be of the ```negative``` class, the word2vec classifier can be used to predict the true label among all other categories. When enough training data is available, a new word2vec model on the data can be learned which is then used for classification. However, the point where enough training data is available that a word2vec model has higher accuracy than the binary classifier is not predictable, since no evaluation data for the class is available. The expected accuracy of the compound classifier in the product of accuracies for each classifier.

[Figure @fig:extended-performace-neg-sampling] shows the accuracy of a binary classifier with a varying number of training samples with and without the additionally generated training data when using 100 samples of each negative class. As one can see, the difference in accuracy between the classifiers is very close to [Figure @fig:extended-performace].

![Comparison of a multinomial Naive Bayes classifier for a binary classification problem when trained with and without created training data](source/figures/extended_performace_only_negative.pdf "Extended classifier performance with negative sampling"){width=90% #fig:extended-performace-neg-sampling}
