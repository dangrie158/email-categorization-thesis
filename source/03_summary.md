\pagenumbering{roman}
\setcounter{page}{1}

# Abstract {.unnumbered}

This thesis evaluates how *word embedding* models, especially the word2vec model, can be used for the task of email classification. After the introduction and motivation, the algorithms utilized in this thesis will be briefly introduced. Since no sufficiently sized, tagged email corpus could be found, the evaluations were performed on a corpus consisting of German news articles. This corpus will be presented. To find ways to simplify the tagging of large, unlabeled datasets, different clustering algorithms are assessed on the corpus. These methods can be used, if an untagged email corpus should be used when training a classifier. For the task of email classification, different classifiers based on a word2vec model will be evaluated against classic NLP classifiers. Since the real-time classification of incoming emails can cause scenarios where only little training data for a class is available, a method is introduced that can increase the classifier accuracy by up to 15% in these scenarios. Last is the evaluation of all methods on the author's private email corpus to investigate if the news corpus is a valid replacement for an email corpus.

\newpage

# Kurzfassung {.unnumbered}

Diese Thesis evaluiert wie *word embedding* Modelle, insbesondere das word2vec Modell, für die Aufgabe der E-Mail Klassifikation genutzt werden können. Nach der Einführung und Motivation werden die verwendeten Algorithmen kurz vorgestellt. Da kein E-Mail Korpus von ausreichender Größe gefunden werden konnte, welcher Klassenlabel zur Verfügung stellt, wurde die Evaluation auf einem Korpus aus deutschen Nachrichten Artikeln durchgeführt. Der dafür erstellte Korpus wird kurz vorgestellt. Um Methoden zu finden die das initiale Labeling von großen, ungetaggten Datensätzen vereinfachen, folgt eine Evaluierung verschiedener Clustering Algorithmen auf dem Datensatz. Diese Methoden können benutzt werden, wenn ein E-Mail Korpus der noch nicht über Labels verfügt für das Training eines Klassifiers benutzt werden soll. Für die Aufgabe der Klassifikation werden verschiedene Klassifikatoren auf Basis eines word2vec Modells gegen klassische NLP Klassifikatoren evaluiert.

Da es bei der echtzeit Klassifikation von eingehenden E-Mail Nachrichten vorkommen kann, dass Klassen sehr wenig Trainingselemente besitzen, folgt die Vorstellung einer Methode die es erlaubt, mit Hilfe eines vortrainierten word2vec Modells, die Klassifikationsgenauigkeit in diesen Szenarien um bis zu 15% zu erhöhen. Zuletzt folgt die Evaluation aller Methoden auf dem privaten E-Mail Korpus des Autors um zu untersuchen ob der Nachrichtenkorpus ein valider Ersatz für einen E-Mail Korpus darstellt.

\newpage
