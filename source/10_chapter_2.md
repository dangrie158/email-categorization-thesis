# Theoretical and Technical Framework

This section provides an overview of the technologies and algorithms used to implement and validate the classifiers presented in the next sections.

## Tools

**SciPy** [^scipy]

SciPy is a set of Python libraries for scientific computing. The main packages used in this thesis are:

- *NumPy* a library for multi-dimensional arrays of arbitrary data types with efficient implementation of mathematic operations on this data.
- *SciPy* a collection of mathematic operations on data including transformation, random sampling and dimensionality reduction algorithms.
- *Matplotlib* a plotting library that can plot 2D and 3D data and save it in multiple output formats. Used to create most charts in this thesis.
- *IPython* a Python kernel for the interactive Jupyter notebook server.

[^scipy]: https://scipy.org

**scikit-learn** [^scikit-learn]

Scikit-learn is a Python library build on top of SciPy that implements Machine Learning algorithms including classification, clustering and regression.

[^scikit-learn]: http://scikit-learn.org

**Gensim** [^gensim]

Gensim is a Python package by Radim Řehůřek that provides efficient implementations of machine learning algorithms for text-based data. Gensim's implementation of the LDA and word2vec algorithms is used in this thesis.

[^gensim]: https://radimrehurek.com/gensim

**Keras** [^keras]

Keras is a high-level abstraction library written in Python for Theano[^theano] and TensorFlow[^tensorflow] backends. Theano and TensorFlow are both graph-based computation libraries for multi-dimensional data flow.  Keras provides a common interface for both libraries. It is used to implement the CNN classifier presented in [chapter @sec:cnn-classifier].

[^keras]: https://keras.io
[^theano]: http://deeplearning.net/software/theano/
[^tensorflow]: https://www.tensorflow.org

## Word2Vec {#sec:word2vec}

Word2vec is a method to build a Vector Space Model (VSM) in which words can be represented (embedded) that was introduced by Mikolov et al. [-@mikolov2013efficient].
Classical NLP models often treat each word as a single, atomic symbol, for example, as a numeric id (e.g. ```car: 350``` and ```truck: 543```) or a single-hot vector. A single-hot vector is a binary sparse vector with the same dimensionality as the length of the vocabulary with only one (single) non-zero (hot) element. These simple BOW approaches, however, do not allow the representation of similarities between words (e.g. the word ```car``` and ```truck``` are both motorized transportation devices with 4 or more wheels). Therefore, an algorithm using one of these representations cannot take advantage of this knowledge unless it learns them as part of the training, which requires more training data.

Word2vec, however, tries to embed each word in the vocabulary in a vector space with, compared to the dimensionality of single-hot encodings, very low dimensionality (typically between 100 - 1000, @mikolov2013efficient). It uses the *distributional hypothesis* which states that words which occur in the same context tend to share a similar meaning [@harris1954distributional]. The algorithm therefore tries to learn dense vectors that have a high (cosine-) similarity for words that co-occur often and a low similarity for words that do not occur in the same context.

Word2Vec uses a *predictive method* that either tries to predict a word using its context as an input or to predict the context given the current word. Another approach is to use a *count based* model like Latent Semantic Indexing (LSI) that tries to learn the correlation between words by counting the co-occurrence and then transform this information into a low-dimensional vector space using Singular Value Decomposition (SVD) [@dumais1988using]. However, both, predictive and count based methods can be learned unsupervised on unlabeled training data because the only input is the context of the current word. This property allows the use of any text corpus in any language where the distributional hypothesis holds true. To train word2vec models with good vector representations[^1], a large corpus is needed. This requirement comes from the fact that the distributional hypothesis is a statistical model which profits from a large corpus where words occur in their context more than once. Mikolov et al. published a pre-trained word2vec model they used to evaluate the optimization methods in @mikolov2013distributed. This model was trained on 100 billion (english) words from a Google News corpus.

[^1]: good vector representation of words will have a small distance between words with a similar meaning and long distances for words with different meanings.

### Learning of the Word Embeddings

Word2Vec uses one of two approaches to learn vector representations of the words in the corpus, skip-gram or continuous bag of words (CBOW).

The CBOW approach tries to learn the model in a way that maximizes the probability to generate the current target word out of a bag of context words. Due to the bag of words approach for the context words, the order of the words in the current context does not matter. Since CBOW uses multiple input words, the input to the model is either generated by simply summing the vectors for all context words or by using the mean average of all input words.

![Continuous bag of words architecture with a context window of 4 words and a summing strategy to combine the multiple input vectors](source/figures/cbow-aritechture.pdf "Continuous bag of words architecture"){#fig:cbow}

In contrast to the CBOW approach, the skip-gram architecture tries to predict the context words out of the current word as input. The order of the words is weighted into the target by giving context words closer to the current word a higher weight.

![Skip-gram architecture with a context window of 4 words](source/figures/skipgram-aritechture.pdf "Skipgram architecture"){#fig:skipgram}

On the Google Code page for the word2vec project[^2] the authors state that CBOW is the faster algorithm whereas skip-gram provides better performance for infrequent words. The following section will explain how vector representation can be learned in a CBOW configuration. A model for the skip-gram configuration, however, uses the same basic concepts with some peculiarities for the different objective. <!--Since in this thesis only models are used that use the CBOW architecture, the following section will explain how the vector representations are learned in this configuration.-->

The model that will be learned to optimize the CBOW objective is a shallow neural network with one, fully connected, hidden layer. The input and output layer have the same dimensionality $v$ which is equal to the size of the vocabulary $V$. The hidden layer has dimensionality $k$ which equals the dimensionality of the vector space in which the words will be embedded. Since the layers are fully connected, the weights between the layers can be represented by a matrix ${Wi}_{v\times k}$ for the connection between input- and the hidden layer or ${Wo}_{k\times v}$ for the links from the hidden- to the output layer respectively.

![The structure of a neural net with a CBOW architecture](source/figures/cbow-nn.pdf "Detail view of CBOW net"){#fig:cbowdetail}

As shown in [Figure @fig:cbow] above, to train the the word ${w}_{t} \in V$ the context $c_{ { w }_{ d, t } }=\{ { w }_{ d, t-C },{ w }_{ d, t-C-1 },\dots { w }_{ d, t-1 },{ w }_{ d, t+1 },\dots ,{ w }_{ d, t+C }\}$ is considered relevant, where $C$ is half the window size and ${ w }_{ d, x }$ is the $x$-th word in document $d$ represented as a one-hot vector. To represent the context $c_{ { w }_{ t } }$, the single-hot vectors of each word in the context is either summed up or mean-averaged ((@sumcontext) or (@meancontext) respectively).

(@sumcontext) $$ \vec { { c }_{ { w }_{ t } } } =\sum _{ w\in { c }_{ { w }_{ t } } }^{  }{ w }  $$

(@meancontext) $$ \vec { { c }_{ { w }_{ t } } } =\frac { 1 }{ 2C } \sum _{ w\in { c }_{ { w }_{ t } } }^{  }{ w }  $$

The hidden layer has a simple, linear activation function (${f}_{i}(x) = x$). Therefore, the output of the hidden layer is simply the result of multiplying the input vector $\vec { { c }_{ { w }_{ t } } }$ with the weight matrix $Wi$

(@hiddenlayercalc) $${ \vec { h } =\vec { { c }_{ { w }_{ t } } } \times Wi=\frac { 1 }{ 2C } \sum _{ j=0 }^{ v }{ { Wi }_{ j } }  }^{ T }$$

where ${ Wi }_{ j }$ is the $j$-th row of $Wi$.

Since the rows of the input matrix correspond to the words in the vocabulary, this multiplication can be implemented very efficiently by summing up the rows of the matrix where the input vector has a non-zero value and transpose the result (@hiddenlayercalc). In the case of mean-averaged input vectors, the result also needs to be divided by the context size.

To calculate the state of the output layer $\vec{o}$, the current state of the hidden layer $\vec{h}$ needs to be multiplied by the output weight matrix $Wo$. Since the CBOW objective is to learn the neural network in a way that maximizes the probability to generate the output word given a set of input words, the output layer uses a softmax activation function (@softmax) to output probabilities for each neuron that will sum up to one. (@outputlayercalc) shows the formula to calculate the probability for word $w_t$ to be generated with the current hidden layer state $\vec{h}$ where ${Wo}_{i}$ is the $i$-th column of the matrix $Wo$.

(@softmax) $${ softmax(x) }_{ j }=\frac { exp({ x }_{ j }) }{ \sum _{ i=1 }^{ K }{ exp({ x }_{ i }) }  } \quad for \quad j=\{ 1, \dots ,  K \}$$

(@outputlayercalc) $$ p({ w }_{ t }|{ c }_{ { w }_{ t } }) = \frac { exp(\vec { h } \cdot { Wo }_{ t }) }{ \sum _{ i=0 }^{ V }{ exp({ \vec { h } \cdot { Wo }_{ i } } ) }  } $$

The maximization of the likelihood that word $w_t$ is generated by its context $c_{w_t}$, which is the objective of the CBOW model, can be expressed by (@cbowobjective) using (@outputlayercalc).

(@cbowobjective) $$\underset { Wi,Wo }{ argmax }\ log(p({ w }_{ t }|{ c }_{ { w }_{ t } }))$$

To maximize (@cbowobjective), the loss function needs to be minimized by adjusting the matrices $Wi$ and $Wo$. The loss is calculated by subtracting the summed likelihoods for every *wrong* combination of target-context pairs from the likelihood of the *correct* pair. Due to the softmax normalization, the sum of likelihoods for the *wrong* pairs is equal to $1-p({ w }_{ t }|{ c }_{ { w }_{ t } })$.

(@lossfunction) $$
\begin{aligned}
L(Wi,Wo)
&=-(p({ w }_{ t }|{ c }_{ { w }_{ t } })-\sum _{ { w }_{ n }\in V\setminus { w }_{ t } }^{  }{ p({ w }_{ n }|{ c }_{ { w }_{ t } }) } ) \\
&=-(p({ w }_{ t }|{ c }_{ { w }_{ t } }) - (1-p({ w }_{ t }|{ c }_{ { w }_{ t } }))) \\
&=1-2p({ w }_{ t }|{ c }_{ { w }_{ t } })
\end{aligned}
$$

Using this loss function, the model can be trained with any back-propagating loss optimization strategy (e.g. Stochastic Gradient Descent, Adam or AdaGrad).

[^2]: https://code.google.com/archive/p/word2vec/

### Optimizations and Parameters

#### Hierarchical Softmax

A word2vec model, like most machine learning algorithms, profits from a large training set. Furthermore, it can only embed words in the vector space that are present in the vocabulary. Therefore, the weight matrices $Wi$ and $Wo$ can get large, because for both the size of the vocabulary dictates the size of one dimension.

As stated earlier, the computation of the hidden layer state $\vec{h}$ can be implemented very efficiently by directly summing the rows of the weight matrix $Wi$ (@hiddenlayercalc). However, the calculation of the output vector $\vec{o}$ with the naive approach in (@outputlayercalc) requires the computation of the whole matrix multiplication to calculate the denominator in the softmax activation function.

To overcome this issue, the hierarchical version of the softmax function (@morin2005hierarchical and @mnih2009scalable) can be used (@mikolov2013efficient). Hierarchical softmax uses a binary tree (more specifically a Huffman tree to get an optimal prefix coding for more frequent tokens) where every token, in this case every word in the vocabulary, is a leaf of the tree ([Figure @fig:bintree]). In a balanced binary tree, the depth of each leaf is limited to $\left\lceil {log}_{2}(N)\right\rceil$ where $N$ is the number of leafs. Since a Huffman tree optimizes the depth of its leaves by their frequency, the average depth is also limited to this value.

![An example binary tree for a vocabulary with V words. (Rong (2014)](source/figures/binary-tree.pdf "Binary tree for a vocabulary"){#fig:bintree}
The hierarchical softmax approach now uses each branch of the tree as a normalized probability. The final probability for the leaf $l$ is calculated by multiplying each branch along the direct path of the tree up to to the node $l$. The Paper @mnih2009scalable formulates this strategy as follows:

> This setup replaces one $N$-way choice by a sequence of $O(log N)$ binary choices.

Therefore, the computation of the loss function decreases in its complexity exponentially. @mikolov2013distributed give the updated formula to calculate the probability of word ${w}_{t}$ being produced by the context ${c}_{{w}_{t}}$:

(@hierarchicalsoftmax) $$ p({ w }_{ t }|{ c }_{ { w }_{ t } })=\prod _{ j=1 }^{ L({ w }_{ t })-1 }{ \sigma (\llbracket  n(w,j+1)=ch(n(w,j)) \rrbracket  \cdot { { v' }_{ n(w,j) } }^{ T }) } $$

in which one can see the continuous product of the inner term over the $L({w}_{t})-1$ nodes that are traversed to the leaf that represents the word ${w}_{t}$. ${ { v' }_{ n(w,j) } }^{ T }\vec { h }$ is the product of the current node with the output of the hidden layer and $\sigma$ is the softmax function. $\llbracket \cdot \rrbracket$ is a special function which returns $1$ if the inner term is true and $-1$ otherwise. $n(w,j)$ returns the $j$-th node on the path to $w$ and $ch(n)$ returns a fixed but arbitrary child node of $n$ (e.g. always the left branch).

@rong2014word2vec and @yinhierarchical go into great detail on how this formula can be understood and how it can be used during the learning phase of the model.

#### Subsampling

In a large corpus, there will be some phrases (word co-occurrences) that occur much more frequent compared to others (see [Figure @fig:wordfrequencies]). As the word vectors for the words in the phrase will change less with every training step as they "settle" towards their optimal position, the model profits less and less from performing a training step on those phrases. Also, in an unprocessed corpus, there will be words with a much higher frequency compared to others. These words may be stop words (e.g. 'the', 'and', 'or') with no significant importance to the meaning of the phrase.

Therefore, @mikolov2013distributed suggest a subsampling of the words in the corpus based on their term frequency. They provide the formula

(@subsamplingformula) $$ P({ w }_{ i })=1-\sqrt { \frac { t }{ f({ w }_{ i }) }  } $$

that calculates the probability for the word ${ w }_{ i }$ to be skipped in this training step. $f(w)$ is the term frequency of word $w$ and $t$ is a threshold which is defined as a hyperparameter of the model. Gensim's implementation of word2vec uses $0.001$ as a default value for $t$.

Subsampling is a cheap operation during learning if the word frequencies are already precalculated (e.g. from building the Huffman tree). Therefore, it can be used as a simple way to scale down the impact of stopwords on the model without the need of a language-specific stopword set.

#### Negative Sampling

Negative sampling is another approximation strategy to avoid the expensive calculation of the softmax activation function. Negative sampling was introduced by @mikolov2013distributed. The idea is based on the noise-contrastive estimation (NCE) by @mnih2013learning. However, while NCE tries to estimate the log-probability $log(p(y|X))$, word2vec only is concerned about learning good vector representations for the words in the vocabulary. The log-probability at the output layer is only used while learning. Therefore, the NCE approximation is further simplified, while the word vectors retain their quality.

The idea of negative sampling is, instead of learning the full probabilistic model by calculating the log-likelihood for every word at the output layer, only $k$ negative samples from the vocabulary are chosen from a random distribution. The negative sampling objective now tries to maximize the probability of the correct sample in contrast to the negative (noise) samples. Therefore, there are now only $k$ (non-normalized) calculations in the output layer instead of $V$. @mikolov2013distributed define good values for $k$ from 5 to as high as 20 for small corpora and as low as 2 for large corpora.

### Interesting Properties of the word2vec Model

Word2vec works unsupervised. Therefore, large training corpora can easily be found. The algorithm is independent of the language used and in theory should work with any language where the distributional hypothesis holds true. Word2vec learns good word vectors with one of the simple architectures described above. Since the algorithm in its basis is a simple neural net, the algorithm can benefit from further research in this area, e.g. new optimizing methods. The simple architecture also results in quicker learning compared to other models (@mikolov2013distributed).

However, vectors learned by word2vec also have another interesting property. They automatically learn representations between words that can be expressed as linear operations in the vector space. An often cited example for this property comes from @mikolov2013efficient. They use the word vectors from their Google News corpus and show that the result of the linear combination ```w['Paris'] - w['France'] + w['Italy']``` is closest to the vector for the word ```w['Rome']```. They also show the result of other relationships, for example, adjective $\rightarrow$ comparative and company name $\rightarrow$ CEO surname.

## Latent Dirichlet Allocation {#sec:lda}

Latent Dirichlet allocation (LDA) is a generative model used for topic modeling described by @blei2002latent. The algorithm performs a compression on a corpus by describing each document $w$ by a mixture of $K$ topics $z_1, z_2, \dots , z_K$ where $K$ is a hyperparameter of the model.

LDA is a successor of Latent Semantic Indexing (LSI) (@deerwester1990indexing) or more precisely the probabilistic variant PLSI (@hofmann1999probabilistic).

LSI is a discriminative model that uses a tf-idf (term frequency - inverse document frequency) matrix of the words in the corpus and compresses this matrix using a singular value decomposition (SVD). PLSI, in contrast, is a generative mixture model, that tries to model the probability of the word co-occurrence of a word $w$ in document $d$; $p(w,d)$ by the mixture of independent multinomial distributions. Thomas Hoffman presents equation (@plsi-mixture) that defines the joint probability model where $Z$ is the set of unobserved (latent) topics (@hofmann1999probabilistic).

(@plsi-mixture) $$p(w,d)=\sum_{ z \in Z }^{  }{ p(z)p(d|z)p(w|z) } $$

However, while PLSI is a generative model for the corpus it is learned on, the documents used for learning are only treated as a set of individual labels. Therefore the PLSI model cannot directly be used to create probabilities for new documents (@blei2002latent).

The LDA model, in contrast, is a fully generative model. Therefore, the model can describe how a new document $d$ is generated from the model by the following process.

1. Draw a set of $k$ multinomial distributions from a dirichlet distribution ${\beta}_{k} \sim Dir(\eta )$
2. Draw the mixture of topics as a multinomial distribution for the document ${\theta}_{d}$ from a dirichlet distribution ${\theta}_{d} \sim Dir(\alpha )$
3. For every word in the document ${w}_{d,n}$
    1. Select a topic ${z}_{d,n}$ from the multinomial distribution of topics in the document ${\theta}_{d}$
    2. Select a word ${w}_{d,n}$ from the multinomial distribution ${\beta}_{{z}_{d,n}}$ in the topic ${z}_{d,n}$

Note that LDA uses a bag of words assumption for the documents, so the order of the generated words does not matter.

In the formal plate notation the generating process with $D$ documents, each containing $N$ words can be described by [Figure @fig:ldaplate] where each plate is the repeated draw of a value from the distribution.

![Plate notation of the LDA generative process. Based on Lee and Singh (2013)](source/figures/lda-plate.pdf "Plate notation of the LDA generative process"){#fig:ldaplate}

### Learning

The only observable entity in [Figure @fig:ldaplate] are the words ${w}_{d,n}$ of the documents. To find the latent topics $z$, the objective while learning an LDA model is to determine the parameters $\theta$ and $\beta$ for the distributions so that the model has a high probability to generate the documents in the training set. Therefore, the posterior probability needs to be estimated, given the Dirichlet priors and the likelihood based on the observations of words (@lda-posterior) which can be represented as the joint probability in ((@lda-joint) based on @darling2011theoretical).

(@lda-posterior) $$p(w,z,\beta ,\theta | \alpha ,\eta )$$
(@lda-joint) $$\prod _{ K }^{  }{ p(\beta_k|\eta) } \prod _{ D }^{  }{ p(\theta_d|\alpha) }\prod _{ N }^{  }{ p(z_{d,n}|\theta_d) p(w_{d,n}|\beta_{z_{d,n}}) }$$

One way to find the latent variables for the posterior probability is by using Gibbs sampling which is a Markov chain Monte Carlo algorithm (MCMC) (@geman1984stochastic).

@darling2011theoretical goes into great detail on how the posterior distribution can be inferred using Gibbs sampling. However, the practical algorithm follows the following scheme:

1. Assign each word ${w}_{d,n}$ with a randomly choosen topic $z \in \{ 1, \dots , K \}$
2. For each word ${w}_{d,n}$ in document $d$ in the corpus:
    1. Calculate $p(z|d)$, the probability that a word from $d$ is already assigned to $z$
    2. Calculate $p(w_{d,n}|z)$, the proportion of how often $w_{d,n}$ already appears in $z$
    3. Reassign the word to the topic $z$ where $\underset { z }{ argmax } (p(z|d)p(w_{d,n}|z))$

This algorithm can be repeated for several epochs.

This unsupervised process yields a model that describes every document $d$ as a mixture of $K$ abstract topics $z$. The representation of a document as a combination of abstract topics can be seen as a compression of the text. The mixture of topics can also be seen as a vector of length $K$. LDA can therefore be considered a document embedding (in contrast to the word embedding, word2vec) since it embeds each document in a $K$ dimensional vector space, in which documents with a similar mixture of topics have a small distance to one another. This vector space model can then be used to find documents that are about the same concrete topic by grouping documents with a similar mixture of abstract topics. In the next chapter, LDA is used to group related documents to reduce the workload of manually assigning a label to a document.
