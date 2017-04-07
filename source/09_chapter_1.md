# Introduction {#sec:intro}

The way we use modern technology to communicate is still under ongoing development. Work related messaging, however, is still dominated by email being the most commonly used form of communication. The Radicati Group estimates the number of work-related emails received by each individual per day to average at 122 in the year 2016 and sees continuing growth of this figure in the following years [@radicatireport]. Email, however, is not only used for work-related- but also private communication. According to the Pew Research Center, in 2011 92% of the American population used email as a form of communication [@pewreport]. This ubiquity leads many people to mix their private and work email accounts. A 2013 survey conducted by GFI Software found that 81% of Americans check their work email outside their working hours [@gfireport]. The same study also found that 62% use different folders in their mailbox to categorize the received emails. The mixing of private and work related emails and the resulting permanent availability can cause additional stress [@kushlev2015checking]. Equally, the need to read at least a part of the email to be able to manually sort it and decide whether to react now or later does not allow for a workflow without interruptions.

For the above reasons, a way to automatically sort incoming Mail is desired. This thesis will elaborate methods to allow sorting incoming mail automatically into different categories. Since many users that would profit from such a system already manually sort their emails into different folders, the current inbox emails can be used as a training set with the folder being the target label. However, to allow the sorting of inboxes that are only partially sorted or not yet sorted at all, methods to help to sort large, unlabeled corpora using minimal manual labor and unsupervised natural language processing (NLP) algorithms will be presented and evaluated.

## Approach {#sec:approach}

Vector space models for text classification have gained much attention in the last years since they can be trained on unlabeled data and learn a language model where associations between words can be represented by linear operations in the vector space (@mikolov2013efficient). This thesis will, therefore, evaluate the performance of different classifiers, all using word vectors from a word2vec model, against each other to compare the performance. Also, different state-of-the-art text classification techniques like SVD with TF-IDF vectors will be used as a comparison to find if the classifiers benefit from a vector space model.

Due to the lack of a readily available, tagged email corpus with mixed content (personal and private), the methods will instead first be developed and evaluated on a news corpus that is built by crawling a set of German news sites. Later, the strategies will also be assessed on the author's private mail corpus. However, this corpus will, in contrast to the generated news corpus, not be published due to privacy.

## Non-goals

This thesis is only concerned about the text classification task on the email body. It does not consider additional info that is available in an email corpus like metadata of the message (e.g. sender, recipient, date or subject) or information about the thread an email belongs to (e.g. replies and forwardings).

However, it should not go unmentioned that, in some cases, the full body of the mail may not be available, for example, due to encryption.

It also is worth noting that this available data may be high-quality features as, for instance, a thread probably is often about a single topic and therefore all of its messages would be of the same class.

<!--The methods that will be analyzed will all be based on a word2vec model [@mikolov2013efficient].
For the automatic classification into categories that already have a large tagged training set available (e.g. different folders in the user's inbox), a simple strategy may suffice. This simple strategy may use a large word2vec model as a neutral base and inherits a concrete model for each category by learning the tagged data. The classification task then simply maximizes the log-likelihood of a new document by minimizing the calculated loss in each model.

For a more fine-grained classification and in other cases where not enough training data is available, a more sophisticated strategy is needed. For this, a keyword based approach will be developed and evaluated. This approach may extend a single or multiple user-provided keywords into a  bigger cloud of words that are similar to the keyword. Again a word2vec model is used for this task. This model may be trained with a natural base corpus (e.g. Wikipedia) and then extended with the corpus of all emails to learn the specific language of the mail corpus. This method may provide a better classification rate than a completely user-curated list of keyword-based rules.-->


## Contributions

The main contributions of this thesis can be summed up in the following points:

- A memory efficient implementation of derived word2vec models that allow multiple models to be loaded at the same time in memory
- An implementation of an optimized algorithm based on the work of @koehn2003empirical to split compound words of synthetic languages into their parts
- A German news corpus, containing >100,000 articles with rich information such as author, date, normalized text and 11 different labels[^corpus-repo].
- A method to increase the accuracy of classifiers when only little training data is available by creating new training sets using only unsupervised algorithms and unlabeled data.
- Empirical evidence that news articles can be utilized as a more available alternative for emails when working with natural language machine learning algorithms.

[^corpus-repo]: https://gitlab.mi.hdm-stuttgart.de/griesshaber/german-news-corpus
