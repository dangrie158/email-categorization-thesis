# News Classification

## word2vec ansatz mit basemodel
warum basemodel:
  - weil sonst wörter die nicht (oper selten) vorkommen random initialisiert werden
  - lernen einer normalen sprache


## clustering (unsupervised on word2vec model)

## word2vec log likelyhood

- riesen modelle
- beste performance
- schnell (gute performance für lernen und sehr gute performance für kategorisieren)

## word2vec as doc2vec (SVD as classifier)

- schlechte performance (schlechter als tf-idf vectorizer mit SVD)
- nur ein riesen modell
- semi schnell (SVD lernen ok, prediction gut)

## cnn
- (noch) beschissene performance
- mini modell (cnn) + 1 w2v modell
- nicht alle daten können verwendet werden (a-priori normalisierung)
- langsam (ewig am lernen, langsame vorhersage)

problems:
- random initialization (missing words) needs same distribution
- padding (how avoided) (maybe: is it really a problem when worde repititions from article beginning)
- same a-priori (overfitting to a-priori as parameter)
    - solved through equalization of a-priori
- hard to learn (all other models were learned on a macbook, this needs to be learned on a 4GPU cluster)

## results & comparison of methods
not near 100% accuracy (currently ~80%)
but: most methods have a "confidence" e.g. log-likelihood
-> confidence score
if confidence < minimum score: don't sort the email

speed / mem consumption: auch wenn initiales lernen ein "einmaliger" task ist ist geschwindigkeit immer gut. ausserdem müssen modelle eventuell neu gelert werden (z.B. wenn neue klassen hinzukommen oder andere hyperparameter verändert werden sollen)

## other metrics (input parameters)
- metadata (auch wenn keine tests damit gemacht wurden weil der corpus fehlt ein paar gedanken dazu)
- author (via SVD)
- how to combine
- maybe sometimes only the metadata is available (secured connections SMTP over SSL)

experiment:
learn authors -> category and test result (are the authors really in this category)

## Naiver Bayes auf LDA


## random Indexing
