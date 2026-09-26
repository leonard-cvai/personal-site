---
title: "Simple Prompt Tuning"
description: "How I quickly tune prompts."
date: 2026-09-25
draft: false
---

This is a general method that I use to quickly tune LLM prompts. It's great for when I'm working on a new problem and I need an optimized prompt quickly. It works by iteratively improving the prompt based on observed failure cases. Claude can run the loop autonomously from a high-level description. This post describes the loop, a worked example, and a few of the finer points of running the loop. 


## The loop

<picture>
  <source media="(max-width: 640px)" srcset="/images/prompt-tuning-loop-narrow.svg">
  <img src="/images/prompt-tuning-loop.svg" alt="The loop: 1. write the prompt, 2. run the prompt, 3. evaluate, 4. group the failures, then back to step 1. From step 3, if accuracy does not improve for 3 iterations, stop." width="770" height="310">
</picture>

1. **Write the prompt.** Start with a naive baseline prompt. Each iteration of the loop re-writes the prompt fix failure modes in the previous iteration.
2. **Run the prompt.** Run it on your dataset.
3. **Evaluate.** Calculate one metric, such as accuracy.
   - If 3 iterations in a row do not beat the best result, stop.
   - Use the best prompt so far, not the last prompt.
4. **Group the failures.** Group failures into themes; we will make edits to the prompt for each theme. Grouping helps to prevent overfitting on single failures.

I tell the agent to save each prompt version as a file. Each file has a `notes` field.
The notes say what the last version got wrong and what this version changes.
The notes make the history easy for me to review.

## Worked example: ChaosNLI

I recently used this loop to tune a Jev prompt for the αNLI task of the [ChaosNLI](https://github.com/easonnie/ChaosNLI) dataset. 
Each example is a short story with a beginning and an ending.
Two hypotheses describe what happened in the middle.
The task is to pick the more likely hypothesis.

Here is an example from the dataset:

> **Beginning:** Carl was walking down the street.<br>
> **Hypothesis 1:** Carl had a wallet full of money and a full tank of gas.<br>
> **Hypothesis 2:** Carl found a twenty and couldn't find who's it was.<br>
> **Ending:** Carl paid for gas with it.

The correct answer is Hypothesis 2. Only Hypothesis 2 explains what "it" refers to.

Below we will walk through the tuning process. We will show how the prompt and accuracy change with each iteration.


### Iteration 1: Baseline

<details class="prompt-diff not-prose">
<summary class="hdr"><svg class="chev" viewBox="0 0 16 16" width="16" height="16" aria-hidden="true"><path d="M6 3l5 5-5 5" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/></svg><span class="name">Prompt v01</span><span class="toggle"><span class="show">Show prompt</span><span class="hide">Hide prompt</span></span></summary>
<div class="ln label"><span></span><span>1</span><span class="sign"></span><span class="txt">Instructions:</span></div>
<div class="ln"><span></span><span>2</span><span class="sign"></span><span class="txt">Of the two hypotheses, is Hypothesis 1 the one more likely to cause Observation-Beginning to turn into Observation-Ending?</span></div>
<div class="ln label"><span></span><span>3</span><span class="sign"></span><span class="txt">Input format:</span></div>
<div class="ln"><span></span><span>4</span><span class="sign"></span><span class="txt">Plain text.</span></div>
</details>

**Result: 84.78% accuracy. New best, continue loop.**

Failure themes:

- Hypothesis 1 fits the beginning but does not cause the ending (49 false positives, 21 false negatives).
- Jev accepts garbled hypotheses, such as "Breakfast ate a lot at Sam."


### Iteration 2: Define Positive + Negative

<details class="prompt-diff not-prose">
<summary class="hdr"><svg class="chev" viewBox="0 0 16 16" width="16" height="16" aria-hidden="true"><path d="M6 3l5 5-5 5" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/></svg><span class="name">Prompt v01 → v02</span><span class="stat"><span class="plus">+10</span> <span class="minus">−0</span></span><span class="toggle"><span class="show">Show prompt</span><span class="hide">Hide prompt</span></span></summary>
<div class="ln label"><span>1</span><span>1</span><span class="sign"></span><span class="txt">Instructions:</span></div>
<div class="ln add"><span></span><span>2</span><span class="sign">+</span><span class="txt">This is an abductive reasoning task from a short everyday story.</span></div>
<div class="ln add"><span></span><span>3</span><span class="sign">+</span><span class="txt">Observation-Beginning is how the story starts and Observation-Ending is how it ends; something happened in between.</span></div>
<div class="ln add"><span></span><span>4</span><span class="sign">+</span><span class="txt">Two candidate hypotheses describe what happened in the middle.</span></div>
<div class="ln"><span>2</span><span>5</span><span class="sign"></span><span class="txt">Of the two hypotheses, is Hypothesis 1 the one more likely to cause Observation-Beginning to turn into Observation-Ending?</span></div>
<div class="ln add label"><span></span><span>6</span><span class="sign">+</span><span class="txt">Criteria (true):</span></div>
<div class="ln add"><span></span><span>7</span><span class="sign">+</span><span class="txt">Hypothesis 1 is the better explanation of the middle of the story: read in order (beginning, hypothesis, ending), it makes a more coherent and plausible story than Hypothesis 2.</span></div>
<div class="ln add"><span></span><span>8</span><span class="sign">+</span><span class="txt">It is consistent with both observations and leads naturally to the ending, accounting for its specific details (what 'it', 'them' or 'he' refers to, why a person feels or acts as they do at the end).</span></div>
<div class="ln add label"><span></span><span>9</span><span class="sign">+</span><span class="txt">Criteria (false):</span></div>
<div class="ln add"><span></span><span>10</span><span class="sign">+</span><span class="txt">Hypothesis 2 is the better explanation of the middle of the story.</span></div>
<div class="ln add"><span></span><span>11</span><span class="sign">+</span><span class="txt">Hypothesis 1 is worse if it contradicts either observation, only fits the beginning but does not lead to the ending, leaves the ending's specific details unexplained while Hypothesis 2 explains them, or is garbled, ungrammatical or nonsensical.</span></div>
<div class="ln add"><span></span><span>12</span><span class="sign">+</span><span class="txt">Judge both hypotheses the same way regardless of their order.</span></div>
<div class="ln label"><span>3</span><span>13</span><span class="sign"></span><span class="txt">Input format:</span></div>
<div class="ln"><span>4</span><span>14</span><span class="sign"></span><span class="txt">Plain text.</span></div>
</details>

**Result: 86.96% accuracy. New best, continue loop.**

Failure themes:

- The prompt still leans toward Hypothesis 1 (37 false positives, 23 false negatives).
- The question "is Hypothesis 1 the one…?" may cause a "yes" bias.


### Iteration 3: Test Positive Bias

<details class="prompt-diff not-prose">
<summary class="hdr"><svg class="chev" viewBox="0 0 16 16" width="16" height="16" aria-hidden="true"><path d="M6 3l5 5-5 5" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/></svg><span class="name">Prompt v02 → v03</span><span class="stat"><span class="plus">+7</span> <span class="minus">−6</span></span><span class="toggle"><span class="show">Show prompt</span><span class="hide">Hide prompt</span></span></summary>
<div class="ln label"><span>1</span><span>1</span><span class="sign"></span><span class="txt">Instructions:</span></div>
<div class="ln skip"><span>…</span><span>…</span><span class="sign"></span><span class="txt">…</span></div>
<div class="ln"><span>4</span><span>4</span><span class="sign"></span><span class="txt">Two candidate hypotheses describe what happened in the middle.</span></div>
<div class="ln del"><span>5</span><span></span><span class="sign">-</span><span class="txt">Of the two hypotheses, is Hypothesis 1 the one more likely to cause Observation-Beginning to turn into Observation-Ending?</span></div>
<div class="ln add"><span></span><span>5</span><span class="sign">+</span><span class="txt">Which of the two hypotheses is more likely to cause Observation-Beginning to turn into Observation-Ending?</span></div>
<div class="ln add"><span></span><span>6</span><span class="sign">+</span><span class="txt">Answer true for Hypothesis 1 and false for Hypothesis 2.</span></div>
<div class="ln add"><span></span><span>7</span><span class="sign">+</span><span class="txt">Judge both hypotheses by the same standard; their order means nothing.</span></div>
<div class="ln label"><span>6</span><span>8</span><span class="sign"></span><span class="txt">Criteria (true):</span></div>
<div class="ln del"><span>7</span><span></span><span class="sign">-</span><span class="txt">Hypothesis 1 is the better explanation of the middle of the story: read in order (beginning, hypothesis, ending), it makes a more coherent and plausible story than Hypothesis 2.</span></div>
<div class="ln del"><span>8</span><span></span><span class="sign">-</span><span class="txt">It is consistent with both observations and leads naturally to the ending, accounting for its specific details (what 'it', 'them' or 'he' refers to, why a person feels or acts as they do at the end).</span></div>
<div class="ln add"><span></span><span>9</span><span class="sign">+</span><span class="txt">Hypothesis 1 is the better middle: read in order (beginning, Hypothesis 1, ending) it makes a more coherent and plausible story than with Hypothesis 2.</span></div>
<div class="ln add"><span></span><span>10</span><span class="sign">+</span><span class="txt">It is consistent with both observations and leads to the ending, accounting for its specific details (what 'it', 'them' or 'he' refers to, why someone feels or acts as they do at the end), while Hypothesis 2 contradicts an observation, does not lead to the ending, leaves its details unexplained, or is garbled or nonsensical.</span></div>
<div class="ln label"><span>9</span><span>11</span><span class="sign"></span><span class="txt">Criteria (false):</span></div>
<div class="ln del"><span>10</span><span></span><span class="sign">-</span><span class="txt">Hypothesis 2 is the better explanation of the middle of the story.</span></div>
<div class="ln del"><span>11</span><span></span><span class="sign">-</span><span class="txt">Hypothesis 1 is worse if it contradicts either observation, only fits the beginning but does not lead to the ending, leaves the ending's specific details unexplained while Hypothesis 2 explains them, or is garbled, ungrammatical or nonsensical.</span></div>
<div class="ln del"><span>12</span><span></span><span class="sign">-</span><span class="txt">Judge both hypotheses the same way regardless of their order.</span></div>
<div class="ln add"><span></span><span>12</span><span class="sign">+</span><span class="txt">Hypothesis 2 is the better middle: read in order (beginning, Hypothesis 2, ending) it makes a more coherent and plausible story than with Hypothesis 1.</span></div>
<div class="ln add"><span></span><span>13</span><span class="sign">+</span><span class="txt">It is consistent with both observations and leads to the ending, accounting for its specific details (what 'it', 'them' or 'he' refers to, why someone feels or acts as they do at the end), while Hypothesis 1 contradicts an observation, does not lead to the ending, leaves its details unexplained, or is garbled or nonsensical.</span></div>
<div class="ln label"><span>13</span><span>14</span><span class="sign"></span><span class="txt">Input format:</span></div>
<div class="ln"><span>14</span><span>15</span><span class="sign"></span><span class="txt">Plain text.</span></div>
</details>

**Result: 86.96% accuracy. 1st loop with no new best.**

Failure themes:

- The neutral question in v03 moved failures from false negatives to false positives. So the lean is not a "yes" bias.
- Hypothesis 1 is compatible with the story, but Hypothesis 2 causes the ending.


### Iteration 4: Work Backwards

Because iteration 3 did not yield a new best, we use the prompt from iteration 2 as our starting point.

<details class="prompt-diff not-prose">
<summary class="hdr"><svg class="chev" viewBox="0 0 16 16" width="16" height="16" aria-hidden="true"><path d="M6 3l5 5-5 5" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/></svg><span class="name">Prompt v02 → v04</span><span class="stat"><span class="plus">+4</span> <span class="minus">−3</span></span><span class="toggle"><span class="show">Show prompt</span><span class="hide">Hide prompt</span></span></summary>
<div class="ln label"><span>1</span><span>1</span><span class="sign"></span><span class="txt">Instructions:</span></div>
<div class="ln skip"><span>…</span><span>…</span><span class="sign"></span><span class="txt">…</span></div>
<div class="ln"><span>4</span><span>4</span><span class="sign"></span><span class="txt">Two candidate hypotheses describe what happened in the middle.</span></div>
<div class="ln add"><span></span><span>5</span><span class="sign">+</span><span class="txt">Work backwards from the ending: first identify what in Observation-Ending needs explaining (a change from the beginning, an outcome, a feeling or decision, an object or person it refers to), then ask which hypothesis supplies the cause of that.</span></div>
<div class="ln"><span>5</span><span>6</span><span class="sign"></span><span class="txt">Of the two hypotheses, is Hypothesis 1 the one more likely to cause Observation-Beginning to turn into Observation-Ending?</span></div>
<div class="ln label"><span>6</span><span>7</span><span class="sign"></span><span class="txt">Criteria (true):</span></div>
<div class="ln del"><span>7</span><span></span><span class="sign">-</span><span class="txt">Hypothesis 1 is the better explanation of the middle of the story: read in order (beginning, hypothesis, ending), it makes a more coherent and plausible story than Hypothesis 2.</span></div>
<div class="ln del"><span>8</span><span></span><span class="sign">-</span><span class="txt">It is consistent with both observations and leads naturally to the ending, accounting for its specific details (what 'it', 'them' or 'he' refers to, why a person feels or acts as they do at the end).</span></div>
<div class="ln add"><span></span><span>8</span><span class="sign">+</span><span class="txt">Hypothesis 1 is the better explanation of the middle of the story: it supplies the cause of what Observation-Ending describes, so that beginning, Hypothesis 1 and ending read as one coherent, plausible story, more so than with Hypothesis 2.</span></div>
<div class="ln add"><span></span><span>9</span><span class="sign">+</span><span class="txt">It is consistent with both observations and accounts for the ending's specific details.</span></div>
<div class="ln label"><span>9</span><span>10</span><span class="sign"></span><span class="txt">Criteria (false):</span></div>
<div class="ln"><span>10</span><span>11</span><span class="sign"></span><span class="txt">Hypothesis 2 is the better explanation of the middle of the story.</span></div>
<div class="ln del"><span>11</span><span></span><span class="sign">-</span><span class="txt">Hypothesis 1 is worse if it contradicts either observation, only fits the beginning but does not lead to the ending, leaves the ending's specific details unexplained while Hypothesis 2 explains them, or is garbled, ungrammatical or nonsensical.</span></div>
<div class="ln add"><span></span><span>12</span><span class="sign">+</span><span class="txt">Hypothesis 1 is worse if it is merely compatible with the story but does not cause the ending while Hypothesis 2 does, if it contradicts either observation, if it leaves the ending's specific details unexplained while Hypothesis 2 explains them, or if it is garbled, ungrammatical or nonsensical.</span></div>
<div class="ln"><span>12</span><span>13</span><span class="sign"></span><span class="txt">Judge both hypotheses the same way regardless of their order.</span></div>
<div class="ln label"><span>13</span><span>14</span><span class="sign"></span><span class="txt">Input format:</span></div>
<div class="ln"><span>14</span><span>15</span><span class="sign"></span><span class="txt">Plain text.</span></div>
</details>

**Result: 88.70% accuracy. New best, continue loop.**

Failure theme: Hypothesis 2 links the two observations, but Hypothesis 1 relates to only one of them.


### Iterations 5-7: no new best

All three versions start from v04.

**Iteration 5.**

<details class="prompt-diff not-prose">
<summary class="hdr"><svg class="chev" viewBox="0 0 16 16" width="16" height="16" aria-hidden="true"><path d="M6 3l5 5-5 5" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/></svg><span class="name">Prompt v04 → v05</span><span class="stat"><span class="plus">+2</span> <span class="minus">−0</span></span><span class="toggle"><span class="show">Show prompt</span><span class="hide">Hide prompt</span></span></summary>
<div class="ln label"><span>1</span><span>1</span><span class="sign"></span><span class="txt">Instructions:</span></div>
<div class="ln skip"><span>…</span><span>…</span><span class="sign"></span><span class="txt">…</span></div>
<div class="ln label"><span>7</span><span>7</span><span class="sign"></span><span class="txt">Criteria (true):</span></div>
<div class="ln skip"><span>…</span><span>…</span><span class="sign"></span><span class="txt">…</span></div>
<div class="ln add"><span></span><span>10</span><span class="sign">+</span><span class="txt">When both hypotheses could work, the better one is the one that links the two observations to each other, using a detail of the beginning to produce the ending (a habit that leads to the outcome, an item found that the ending then refers to), rather than one that only relates to one of them.</span></div>
<div class="ln label"><span>10</span><span>11</span><span class="sign"></span><span class="txt">Criteria (false):</span></div>
<div class="ln skip"><span>…</span><span>…</span><span class="sign"></span><span class="txt">…</span></div>
<div class="ln add"><span></span><span>14</span><span class="sign">+</span><span class="txt">Hypothesis 1 also loses when both could work but Hypothesis 2 links the two observations to each other and Hypothesis 1 only relates to one of them, or when Hypothesis 1 is vaguer and Hypothesis 2 spells out the chain of events.</span></div>
<div class="ln"><span>13</span><span>15</span><span class="sign"></span><span class="txt">Judge both hypotheses the same way regardless of their order.</span></div>
<div class="ln label"><span>14</span><span>16</span><span class="sign"></span><span class="txt">Input format:</span></div>
<div class="ln"><span>15</span><span>17</span><span class="sign"></span><span class="txt">Plain text.</span></div>
</details>

**Result: 87.61% accuracy. 1st loop with no new best.**

Failure theme : the remaining failures sit close to a probability of 0.5.

**Iteration 6.**

<details class="prompt-diff not-prose">
<summary class="hdr"><svg class="chev" viewBox="0 0 16 16" width="16" height="16" aria-hidden="true"><path d="M6 3l5 5-5 5" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/></svg><span class="name">Prompt v04 → v06</span><span class="stat"><span class="plus">+1</span> <span class="minus">−1</span></span><span class="toggle"><span class="show">Show prompt</span><span class="hide">Hide prompt</span></span></summary>
<div class="ln label"><span>1</span><span>1</span><span class="sign"></span><span class="txt">Instructions:</span></div>
<div class="ln skip"><span>…</span><span>…</span><span class="sign"></span><span class="txt">…</span></div>
<div class="ln label"><span>7</span><span>7</span><span class="sign"></span><span class="txt">Criteria (true):</span></div>
<div class="ln skip"><span>…</span><span>…</span><span class="sign"></span><span class="txt">…</span></div>
<div class="ln label"><span>10</span><span>10</span><span class="sign"></span><span class="txt">Criteria (false):</span></div>
<div class="ln skip"><span>…</span><span>…</span><span class="sign"></span><span class="txt">…</span></div>
<div class="ln label"><span>14</span><span>14</span><span class="sign"></span><span class="txt">Input format:</span></div>
<div class="ln del"><span>15</span><span></span><span class="sign">-</span><span class="txt">Plain text.</span></div>
<div class="ln add"><span></span><span>15</span><span class="sign">+</span><span class="txt">JSON object.</span></div>
</details>

**Result: 87.39% accuracy. 2nd loop with no new best.**

Failure theme in last iteration: the same as in v05.

**Iteration 7.** 

<details class="prompt-diff not-prose">
<summary class="hdr"><svg class="chev" viewBox="0 0 16 16" width="16" height="16" aria-hidden="true"><path d="M6 3l5 5-5 5" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/></svg><span class="name">Prompt v04 → v07</span><span class="stat"><span class="plus">+2</span> <span class="minus">−1</span></span><span class="toggle"><span class="show">Show prompt</span><span class="hide">Hide prompt</span></span></summary>
<div class="ln label"><span>1</span><span>1</span><span class="sign"></span><span class="txt">Instructions:</span></div>
<div class="ln skip"><span>…</span><span>…</span><span class="sign"></span><span class="txt">…</span></div>
<div class="ln del"><span>4</span><span></span><span class="sign">-</span><span class="txt">Two candidate hypotheses describe what happened in the middle.</span></div>
<div class="ln add"><span></span><span>4</span><span class="sign">+</span><span class="txt">Two candidate hypotheses describe what happened in the middle, both written by crowd workers: one was written as the real middle of the story, and the other was typically made by editing a plausible middle so that it no longer leads to the ending (for example by changing or negating a detail), so it can look reasonable on its own.</span></div>
<div class="ln add"><span></span><span>5</span><span class="sign">+</span><span class="txt">Stories and hypotheses may contain typos.</span></div>
<div class="ln skip"><span>…</span><span>…</span><span class="sign"></span><span class="txt">…</span></div>
<div class="ln label"><span>7</span><span>8</span><span class="sign"></span><span class="txt">Criteria (true):</span></div>
<div class="ln skip"><span>…</span><span>…</span><span class="sign"></span><span class="txt">…</span></div>
<div class="ln label"><span>10</span><span>11</span><span class="sign"></span><span class="txt">Criteria (false):</span></div>
<div class="ln skip"><span>…</span><span>…</span><span class="sign"></span><span class="txt">…</span></div>
<div class="ln label"><span>14</span><span>15</span><span class="sign"></span><span class="txt">Input format:</span></div>
<div class="ln"><span>15</span><span>16</span><span class="sign"></span><span class="txt">Plain text.</span></div>
</details>

**Result: 87.83% accuracy. 3rd loop with no new best.**

**Final prompt: Iteration 4. Test accuracy: 87.75%.**

## Finer points

### Use train, val and test splits

Although we're not training the model itself, it's still helpful to split the dataset:

- **Train:** We use this data for the run/evaluate steps of the loop.
- **[Optional] Val:** If it's important to have calibrated outputs (e.g. Jev scores), I use this split to calibrate probabilities. Not every use case needs this.
- **Test:** Get an estimate of how the prompt performs on unseen data.


### Optimizing multiple metrics

You can optimize for multiple objectives (e.g. response accuracy and grounding quality), but you will want to relax the stopping criteria. If you require regressions on all metrics over consecutive iterations you can get see-sawing as the prompt trades off between the objectives. This can seriously extend tuning time
