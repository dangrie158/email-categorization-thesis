# Introduction

The way we use modern technology to communicate is still under ongoing development. Work related messaging, however, is still dominated by E-Mail being the most commonly used form of communication. The Radicati Group estimates the number of work-related E-Mails received by each individual per day to average at 122 in the year 2016 and sees continuing growth of this number in the following years [@radicatireport]. E-Mail, however, is not only used for work-related- but also private communication. According to the Pew Research Center, in 2011 92% of the American population used E-Mail as a form of communication [@pewreport]. This ubiquity leads many people to mix their private and work E-Mail accounts. A 2013 survey conducted by GFI Software found that 81% of Americans check their work E-Mail outside their working hours [@gfireport]. The same study also found that 62% use different folders in their mailbox to categorize the received E-Mails. The mixing of private and work related E-Mails and the following permanent availability can cause additional stress [@kushlev2015checking]. Equally, the need to read at least a part of the E-Mail to be able to manually sort it and decide whether to react now or later does not allow for a workflow without interruptions.

For the above reasons, a way to automatically sort incoming Mail is desired. This thesis will elaborate methods to allow sorting incoming mail automatically into different categories. Since many users that would profit from such a system already manually sort their emails into different folders, the current inbox emails can be used as a training set with the folder being the target label. However, to allow the sorting of inboxes that are only partially sorted or not yet sorted at all, methods to allow sorting of big, unlabeled corpora using minimal manual labor and unsupervised Natural Language Processing (NLP) algorithms will be presented and evaluated.

## Approach {#sec:approach}

Schreiben wenn fertig
dass / warum news verwendet wurden

- sarah palin emails
- enron corpus

- was nicht gemacht wird
  - metadaten
  - threads
  -


validation der ansätze mit newsgroups
validation der daten mit eigenem email datensatz (weil mehr "real life" datensatz (spam, verschiedene vormate e.g. tofu))

<!--The methods that will be analyzed will all be based on a word2vec model [@mikolov2013efficient].
For the automatic classification into categories that already have a large tagged training set available (e.g. different folders in the user's inbox), a simple strategy may suffice. This simple strategy may use a large word2vec model as a neutral base and inherits a concrete model for each category by learning the tagged data. The classification task then simply maximizes the log-likelihood of a new document by minimizing the calculated loss in each model.

For a more fine-grained classification and in other cases where not enough training data is available, a more sophisticated strategy is needed. For this, a keyword based approach will be developed and evaluated. This approach may extend a single or multiple user-provided keywords into a  bigger cloud of words that are similar to the keyword. Again a word2vec model is used for this task. This model may be trained with a natural base corpus (e.g. Wikipedia) and then extended with the corpus of all emails to learn the specific language of the mail corpus. This method may provide a better classification rate than a completely user-curated list of keyword-based rules.-->

Due to the lack of a readily available, tagged E-Mail corpus with mixed content (personal and private), the methods will instead first be developed and evaluated on a news corpus that is built by crawling a set of german news sites. Later, the strategies will also be evaluated on the author's private mail corpus, however, this corpus will, in contrast to the generated news corpus, not be published.

## Contributions

- vielleicht gensim extension für part models
- corpus mit xxxk news artikeln
- shown that newsarticles are a substitute to mails
