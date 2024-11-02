# Symbolic Learning over Ontology

The process of inductive learning about KGs includes a range of methods for acquiring knowledge inside KGs
that will aid in their completion. Inductive learning is a crucial aspect of identifying missing relationships
in KGs because it requires deducing patterns and correlations from the existing KG. Using existing
approaches, it is possible to learn symbolic or numerical representations of KGs that match to the
essential building blocks for inferring missing links, allowing for effective KG completion.

Symbolic learning generates logical rules based on the input KG.
The learnt edges serve as previous information, which improves numerical learning methods like KGE models.
During symbolic learning, KOSMOS employs extracted horn rules in conjunction with PCA Confidence.
The mined rules are then used to make predictions for the missing relationships in the input KG.
These predictions are based on logical inference, which is utilized to determine the implication of the
mined rules. SPARQL queries are used to determine the entailment of mining rules.

To mine the horn rules over ontology follow the below given steps:

```prolog
?- get_paths_and_write_closed_rules(['hasBiomarker', 'patientDrug'], Paths, Rules, 3, 'MinedRules.txt').
```
