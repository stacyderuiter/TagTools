Change Point Detection
========================================================
author: Stacy DeRuiter
date: 8 August 2017
autosize: true

Did _________ Change?
========================================================
- show one or more examples of datasets - is there a change?
- Humans extremely skilled at detecting patterns and synthesizing information from multiple visual data sources
- This job is VERY HARD for a computer -- why?
    - we need to tell the computer what to expect, and specify exactly what and how things will change when "something changes."
    - most common change-point detection algorithms rely on conditions that are *not* met by tag data!


Simple change-point detection
========================================================
- Univariate case
- Using means or means and variances - simulated example and R code
- use R package changepoint
- do you know if there is a change-point or not?
- how many change-points are there exactly?

Multivariate change-point detection
========================================================
- similar methods as before, but multiple data streams
- are data means and variances same between streams?
- are sizes of changes same between streams?
- are data streams independent of each other (other than cp)?
- could there be a lag in the change from one time-series to the next?
- challenge level: multivariate >> univariate; unknown number of change points > known number; dependent data >>>>>>>independent data points

Does it work anyway?
========================================================
- what happens if we naively apply simple change point detectors to tag data?
- is the answer right?
- Maybe...and no...p-values are almost certainly wrong.
- If the user has to decide whether it "worked" and adjust settings/assumptions, then why do the procedure?

Devilish dependence on settings
========================================================
- depending on how many change points you expect, the results change
- blanking time between changes changes results
- black box algorithms with mysterious settings e.g. matlab findchangepts 'MinThreshold'

Are there alternatives?
========================================================
- Dina's curvature method?
- Hope for the future? [http://www.lancs.ac.uk/~khaleghi/](http://www.lancs.ac.uk/~khaleghi/)
- Just apply peak detection to univariate data? Data should not be the raw data then, but some summary of "what you think might be changing".
- A very simple resampling approach for univariate data with baseline/comparison periods
- broken stick models -- segmented package?

