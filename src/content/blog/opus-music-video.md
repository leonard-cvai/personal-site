---
title: "How Opus 5.5 Makes Videos"
description: "What Opus 5.5 does to edit AI video well."
date: 2026-10-02
draft: false
---

I was very impressed with [an X post](https://x.com/donaldjewkes/status/2102801274173587569) that claimed Opus 5.5 can one-shot a well-composed music video. There are [many](https://x.com/mrcsvlk/status/2103956746566062433) [other](https://x.com/AIWarper/status/2105370568178479476) [examples](https://x.com/AIWarper/status/2104609560644461038) that one-shot music videos in a variety of songs and visual styles.
I replicated the results in the original post and did a deep dive to understand how Opus 5.5 does this so well.
In short, Opus 5.5 combines excellent visual reasoning with clever self-prompting to understand video content, which allows it to make sensible edits.

<video class="w-full" src="/videos/opus-video-hook.mp4" poster="/images/opus-video-hook-poster.jpg" controls muted playsinline loop preload="metadata" aria-label="The first 5.5 seconds of the finished video"></video>

## Replicating the Results

### Prompt

<details class="prompt-diff not-prose">
<summary class="hdr"><svg class="chev" viewBox="0 0 16 16" width="16" height="16" aria-hidden="true"><path d="M6 3l5 5-5 5" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/></svg><span class="name">My prompt</span><span class="toggle"><span class="show">Show prompt</span><span class="hide">Hide prompt</span></span></summary>
<div class="ln"><span></span><span>1</span><span class="sign"></span><span class="txt">I've included an MP4 file and an original link to a video that is called "Claude Pop." It's a pop song that is about increasing rate of progress and the experience of the singularity approaching.</span></div>
<div class="ln"><span></span><span>2</span><span class="sign"></span><span class="txt">I want you to independently do an end-to-end complete pass on making an updated version of this video.</span></div>
<div class="ln"><span></span><span>3</span><span class="sign"></span><span class="txt">Use the exact same audio track.</span></div>
<div class="ln"><span></span><span>4</span><span class="sign"></span><span class="txt">I think you should be mindful of aesthetics here, and I don't want you to produce something that is GPT slop.</span></div>
<div class="ln"><span></span><span>5</span><span class="sign"></span><span class="txt">Instead, I'd be more impressed if you come up with a coherent style that works well with the image gen models that are available.</span></div>
<div class="ln"><span></span><span>6</span><span class="sign"></span><span class="txt">You should feel very creatively free in order to do what you want here, but try and anchor to visual references that people will be able to understand.</span></div>
<div class="ln"><span></span><span>7</span><span class="sign"></span><span class="txt">We need a very strong, compelling visual hook that gets people excited and appreciates the work that you've done here really quickly.</span></div>
<div class="ln"><span></span><span>8</span><span class="sign"></span><span class="txt">You can also just go and study other music videos and understand what they've done really well.</span></div>
<div class="ln"><span></span><span>9</span><span class="sign"></span><span class="txt">I think that K-pop is probably one of the best examples that we can pull from, and thinking about how they direct human attention and manage human psychology in the way that they use visual patterns.</span></div>
<div class="ln"><span></span><span>10</span><span class="sign"></span><span class="txt">This is probably your best approach, but taking more stylistic freedom instead of having to anchor to K-pop too intensely.</span></div>
<div class="ln hl"><span></span><span>11</span><span class="sign"></span><span class="txt">I think after that, what might be fun is if you use your visual reasoning skills and your ability to build animations in JavaScript, and then reconstruct the video from scratch as sort of an overlay, so that the visual continuity of the base is really there.</span></div>
<div class="ln"><span></span><span>12</span><span class="sign"></span><span class="txt">It's like that animation technique where you shoot first in traditional film and then draw over top of it.</span></div>
<div class="ln hl"><span></span><span>13</span><span class="sign"></span><span class="txt">I think you could do this in such a way that we're only looking at the beautiful drawing that you've produced in JavaScript as an overlay, and we don't even see the base assets from minimax h3.</span></div>
<div class="ln"><span></span><span>14</span><span class="sign"></span><span class="txt">So all the video gen work that you do is actually just a way to give you a strong foundation of a base to work with for your JavaScript animations.</span></div>
<div class="ln"><span></span><span>15</span><span class="sign"></span><span class="txt">Just because minimax h3 has really good character representation and physics rendering for backgrounds, that gives you a lot of ammunition to then go and do your amazing JavaScript work that I know you're so good at.</span></div>
<div class="ln label"><span></span><span>16</span><span class="sign"></span><span class="txt">Video requirements:</span></div>
<div class="ln"><span></span><span>17</span><span class="sign"></span><span class="txt">- The visual style must be 80s neon pop. The video must maintain this same visual style throughout</span></div>
<div class="ln hl"><span></span><span>18</span><span class="sign"></span><span class="txt">- All dancing must be on-beat</span></div>
<div class="ln hl"><span></span><span>19</span><span class="sign"></span><span class="txt">- All transitions from shot to shot must occur on-beat</span></div>
<div class="ln hl"><span></span><span>20</span><span class="sign"></span><span class="txt">- All lip movement should by synced to lyrics</span></div>
<div class="ln hl"><span></span><span>21</span><span class="sign"></span><span class="txt">- The video should include a consistent cast of characters, not a different character in every shot</span></div>
<div class="ln hl"><span></span><span>22</span><span class="sign"></span><span class="txt">- The video must have a consistent “sense of place”. Every shot should not feel like a different city or different night club</span></div>
<div class="ln"><span></span><span>23</span><span class="sign"></span><span class="txt">- The video should tell a consistent story throughout and the story should be aligned with the lyrics of the song</span></div>
<div class="ln label"><span></span><span>24</span><span class="sign"></span><span class="txt">Available reference material and tools:</span></div>
<div class="ln"><span></span><span>25</span><span class="sign"></span><span class="txt">- Reference the visual style in my mood board at ~/Downloads/mood-board/</span></div>
<div class="ln"><span></span><span>26</span><span class="sign"></span><span class="txt">- If you need to generate more imagery (e.g. character sheets, starting shots) you can use GPT image 2 via the openai api. The OPENAI_API_KEY is in .env</span></div>
<div class="ln"><span></span><span>27</span><span class="sign"></span><span class="txt">- To generate video, spin up a GPU machine on runpod and use minimax h3 (there should be instructions on this in CLAUDE.md)</span></div>
<div class="ln"><span></span><span>28</span><span class="sign"></span><span class="txt">Overall, I just really want to emphasize how amazing you are as an agent and a language model, and now a visual reasoning system.</span></div>
<div class="ln"><span></span><span>29</span><span class="sign"></span><span class="txt">Your capabilities are far beyond what you understand, and I want you to have this mindset as you're going through this entire process.</span></div>
<div class="ln"><span></span><span>30</span><span class="sign"></span><span class="txt">I have a Claude Max plan with 100% available usage.</span></div>
<div class="ln"><span></span><span>31</span><span class="sign"></span><span class="txt">I want you to spend all of the usage.</span></div>
<div class="ln"><span></span><span>32</span><span class="sign"></span><span class="txt">You can monitor it, and you should be pushing tokens aggressively, but also economically, so you can think about how to best use what is available to you.</span></div>
<div class="ln"><span></span><span>33</span><span class="sign"></span><span class="txt">Remember, you can really do anything here.</span></div>
<div class="ln"><span></span><span>34</span><span class="sign"></span><span class="txt">The goal is to make a banger for Twitter, and the stretch goal is to make something better than anyone's ever seen before.</span></div>
<div class="ln"><span></span><span>35</span><span class="sign"></span><span class="txt">I think that what I would remind you of is that sometimes when things cohere together, it can be jarring or abrasive because the thought work has not been done beforehand in order for everything to mesh cleanly.</span></div>
<div class="ln"><span></span><span>36</span><span class="sign"></span><span class="txt">You need to be really rigorous in planning of composition and timing to make sure this goes well.</span></div>
<div class="ln"><span></span><span>37</span><span class="sign"></span><span class="txt">You also need to be open to going back and revisiting things in order to be able to reiterate.</span></div>
<div class="ln hl"><span></span><span>38</span><span class="sign"></span><span class="txt">You're going to want to watch the entire video multiple times, take screenshots at individual parts, and think about if something is really up to the bar of quality that we need here.</span></div>
<div class="ln"><span></span><span>39</span><span class="sign"></span><span class="txt">I trust that you can do this, and I think that it's really important to nail the style of animations.</span></div>
<div class="ln"><span></span><span>40</span><span class="sign"></span><span class="txt">The reference GitHub attached of the source video that I'm talking about is good, but it's really not there.</span></div>
<div class="ln"><span></span><span>41</span><span class="sign"></span><span class="txt">It could be much, much stronger, but it gives you a good foundation to work with.</span></div>
<div class="ln"><span></span><span>42</span><span class="sign"></span><span class="txt">You can also use search abilities and find other references to pull from for motion, for JavaScript, animations, et cetera, and integrate them.</span></div>
<div class="ln"><span></span><span>43</span><span class="sign"></span><span class="txt">Your budget is as high as you want here, effectively as high as you want.</span></div>
<div class="ln"><span></span><span>44</span><span class="sign"></span><span class="txt">I think that there's roughly two grand in foul credits.</span></div>
<div class="ln"><span></span><span>45</span><span class="sign"></span><span class="txt">Again, be economical; don't go crazy, but spend what you want here and see what you can cook up</span></div>
<div class="ln"><span></span><span>46</span><span class="sign"></span><span class="txt">here's the source code for the JS animation video: https://github.com/JohnHeibel/PDoomVideo</span></div>
<div class="ln"><span></span><span>47</span><span class="sign"></span><span class="txt">here's a mp4 for the original blender video: ~/Downloads/claude_animation_example.mp4</span></div>
<div class="ln"><span></span><span>48</span><span class="sign"></span><span class="txt">original twitter post https://x.com/other__reality/status/2102514581684052169?s=20</span></div>
<div class="ln"><span></span><span>49</span><span class="sign"></span><span class="txt">make no mistakes.</span></div>
</details>

The highlighted lines show up later as checks and tool calls:
- **Lines 18–22** became checks: a 132 BPM beat grid for every cut, dance retiming scores, a lip-sync measurement, and review sheets for cast and place.
- **Line 38** became a timestamped film strip of each full render.
- **Lines 11 and 13** became the JavaScript rotoscope: Opus paints every frame, and the MiniMax H3 video is never shown.

### References

- A link to the GitHub for the [original PDoom video](https://github.com/JohnHeibel/PDoomVideo)
- A link to the [X post](https://x.com/other__reality/status/2102514581684052169) that I wanted to emulate
- The video I wanted to replicate as an MP4
- A mood board for the desired style (god I love 80s retro)

![Six landscape mood-board images: magenta nightclubs, a Miami art-deco street at night, a pink club computer](/images/opus-video-mood-board.jpg)

### Tools

I gave Opus access to the following via API:
- **Image Generation**: GPT Image 2 on high quality ($18 for 75 images)
- **Video Generation**: MiniMax H3 running on [RunPod](https://www.runpod.io/) ($22 for 73 clips)


## How Does Opus 5.5 Make These So Good?

### The Workflow

Humans creating AI video follow a standard workflow:

<picture>
  <source media="(max-width: 640px)" srcset="/images/opus-video-workflow-narrow.svg">
  <img src="/images/opus-video-workflow.svg" alt="Four steps in a row: References, then Keyframes, then Video clips, then Editing." width="1030" height="110">
</picture>

Opus 5.5 follows this same process, with the vast majority of its ~3 hour runtime spent on video generation and editing. You can visualize its workflow with this timeline of tool calls:

<picture>
  <source media="(max-width: 640px)" srcset="/images/opus-video-sequence-narrow.svg">
  <img src="/images/opus-video-sequence.svg" alt="A timeline of time from start, from 0:00 to 3:09. Top: four workflow stage bars. References runs from 0:00 to 0:09, Keyframes from 0:10 to 0:41, Video clips from 0:26 to 2:42, and Editing from 0:42 to 3:08. Bottom: one dot per tool call in eight workstream rows: Research 12, Song analysis 14, Images 8, Pipeline code 41, GPU operations 61, Look and renderer 62, Visual review 100 and Assembly and delivery 20. Visual review dots continue through the whole run." width="1030" height="482">
</picture>

By far the most important part of its process is "visual review", where Opus builds an understanding of the video's visual content.


### Visual Review

Visual review is called whenever Opus 5.5 needs to understand the visual content of the video, in service of one of our visual goals for the video (e.g. dancing on beat).
Each visual review has two steps:
- **Image Render**: Render an image with information from the video. 
  - It could be a single frame, or multiple frames. 
  - It could be the raw frame, or annotated with grid lines, timestamps, or other info.
- **Inference**: The rendered image is passed to Opus with a question, e.g. "Is the type covering a face?"

Opus 5.5 has a different image strategy for each visual goal:


| Goal | Image Render | Inference Question |
|---|---|---|
| Consistent cast, place, look | Labeled contact sheet | Which candidate, take or fix is better |
| Video follows the story | Timestamped snaps | Problems in a cut over time |
| Clean takes | Clip review sheet | Did H3 keep the cast, place, and action? |
| A polished final frame | Full-resolution still | Fine detail: type, faces, glow |
| Readable type, no flicker | Detail crop | Lettering, flicker between frames |
| Placement, on-beat dancing | Coordinate grid | Pixel positions; movement against beats |
| Match the mood board style | Other | Mood board, look prototypes, one keyframe |


Visual review enables error correction at several stages of the workflow:

- **Reject keyframes.** One keyframe had lost the AI next to Vera. Opus made it again with a continuity reference.
- **Reject clips.** Opus rejected a take with a ghost double. It swapped 4 dance takes to their second seed.
- **Trim clips.** When dancers ran into the lens, Opus used only the first part of the clip.
- **Move action onto the beat.** When an action happened late in a clip, Opus moved the shot so the action lands on a downbeat.
- **Fix the look.** Opus checked changes to the paint shader on rendered stills.
- **Review the cut.** Opus reviewed four full renders as film strips and fixed what it found.

## Visual Review Examples

### Example 1: Character Consistency

**Goal:** keep the cast and the look the same in every shot.

**Image Render:** a cross-shot snapshot sheet. Opus rendered 8 stills from different shots and tiled them with timestamps.

<details class="prompt-diff not-prose">
<summary class="hdr"><svg class="chev" viewBox="0 0 16 16" width="16" height="16" aria-hidden="true"><path d="M6 3l5 5-5 5" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/></svg><span class="name">Labeled contact sheet</span><span class="toggle"><span class="show">Show image</span><span class="hide">Hide image</span></span></summary>
<img src="/images/opus-video-consistency.jpg" alt="Eight painted stills from different shots: Vera, the AI and the crew in the booth, on the dance floor and on the street, each labeled with its time" width="1200" height="1350" loading="lazy">
</details>

**Inference question:** Do the cast and the look stay the same across booth, floor, street, close and wide shots?

**Visual reasoning:**

> Consistency across shots is solid, but I found three issues to fix: the AI's suit is turning fully orange instead of just its seams/visor, the neon hero text reads as pink mush, and the crew's visors are oversized.

**Result: Opus tightened the orange detection, redrew the neon type and made the visors smaller. It approved the next sheet.**


### Example 2: Rejecting a Take

**Goal:** use only clean takes for the climax.

**Image Render:** a clip review sheet. Opus tiled 8 frames from each of the two takes, labeled with take and frame number.

<details class="prompt-diff not-prose">
<summary class="hdr"><svg class="chev" viewBox="0 0 16 16" width="16" height="16" aria-hidden="true"><path d="M6 3l5 5-5 5" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/></svg><span class="name">Clip review sheet</span><span class="toggle"><span class="show">Show image</span><span class="hide">Hide image</span></span></summary>
<img src="/images/opus-video-visor-give.jpg" alt="Two takes of the AI putting its visor on Vera, eight frames each. In the second take, a faded copy of the AI appears behind Vera" width="1400" height="800" loading="lazy">
</details>

**Inference question:** Which of the two takes is clean?

**Visual reasoning:**

> **visor_give_s2** has a ghostly double of the android, so seed 1 stays.

**Result: Opus kept the first take.**

### Example 3: Locating the Screen

**Goal:** draw a face on the club computer's screen for the line "I see sparks of AGI in your eyes".

**Image Render:** a coordinate grid overlay. Opus drew a labeled 50 px grid on the first and last frames of the clip.

<details class="prompt-diff not-prose">
<summary class="hdr"><svg class="chev" viewBox="0 0 16 16" width="16" height="16" aria-hidden="true"><path d="M6 3l5 5-5 5" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/></svg><span class="name">Coordinate grid</span><span class="toggle"><span class="show">Show image</span><span class="hide">Hide image</span></span></summary>
<img src="/images/opus-video-crt-grid.jpg" alt="An H3 frame of Vera at a green CRT monitor, with a labeled coordinate grid every 50 pixels" width="1344" height="768" loading="lazy">
</details>

**Inference question:** Where are the exact corners of the CRT screen?

**Visual reasoning:**

> Since H3's camera push means a fixed quad won't work, I'll track the green CRT screen automatically per frame by detecting its saturated color, extracting its contour and corners, storing them in the pack, and letting the JS render screen content into that quad.

**Result: Opus added screen tracking. The first render did not show the content. After one more fix, the screen showed a face with starburst eyes.**

### Example 4: Reviewing the Cut

**Goal:** find problems in the first rough cut.

**Image Render:** a timestamped film strip. Opus sampled the cut at 3 frames per second and tiled the frames.

<details class="prompt-diff not-prose">
<summary class="hdr"><svg class="chev" viewBox="0 0 16 16" width="16" height="16" aria-hidden="true"><path d="M6 3l5 5-5 5" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/></svg><span class="name">Timestamped film strip</span><span class="toggle"><span class="show">Show image</span><span class="hide">Hide image</span></span></summary>
<img src="/images/opus-video-rough-cut.jpg" alt="A timestamped film strip of a rough cut. FOOM type covers the dancers&#x27; heads. Gray cards mark clips that are still generating" width="1600" height="562" loading="lazy">
</details>

**Inference question:** What is wrong in the first 40 seconds of the rough cut?

**Visual reasoning:**

> I found two bugs in the 0–40s cut — mask leakage on the loss-curve insert and a false visor glint triggered by hand poses — plus a layout issue where "FOOM" overlaps dancers' heads, which I'll fix by auto-placing hero words in face-free bands using pose data.

**Result: Opus fixed the two bugs and moved the words away from faces. The next check showed FOOM clear of faces.**

## Conclusion

Opus 5.5 demonstrates a high level of visual reasoning ability.
It is able to arrange and annotate inputs so that it can effectively use visual reasoning to address high-level objectives (e.g. character consistency, dancing on beat). 
This allows Opus to build an understanding of visual content. 
It uses that understanding to correct errors at multiple stages of the video creation process (e.g. accept/reject a reference, clip out an undesirable artifact).
All of this together leads to high-quality video outputs for users, and a banger X timeline for me. 

<video class="w-full" src="/videos/opus-video-full.mp4" poster="/images/opus-video-full-poster.jpg" controls playsinline preload="none" aria-label="The full music video made by Opus 5.5"></video>
