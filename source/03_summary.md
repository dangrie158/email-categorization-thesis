\pagenumbering{roman}
\setcounter{page}{1}

# Kurzfassung {.unnumbered}

Diese Thesis evaluiert wie *word embedding* Modelle, insbesondere das word2vec Modell, für die Aufgabe der E-Mail Klassifikation genutzt werden können. Nach der Einführung und Motivation werden die verwendeten Algorithmen kurz vorgestellt. Da kein E-Mail Korpus von ausreichender Größe gefunden werden konnte der Klassenlabel zur Verfügung stellt, wurde die Evaluation auf einem Korpus aus deutschen Nachrichten Artikeln durchgeführt. Der dafür erstellte Korpus wird kurz vorgestellt. Danach folgt eine Evaluierung verschiedener Clustering Algorithmen auf dem Datensatz um Methoden zu finden die das initiale Labeling von großen, ungetaggten Datensätzen vereinfachen. Dann werden verschiedene Klassifikatoren auf Basis eines word2vec Modells gegen klassische NLP Klassifikatoren evaluiert. Danach folgt die Vorstellung einer Methode die es erlaubt mit Hilfe eines vortrainierten word2vec Modells die Klassifikationsgenauigkeit um bis zu 15% zu erhöhen, wenn sehr wenig Trainingsdaten vorhanden sind. Zuletzt folgt die Evaluation aller Methoden auf dem privaten E-Mail Korpus des Authors um zu untersuchen ob der Nachrichtenkorpus ein valider Ersatz für einen E-Mail Korpus darstellt.

\newpage

# Abstract {.unnumbered}

This thesis evaluates how *word embedding* models, especially the word2vec model, can be used for the task of email classification. After the introduction and motivation, the algorithms utilized in this thesis will be briefly introduced. Since no sufficiently sized, tagged email corpus could be found, the evaluations were performed on a corpus consisting of German news articles. This corpus will be presented. Next is the assessment of different clustering algorithms on the data set to find ways to simplify the tagging of large, unlabeled data sets. Then, different classifiers based on a word2vec model will be evaluated against classic NLP classifiers. Next, a method is introduced that can increase the classifier accuracy by up to 15% when only little training data is available. Last is the evaluation of all methods on the author's private email corpus to investigate if the news corpus is a valid replacement for a mail corpus.

\newpage
