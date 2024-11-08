# -*- coding: utf-8 -*-
# !git clone https://github.com/SDM-TIB/KOSMOS.git
#
# ! pip install -r /content/KOSMOS/requirements.txt

from pykeen.pipeline import pipeline, plot_losses
import numpy as np
import pandas as pd
from pykeen import predict
from pykeen.triples import TriplesFactory
from matplotlib import pyplot as plt
from typing import List
import pykeen.nn
import torch
import json
import os.path
import logging

# Load benchmark KGs
def load_dataset(name):
    triple_data = open(name, encoding='utf-8').read().strip()
    data = np.array([triple.split('\t') for triple in triple_data.split('\n')])
    tf_data = TriplesFactory.from_labeled_triples(triples=data)
    entity_label =tf_data.entity_to_id.keys()
    relation_label = tf_data.relation_to_id.keys()
    return tf_data, triple_data, entity_label, relation_label

# Train KGE models with required hyperparameters
def create_model(tf_training, tf_testing, embedding, n_epoch, path):
    results = pipeline(
        training=tf_training,
        testing=tf_testing,
        model=embedding,
        training_loop='sLCWA',
        model_kwargs=dict(embedding_dim=200),
        negative_sampler_kwargs= dict(filtered=True,
                                      ),
        # Training configuration
        training_kwargs=dict(
            num_epochs=n_epoch,
            use_tqdm_batch=False,
        ),
        # Runtime configuration
        random_seed=1235,
    )
    model = results.model
    results.save_to_directory(path +'/'+ embedding) #save results to the directory
    return model, results

# Plotting observed losses per KGE model
def plotting(result,m, results_path):
        plot_losses(result)
        plt.savefig(results_path + m + "/loss_plot.png", dpi=300)

def initialize(input_config):
    with open(input_config, "r") as input_file_descriptor:
        input_data = json.load(input_file_descriptor)
    KG = './'+ input_data['Type']+'/'+input_data['KG']
    models = input_data['model']
    results_path = input_data['path_to_results']
    return KG, models, results_path

if __name__ == '__main__':
    input_config = 'input.json'

    # Reading input.json file to collect input configuration for executing symbolic learning
    KG, models, results_path = initialize(input_config)
    print(models)
    tf, triple_data, entity_label, relation_label = load_dataset(KG)
    # Split them into train, test
    training, testing = tf.split(random_state=1234)
    training_triples = pd.DataFrame(training.triples, columns=['Head', 'Relation', 'Tail'])
    training_triples.to_csv(KG + 'training_triples.csv', index=False, sep = '\t')

    testing_triples = pd.DataFrame(testing.triples, columns=['Head', 'Relation', 'Tail'])
    testing_triples.to_csv(KG + 'testing_triples.csv', index=False, sep = '\t')

    # Start training and evaluating KGE models
    for m in models:
        model, result = create_model(tf_training=training, tf_testing=testing, embedding=m, n_epoch=100, path= results_path)
        plotting(result,m, results_path)

