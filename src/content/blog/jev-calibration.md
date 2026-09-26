---
title: "Is Jev Calibrated?"
description: "Evaluating Jev's calibration on two hard datasets."
date: 2026-09-26
draft: false
---

Jev answers a yes/no question about a text with a probability. A model is calibrated when these probabilities match reality. A recent post, ["Jev can't be calibrated"](https://www.alexmolas.com/2026/09/23/jev-cant-be-calibrated.html), claimed that Jev can't be calibrated on every dataset. I tested that on 2 wildly different real datasets and found Jev is approximately calibrated on both. To accomplish this, I tuned a Jev prompt for each dataset, scored a held-out test set, and compared each score with the real outcome. This post describes the datasets, the method, and the results.


## The datasets

### Word-in-Context (WiC)

Each example is a target word and two sentences. The task is to decide if the word has the same meaning in both sentences. For example, the dataset labels "degree" in "He earned his degree at Princeton" and "Water boils at 100 degrees Celsius" as two different meanings.

This is a difficult NLP problem. The tuned prompt gets 79.97% accuracy on the test set of 3,066 pairs. The scores should represent the model's confidence in its answer.

### ChaosNLI

We used the αNLI part of [ChaosNLI](https://github.com/easonnie/ChaosNLI). Each example is a short story with a beginning, an ending and two hypotheses for the middle. The task is to pick the more likely hypothesis. 100 people labeled each story. They do not always agree: on 14% of test stories, the vote falls between 30/70 and 70/30.

This dataset is best aligned with Jev's claim to be calibrated to human responses, because there is genuine disagreement among humans. The tuned prompt gets 87.75%  on the test set of 612 stories.


## Methodology

### Tune the Jev prompt

First, we tune the Jev prompt to our use case. This step is critical. Without tuning, the Jev probability will have no bearing on your ground truth. To take an absurd example, imagine your Jev prompt is "Is the sentiment of this paragraph positive?", but your ground truth is "Does this paragraph mention a hotdog?". There is no way that the Jev probability will reflect the true probability. We used the loop from my [Simple Prompt Tuning](/blog/prompt-tuning-loop/) post. 

### Calibration analysis

We score each example in the test set and sort the scores into 10 bins: 0.0–0.1, 0.1–0.2, and so on. In each bin, we compare Jev's average score with the actual rate:

- **WiC:** the share of pairs where the word has the same meaning.
- **ChaosNLI:** the average share of the 100 annotators who chose Hypothesis 1.

We measure the calibration error (ECE), which is the average gap across the bins, weighted by the number of examples in each bin. An ECE of 0 is perfect.


## Results

In each chart, the blue dot is Jev's average score in the bin, and the white dot is the actual rate. A short line between them means good calibration. The gray bar shows the range that sampling error alone can explain (95%).

### Word-in-Context

<picture>
  <source media="(max-width: 640px)" srcset="/images/jev-calibration-wic-narrow.svg">
  <img src="/images/jev-calibration-wic.svg" alt="Word-in-Context: Jev's average score vs the share of pairs with the same meaning, for each score bin. 0.0–0.1: 306 pairs, 6.9% vs 2.9%. 0.1–0.2: 516 pairs, 13.9% vs 8.3%. 0.2–0.3: 255 pairs, 24.5% vs 22.0%. 0.3–0.4: 199 pairs, 34.4% vs 38.7%. 0.4–0.5: 203 pairs, 44.5% vs 46.8%. 0.5–0.6: 216 pairs, 54.5% vs 54.6%. 0.6–0.7: 277 pairs, 64.7% vs 65.3%. 0.7–0.8: 317 pairs, 75.0% vs 76.7%. 0.8–0.9: 457 pairs, 84.6% vs 88.6%. 0.9–1.0: 320 pairs, 92.5% vs 95.6%." width="760" height="538">
</picture>

Jev's calibration is solid on this dataset. The ECE is 0.027. No bin is off by more than 5.5 percentage points. Almost every bin is within the sampling error bars.

### ChaosNLI

<picture>
  <source media="(max-width: 640px)" srcset="/images/jev-calibration-chaosnli-narrow.svg">
  <img src="/images/jev-calibration-chaosnli.svg" alt="ChaosNLI: Jev's average score vs the average share of 100 annotators who chose Hypothesis 1, for each score bin. 0.0–0.1: 110 stories, 6.4% vs 3.8%. 0.1–0.2: 85 stories, 13.7% vs 9.7%. 0.2–0.3: 43 stories, 23.7% vs 30.4%. 0.3–0.4: 32 stories, 33.8% vs 37.9%. 0.4–0.5: 26 stories, 46.3% vs 42.3%. 0.5–0.6: 30 stories, 54.0% vs 49.7%. 0.6–0.7: 43 stories, 64.1% vs 64.0%. 0.7–0.8: 49 stories, 74.5% vs 75.2%. 0.8–0.9: 85 stories, 85.2% vs 84.9%. 0.9–1.0: 109 stories, 93.2% vs 94.9%." width="760" height="538">
</picture>

Jev's scores fit the share of human annotators closely. The ECE against the crowd is 0.025. From 0.6 up, the crowd's share is within 1.8 points of Jev's score in every bin. 

On both datasets, the middle bins have the fewest examples. Their gaps are all within 1.5 standard errors, so sampling error can explain them. 


## Conclusion

Fundamentally, "is Jev calibrated" means "can I use Jev's scores as probabilites". Based on this analysis, the answer is "probably yes" depending on your use case. Jev's scores are generally well matched to the true probability, with some slight divergence in the top and bottom bins. 

### Use Case 1

If you're using Jev to triage tickets between the Platform and Infrastructure team, and you want to escalate borderline tickets to human review, Jev is well calibrated. For all the middle bins (0.2-0.8), the Jev's score falls well within the standard error bars of the true probability. You can safely escalate tickets with borderline scores without wasting the human reviewer's time.

### Use Case 2

If you are using Jev to classify content violations, and you are using Jev's scores to ban users with high confidence violating posts, then Jev's calibration might too loose for comfort. For example if you ban any user with a post scoring **>0.95**, you will have a larger number of false negatives relative to the true probability. This is because in the top bins Jev lowballs the true probability. Jev's scores are less well suited to high-stakes, high-sensitivity, and high-confidence use cases.
