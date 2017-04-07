# Evaluation using Emails

To test the assumption that news articles are a valid replacement for emails as stated in [chapter @sec:newscorpus], this chapter will evaluate the methods presented in the [chapters @sec:initial-labeling] [, @sec:auto-classification] [and @sec:new-classes] on the private email corpus of the author. However, due to privacy issues this corpus will not be released.

The used inbox is sorted into 8 different folders through a mix of rule-based and manual sorting using macOS' build-in ```Mail``` application. There also are 2 separate inboxes for work and study related mails which can be considered another 2 folders totaling 10 different folders.

First the procedure of preprocessing the corpus is explained, then the methods will be evaluated on the preprocessed corpus.

## Preprocessing

The mails were exported in ```mbox``` format. This file format is not formally standardized and the POSIX standard defines only a general format in the *Output Files* section of the ```mailx``` program[^mailx]. This definition only specifies that mails always begin with the ```From``` token followed by a space, end with an empty line and that header and body are separated by a single, empty line. The messages itself follow RFC 2822 - *Internet Message Format*[^rfc-2822] with the extensions for non-ASCII text RFC 2045[^rfc-2045], RFC 2046[^rfc-2046] and RFC 2047[^rfc-2047] *Multipurpose Internet Mail Extensions (MIME)* part 1-3.

Due to the message format, the mails were preprocessed using the following steps:

1. If the mail consists of multiple parts (e.g. the MIME-Type starts with ```multipart/```), recursively preprocess all parts as specified by RFC 2046.
2. According to the ```Content-Transfer-Coding``` header, decode the content (e.g. ```quoted-printable``` or ```base64```).
3. Extract the content if  the ```Content-Type``` header specifies a ```text/plain``` MIME-Type for the message. Remove all HTML Tags if the ```Content-Type``` header specifies a ```text/html``` message. Ignore all other MIME-Types.
4. Convert the content to lowercase.
5. Replace all occurences of tabulators (```\t```), newlines (```\n```) and carriage-returns (```\r```) with spaces.
6. Replace all URLs in the content with the token ```URL```.
7. Normalize whitespaces by replacing every occurrence of one or more whitespaces with a single space.
8. Transcode to Unicode (UTF-8).

Since neither the mbox format nor the RFCs specify an encoding for the message body, mbox can be seen as a binary format. To equalize the coding to UTF-8, the ```charset``` section of the ```Content-Type``` header was used. If not present, ASCII was assumed.

The mbox format was parsed using the mailbox package in the python standard library[^mbox-lib].

To save the preprocessed mails to disk, each email was written into a seperate line to allow for easy loading using gensim's ```LineSentence``` class[^textcorpus-class].

[^mailx]: http://pubs.opengroup.org/onlinepubs/9699919799/utilities/mailx.html
[^rfc-2822]: https://www.ietf.org/rfc/rfc2822.txt
[^rfc-2045]: https://www.ietf.org/rfc/rfc2045.txt
[^rfc-2046]: https://www.ietf.org/rfc/rfc2046.txt
[^rfc-2047]: https://www.ietf.org/rfc/rfc2047.txt
[^textcorpus-class]: https://radimrehurek.com/gensim/models/word2vec.html
[^mbox-lib]: https://docs.python.org/2/library/mailbox.html

## Corpus Statistics {#sec:mail-corpus-stats}

This subsection will present some properties of the corpus created by the preprocessing steps of the previous chapter.

[Table @tbl:mailcorpus-sizes] shows the number of mails for each label totaling 21,571 emails. Although the true label names are not revealed, note that class 1, 7 and 8 contain mails of a singe project and therefore are much smaller than, for example class 6 which contains notification emails from social networks and class 5 which contains newsletters.

The big variance in the number of elements between the labels will require for a closer inspection of classification accuracy, since the accuracy of the whole classifier could be good, although all emails of the classes with few elements are misclassified.

|           | Elements |
|-----------|---------:|
| Class 1   |       73 |
| Class 2   |    1,401 |
| Class 3   |    2,844 |
| Class 4   |      873 |
| Class 5   |    4,922 |
| Class 6   |    7,451 |
| Class 7   |      149 |
| Class 8   |      108 |
| Class 9   |    3,533 |
| Class 10  |      217 |
| **Total** |   21,571 |
Table: Size of the mail corpus by label {#tbl:mailcorpus-sizes}

[Figure @fig:mail-article-sizes] shows a Histogram of the length of ~98.8% of the emails in the corpus, where emails with a length of over 1000 words were filtered out. Compared to the news articles, the average email length is much shorter with ~202 words compared to ~458 words for the news articles (see [figure @fig:articlesize]).

![Histogram of the length of emails in the corpus](source/figures/mail_article_size.pdf "EMail lengths in the Corpus Histogram"){width=100% #fig:mail-article-sizes}

## Evaluation

This subsection will evaluate the methods presented in [chapters @sec:initial-labeling] [, @sec:auto-classification] [and @sec:new-classes] on the mail corpus.

### Clustering for initial Labeling

When working with the news corpus, the summation of word vectors as document vectors worked best compared to TF-IDF and *Paragraph Vectors*. [Table @tbl:mailclustering-results] shows the same advantage of summarized word vectors.

The big increase in homogeneity compared to the news corpus, although almost the same number of classes in the ground truth (10 in the mail corpus compared to 11 in the news corpus), can be explained by the fact that many emails are computer generated, following a simple template and therefore having virtually the same document vector, independent of the vectorizer. Computer generated emails are mainly present in class 6 containing the notification emails of various social networks.

The distribution of the computer generated emails can be seen in the plot of the t-SNE projection of the document vectors (summarized word2vec vectors, [figure @fig:mailw2v-clustering]). The dense orange blob in middle is the representation of all notification emails which has only few outliers.

Furthermore, the clustering using and LDA model and picking the topic with the largest share as cluster yielded again the best homogeneity in the clusters with a value of 0.907.

However, independent on the increase in homogeneity, the clustering techniques show comparable results, hinting that news articles and emails are exchangeable when comparing the performance of clustering methods.

|                 | TF-IDF | word2vec summation | Paragraph Vectors |
|-----------------|--------|--------------------|-------------------|
| k-Means         | 0.105  | 0.749              | 0.675             |
| Ward            | 0.289  | 0.735              | 0.694             |
| Birch           | 0.314  | 0.780              | 0.741             |
| Average Linkage | 0.002  | 0.001              | 0.002             |
| DBSCAN          | 0.052  | 0.019              | 0.063             |
Table: Homogeneity of the clustering methods with different vectorizers on the mail corpus {#tbl:mailclustering-results}

![t-SNE visualization of the mail corpus using summarized word2vec vectors as document vectors](source/figures/mail_tsne_w2v.pdf "t-SNE visualization of the mail corpus"){width=90% #fig:mailw2v-clustering}

### Classification

[Figure @fig:mail-categorization] shows the result of the different classifiers when trained on varying sizes of the training set. The training set was produced with the same 90% / 10% split between the training and validation data that was used for the news corpus.

[Table @tbl:mail-categorization] shows the accuracy of the classifiers using the complete training set.

The overall accuracy is much higher on the mail corpus than it was for any classifier on the news corpus. This is expected since the results of the clustering in the previous subsection already showed evidence that the mail corpus is not as complex as the news corpus for machine learning algorithms. The increase in accuracy can be seen as a property of the mail corpus, however, again the comparison between the algorithms is more important in the question if the news articles are suitable as a more available alternative to emails.

Comparing the results to [figure @fig:class-performance] and [table @tbl:classification-results], one can see that all classifiers behave comparable to the result of the evaluation on the news corpus.

The SVM classifier using TF-IDF vectors has the best accuracy of all classifiers when trained on the complete training set closely followed by the likelihood maximization classifier.

For very few training elements for each class, the advantage of the pre trained base model becomes once more visible with the CNN, likelihood maximization and the SVM classifier using summarized word2vec vectors outperforming the classifiers using TF-IDF vectors. Only the multinomial naive Bayes classifier performed as good in this scenario. The overall performance of the CNN is also once more particularly bad compared to all other classifiers.

![Accuracy of different classifiers with a varying training set size.](source/figures/accuracy_mail_comparison.pdf "Accuracy of classifiers on the mail corpus"){width=90% #fig:mail-categorization}

| Classifier            | Accuracy     |
|-----------------------|--------------|
| Multinomial NB        |     0.933367 |
| SVC (TF-IDF)          | **0.988390** |
| Rand. Forest (TF-IDF) |     0.975192 |
| w2v inv. Bayes        |     0.988294 |
| SVC (w2v)             |     0.953054 |
| CNN                   |     0.913054 |
Table: Result of different classifiers on the mail corpus {#tbl:mail-categorization}

As noted in [chapter @sec:mail-corpus-stats], the big variance in class elements requires for a closer inspection of the classifier output to make sure the good performance in not mainly based on the few, big classes. [Table @tbl:mail-confusion] therefore shows the confusion matrix of the likelihood maximization classifier. As one can see, the accuracy is good for all classes since the highest value of each row is on the diagonal.

| Class | 1     | 2       | 3       | 4      | 5       | 6     | 7     | 8       | 9      | 10     |
|-------|-------|---------|---------|--------|---------|-------|-------|---------|--------|--------|
| 1     | **9** |       0 |       0 |      0 |       0 |     0 |     0 |       0 |      0 |      1 |
| 2     | 0     | **128** |       0 |      1 |       0 |     0 |     0 |       0 |      2 |      0 |
| 3     | 1     |       0 | **283** |      1 |       4 |     0 |     0 |       0 |      0 |      0 |
| 4     | 0     |       0 |       0 | **74** |      12 |     0 |     0 |       0 |      3 |      0 |
| 5     | 1     |       0 |       1 |      9 | **714** |     0 |     0 |       5 |      1 |      0 |
| 6     | 0     |       0 |       0 |      0 |       2 | **9** |     0 |       0 |      0 |      0 |
| 7     | 0     |       0 |       0 |      0 |       0 |     0 | **8** |       0 |      0 |      0 |
| 8     | 0     |       1 |       0 |      0 |       6 |     2 |     0 | **243** |      0 |      0 |
| 9     | 2     |       0 |       0 |      0 |       2 |     0 |     0 |       0 | **13** |      0 |
| 10    | 0     |       0 |       0 |      1 |       0 |     0 |     1 |       0 |      0 | **16** |
Table: Confusion matrix of the likelihood maximization classifier. {#tbl:mail-confusion}

In summary, the very comparable performance of all classifiers and the peculiarities in certain scenarios is another evidence for the exchangeability of emails and news articles when comparing machine learning algorithms that work with natural language.

### Training Data Creation

[Chapter @sec:new-classes] introduced a technique that allows the creation of new training data and proved that this training data can be used to increase classifier performance when very little training data is available.

[Figure @fig:mail-extended-performance] shows a comparison of two naive Bayes classifiers performing a binary classification using negative sampling of the training set analogous to the comparison in [figure @fig:extended-performace-neg-sampling]. The ```original``` classifier only uses the training set elements for training, the ```extended``` classifiers creates new training elements using the method presented in [chapter @sec:new-classes-practical].

Once again, the result is directly comparable to the respective result on the news corpus. While the break-even point between the two classifiers for the news corpus was between 70 and 80 training elements in the new class, it was between 80 and 90 elements in the test with the mail corpus. It is also worth mentioning that the maximum gain in accuracy is only around 5.8% on the mail corpus compared to the up to 15% on the news corpus.

![Performance of the naive Bayes classifier with an extended training set.](source/figures/mail_extended_performace_only_negative.pdf "Extended classifier performance on the mail corpus"){width=90% #fig:mail-extended-performance}
