# Development and Validation Data Sets {#sec:newscorpus}

As noted in [Chapter @sec:approach], the approaches in the next chapter are developed and evaluated on a corpus consisting of german news articles rather than a email corpus. This decision is justified by the fact that no suitable email corpus for development could be found.

One of the biggest publicly available dataset consisting of real emails is the Enron dataset (@klimt2004introducing). The corpus consists of 619,446 emails from 158 users. The inboxes contain the original folder structure that was created by the original owner of the inbox. However, the use of the Enron corpus for development poses some difficulties:

- **corpus size**: While the corpus itself is big, the average number of messages per user is only 757 (@klimt2004introducing). This number drops even more when ignoring messages in folders that are meta folders of the inbox that don't need classification. These folders include sent items, deleted items and notes of the user. Filtering out these items, the number of messages in the complete corpus drops to 186,071. Since the task of folder classification is a per-user task because each user has their own way of managing their inbox, this figure is more important than the overall corpus size. Increasing the amount of data for one user by merging in messages from other users poses the risk of contaminating the inherent sorting strategy the user used and the algorithm needs to learn. Therefore, this task would need manual and carful work preserve this structure.
- **the corpus is a snapshot of a moment**: Users tend to delete emails that contain no longer relevant information. This can be seen by the fact that the metafolders ```deleted_items``` contain 57,653 messages summed up over all users. These messages still would need classification when received, however, they lost their true label since the original folder can't be deduced anymore. Under the thesis that users tend to delete emails that no longer are relevant or contain only little information (such as short yes/no replies), the corpus is preprocessed in a way that maximizes the amount of information in each mail which may affect the classification performance in a positive way. However, since this preprocessing was done manually and is not available in a fully automated application, the results would be distorted.

There are also other corpora available, however none could be found that has a bigger or even similar size to the Enron corpus and provide a similar *real life* structure. The Sarah Palin email dataset (@palin2011) for example does not provide any sort of label at all since it was digitized from printouts of the original emails. Therefore all structure of the original inbox is lost.

For the above reasons, mainly the low corpus size, news articles were used instead of emails. The decision for news articles is based on the following assumptions:

- News articles are widely available and a big corpus can be assembled quickly
- Each article is automatically classifiable into one of a set of categories
- Articles and emails both generally have a single author
- The topic of the articles and new emails change over time
- The length of articles and emails is variable

Since no empirical data could be found about whether or not news articles have the same properties as emails and therefore can be used as a substitute, all developed classification strategies are evaluated against my private inbox, consisting of private, study and work related emails.

This section describes properties of the used news corpus and how it was build.

The corpus was build from the 21st of November 2016 to 6th of March 2017. It consists of 54.691 german news articles in 11 different categories. [Figure @fig:corpuscount] shows the growth of the corpus over time. The flat part at the end of December is due to a server outage over Christmas. [Figure @fig:articlesize] shows the size of the articles in 20 bins. The histogram doesn't show outlier articles with more than 2000 words. However, it still represents over 98.9% of all articles.

![Growth of the corpus size over time](source/figures/corpus_size.pdf "Corpus growth"){#fig:corpuscount}

![Histogram of the article length in 20 bins](source/figures/article_size.pdf "histogram of article length"){#fig:articlesize}

## Crawling

The news articles are being crawled by a Node.js[^3] script in a 2-step process. First, a list of RSS feeds is being crawled and every link to a article is saved. The articles are deduped based on their title from the RSS feed and the publishing date to avoid crawling the same articles multiple times. The list of feeds that are being crawled is based on an updated version of the list of german newssites used by Sasha Can[^4] ([-@can2016entwicklung]). For the full list of feeds see Appendix 1.

In the next step, each previously unvisited article is loaded via the link extracted from the feed and the full content of the page is saved in a MongoDB[^5] database.

[^3]: https://nodejs.org/en/
[^4]: https://github.com/Saytiras/RSS-Crawler/blob/master/config/de_news.json
[^5]: https://www.mongodb.com

## Data Extraction

To work with the news article the text and other useful information needs to be extracted from the articles full webpage. This step happens at crawl time and is done using the Node.js module *unfluff*[^6] which is based on *python-goose*[^7] which in turn is based on *goose*[^8]. Goose is an article extractor that is specifically designed to extract information of news articles.

The informations unfluff tries to extract from the articles page are numerous. Among the most important for a machine learning corpus are:

- the title of the article
- the publishing date
- the text of the article cleaned of all links and images
- the author of the article

All the data that is extracted by unfluff is saved in the database alongside the original article page.

[^6]: https://github.com/ageitgey/node-unfluff
[^7]: https://github.com/grangier/python-goose
[^8]: https://github.com/GravityLabs/goose

## Article Labeling

Online newssites often order their articles in categories, e.g. Politics, Technology. However, unfluff does extract this information as it is highly dependent on the layout of the site. Another problem is that different news sites label their categories differently, although the categories contain similar articles. For example, while one newspaper may name a category about domestic politics *Politik Deutschland*, another may name it *Innenpolitik*.

To overcome these issues, a way to automatically sort the news articles into a list of predefined categories is needed. The List of categories used can be seen in [Table @tbl:categories] and was assembled by finding the lowest common denominator across all news sites in the list of sources. While this list was found independently, a strong similarity with the list of topics from @can2016entwicklung can be noticed. This fact reinforces the confidence that the found list of labels is a good fit for german news articles.

To label the article in an automatic way, @can2016entwicklung used news archives with labeled data to train a classifier using a support vector machine (SVM). However, the objective then was to filter out political articles. Since this corpus will be used for training and validation, the true label can not be predicted by another classifier, since this would result in a corpus that could only be used to train models that are at best as good as the original corpus used for labeling.

Luckily it was observed that all used news sites use URLs that represent the internal structure and therefore a topic as part of the URL. Thus, a regular expression for each site could be used to filter out this information. Since the resulting matches vary greatly between but also within different sites, they get mapped to one of the 11 predefined labels as the next step. [Table @tbl:categories] shows examples of the extracted topics and this mapping in the column *Example Subtopics*. Some of the topics could not be mapped to one of the labels, for example very special topics that only appear once, and others do contain articles without any news relation, for example ads. These topics were mapped to the *Ignore* category.

While this approach requires manual work every time one of the sites changes their URL scheme or adds a new topic, during the collection of the corpus only one news site changed the URL scheme (the IT-News portal golem disabled access via unencrypted HTTP connections) and 11 new topics were added in total, most of which were special topics that were mapped to the *Ignore* category.

[Table @tbl:categories-count] shows the number of articles in each category.

| Label         | English Meaning   | Example Subtopics                                      |
|---------------|-------------------|--------------------------------------------------------|
| Politik       | domestic politics | ```politik_deutschland```, ```innenpolitik```          |
| Ausland       | foreign politics  | ```politik_ausland```, ```ausland```                   |
| Aktuell       | latest news       | ```newsticker```, ```thema```, ```eilmeldung```        |
| Technologie   | technology        | ```Wissen_Mensch```, ```spiegelwissen```               |
| Kultur        | culture           | ```Wissen_Kultur```, ```Wissen_History```              |
| Wirtschaft    | economy           | ```unternehmen_management```                           |
| Finanzen      | finances          | ```finanzen_immobilien```, ```vorsorge```              |
| Sport         | sports            | ```Sport_tennis```, ```Sport_Fussball```               |
| Sonstiges     | miscellanea       | ```allgemein```, ```schlusslicht```, ```campus```      |
| Lokal         | local             | ```kommunalpolitik```, ```nrw```, ```hamburg```        |
| Lifestyle     | lifestyle         | ```shopping```, ```stil```, ```entdecken```            |
| *Ignore*      |                   | ```icon```, ```videoblog```, ```anzeigen```            |

Table: The categories used as Labels  {#tbl:categories}

| Label         |    articles   |
|---------------|---------------|
| Politik       |         14132 |
| Ausland       |          4191 |
| Aktuell       |           200 |
| Technologie   |          3726 |
| Kultur        |          2247 |
| Wirtschaft    |          8593 |
| Finanzen      |          2538 |
| Sport         |          4418 |
| Sonstiges     |          8094 |
| Lokal         |          2700 |
| Lifestyle     |          3305 |
| *Ignore*      |           574 |

Table: Number of articles in each category  {#tbl:categories-count}

## Article normalization

While unfluff extracts the plain text of the news article and removes all ads and comments, the text still needs further processing, so that it can easily be used with machine learning algorithms. This includes normalization, tokenization and phrase detection.

Normalization is the process of converting all text into the same case. Without this step the same word may be interpreted as unequal depending on the case of the word (for example capital case on the beginning of a sentence). This step also normalizes the character encoding to UTF-8 which may initially be different depending on the source of the article.

Tokenization is the process of splitting a string of words into separate tokens. In the easiest case, every token is a word and the string is split at every non-word character, e.g. whitespaces and punctation characters. However, often the single-word approach for tokens is too aggressive. A classic example for when this strategy fails is the word *New-York*. The simple approach would split the phrase into two tokens, although it may be beneficial to save both words as a single token.

The solution to this problem is called phrase detection. A phrase detection may be rule based or uses statistical heuristics. A statistical model may use collocations; words that appear often together. @mikolov2013distributed present a statistical model that uses formula (@phrasedetection) to calculate a score for each combination of words. If two words have a higher score than a predefined threshold, the words are considered a phrase. By running this process multiple times, longer phrases consisting of more words can be found.

(@phrasedetection) $$score({ w }_{ i },{ w }_{ j })=\frac { count({ w }_{ i }{ w }_{ j })-\delta  }{ count({ w }_{ i })\times count({ w }_{ j }) } $$

Normalization of text can consist of further steps like stemming, lemmatization or stopword filtering. However, to keep the corpus universally useable, these steps were not performed at this stage, as they may have no or even a negative impact on the performance of some classification algorithms since they remove information. However, some of the approaches in the next chapter do filter stopwords. The use of such a filter is mentioned in the corresponding chapters.

For normalizing and tokenizing the news article texts, the *normalizr* package[^normalizr] is used. The normalization to the UTF-8 codec is done using pythons build-in *codecs* package. The phrase detection is done in a later step using gensim's *phrases* class[^phrases] that uses the algorithm described above.

[^normalizr]: https://github.com/davidmogar/normalizr
[^phrases]: https://radimrehurek.com/gensim/models/phrases.html

## The Wikipedia Corpus {#sec:wikipedia-corpus}

The word2vec model presented in [Chapter @sec:word2vec] tries to learn good word representations by leveraging the distributional hypothesis ans word co-occurrences. Previously unseen words, however, get initialized with a random vector that is then adjusted by the learning algorithm. This process yields vectors that are mainly based on their random initial state for words that occur only a few times in the corpus. For this reason, gensim's word2vec implementation offers the ```min_count``` parameter with a default value of 5. The parameter specifies a lower bound to how often a word needs to be observed in the corpus. Words which appear more infrequent are not learned by the model. This offers an easy way to make sure, the vectors learned by the model are not mostly based on a random state, but are adjusted by a minimum number of training steps.

However, due to the relatively low corpus size (13,233,740 words after stopword filtering[^stopword-filtering] with 377,998 unique tokens, only 108,900 of which appear more than 5 times), using this lower bound, the news corpus could only be used to learn vector representations for ~29% of the words that appear in the corpus. [Figure @fig:wordfrequencies] shows a histogram of the word frequency of each unique word in the corpus.

Since the word2vec model is trained unsupervised, any large collection of text can be used to increase the size of the corpus. If different models need to be learned, it is important that this base corpus contains neutral texts in regard to the difference of the models learned.
For example, if the objective is to classify text into modern and classic literature, the base corpus should not mainly contain samples of either class (e.g. texts from the Gutenberg Project[^gutenberg]).

For this reason, a dump of the german Wikipedia corpus from 21. October 2017 is used as a base corpus. Since this corpus contains articles over a broad range of topics and is written by a large amount of authors, it matches all criteria for a neutral base corpus. This corpus contains 1,769,502 articles with 834,698,710 words (6,795,065 unique tokens of which 1,862,009 appear more than 5 times).

![Histogram of word frequencies in the news corpus on a log-log scale.](source/figures/word_frequencies.pdf "histogram of word frequencies"){#fig:wordfrequencies}

[^gutenberg]: https://www.gutenberg.org
[^stopword-filtering]: Using the german stopwordlist of NLTK (http://www.nltk.org)

<!--
stopwords:
Total words: 13233740
Unique words: 377777
12804395 frequent word occurences
108900 frequent words

mit stopwords:
Total words: 22084331
Unique words: 377998
21654986 frequent word occurences
109121 frequent words
-->
