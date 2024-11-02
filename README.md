[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
# KOSMOS: Knowledge Oriented Symbolic learning for Medical Ontology-based decision System

The KOSMOS framework uses a hybrid approach that combines symbolic and numerical learning methods to
identify patterns that indicate novel correlations between medical items. This method combines the
semantics of symbolic systems, such as ontologies, with numerical learning models like KGE.
By combining domain knowledge, KOSMOS improves downstream tasks such as link prediction,
numerical model performance, and KG completion efficiency. KOSMOS uses domain knowledge to direct the
search space during mining, resulting in efficient recovery of significant patterns.
In this context, domain knowledge refers to the ontological structure and relationships of a KG.
Using semantic context, KOSMOS can identify patterns that are both statistically significant
and relevant to the healthcare domain.

![KOSMOS](https://raw.githubusercontent.com/SDM-TIB/KOSMOS/main/images/MotivatingExample-WSDM25.png "KOSMOS")

## Getting started
Clone the repository
```git
git clone git@github.com:SDM-TIB/KOSMOS.git
```

## Install Prerequistes
Execute the following command
```python
pip install -r requirements.txt
```
Executing scripts to reproduce KGE results by choosing ``Baseline`` or ``KOSMOS`` folders and navigating to appropriate path. KOSMOS utilizes the implementation of PyKEEN [1] framework for training embedding models, i.e., TransE [2], TransD [3] and TransH [4]. Here, the models are trained with default hyperparameter settings.

Provide configuration for executing
```json
{
  "Type": "Baseline1",
  "KG": "benchmarks/Baseline1/baseline1.nt",
  "model": ["TransE", "TransH","TransD"],
  "path_to_results": "./Results/Baseline1/"
}
```
The user must provide a few options in the above JSON file to select the type of approach that has to be executed with added configuration details. <br>
The parameter ``Type`` corresponds to the type of execution, i.e., ```Baseline1``` or ```KOSMOS```.<br>
Secondly, parameter ``KG`` is the type of knowledge graph, i.e., ```Baseline1``` or ```Baseline2``` or ```KOSMOS```.<br>
Nextly,```model```parameter is used for training the KGE model to generate results for readability.<br>
Lastly, ```path_to_results``` is parameter given by user to store the trained model results.

```python
python kge_kosmos.py 
```
`Note: KGE models are trained in Python 3.9 and executed in a virtual machine on Google Colab with 40 GiB VRAM and 1
GPU NVIDIA A100 SMX-4, with CUDA Version 12.2 (Driver 525.104.05) and PyTorch (v2.0.1).`

To execute symbolic learning component, navigate to folder `Symbolic Learning` follow the instructions. The symbolic component for baseline2 utilizes the hybrid framework proposed in [5].


**References**

[1] Mehdi Ali, Max Berrendorf, Charles Tapley Hoyt, Laurent Vermue, Sahand Sharifzadeh, Volker Tresp, and Jens Lehmann. 2021. PyKEEN 1.0: A Python Library for Training and Evaluating Knowledge Graph Embeddings. Journal of Machine Learning Research (2021). http://jmlr.org/papers/v22/20-825.html

[2] Antoine Bordes, Nicolas Usunier, Alberto Garcia-Durán, Jason Weston, and Oksana Yakhnenko. 2013. Translating Embeddings for Modeling Multi-Relational Data (NIPS’13). Curran Associates Inc., Red Hook, NY, USA, 2787–2795.

[3] Guoliang Ji, Shizhu He, Liheng Xu, Kang Liu, and Jun Zhao. 2015. Knowledge graph embedding via dynamic mapping matrix. In Proceedings of the 53rd annual meeting of the association for computational linguistics and the 7th international joint conference on natural language processing (volume 1: Long papers). 687–696. https://doi.org/10.3115/v1/P15-1067

[4] Zhen Wang, Jianwen Zhang, Jianlin Feng, and Zheng Chen. 2014. Knowledge Graph Embedding by Translating on Hyperplanes. Proceedings of the AAAI Conference on Artificial Intelligence 28, 1 (2014). https://doi.org/10.1609/aaai. 

[5] Disha Purohit, Yashrajsinh Chudasama, Ariam Rivas, and Maria-Esther Vidal. 2023. SPaRKLE: Symbolic caPtuRing of knowledge for Knowledge graph enrichment with LEarning. In Proceedings of the 12th Knowledge Capture Conference 2023 (Pensacola, FL, USA) (K-CAP ’23). Association for Computing Machinery, New York, NY, USA, 44–52. https://doi.org/10.1145/3587259.3627547


## License
This work is licensed under the MIT license.
