Event Detection
========================================================
author: David Sweeney 
date: 8 August 2017
autosize: true
incremental: true


Event Detection Theory
========================================================

- What is event detection?
    - The process of discerning between noise and a behavioral event
    
<img src="Event_Detection-figure/unnamed-chunk-1-1.png" title="plot of chunk unnamed-chunk-1" alt="plot of chunk unnamed-chunk-1" style="display: block; margin: auto;" />


Noise vs. Signal
========================================================

- What is noise?
    - Irrelevant and undesired stimuli
- What is an event?
    - Informative and unique signal stimuli characteristic of a behavioral event
- Event detection is impossible without noise
    

Detection Threshold
========================================================

- What is a threshold?
    - A ratio of event signal power to noise power (_Principles of Underwater Sound for Engineers_ by Robert Urick)
- A signal that exceeds this ratio constitutes a detected behavior event

<img src="Event_Detection-figure/unnamed-chunk-2-1.png" title="plot of chunk unnamed-chunk-2" alt="plot of chunk unnamed-chunk-2" style="display: block; margin: auto;" />

    
Setting a Threshold
========================================================

- The goal is to have the largest ratio of true positive detections to false positive detections
- Thresholds that are too high:
    - Many missed detections
    - Not many false positive and true positive detections

<img src="Event_Detection-figure/unnamed-chunk-3-1.png" title="plot of chunk unnamed-chunk-3" alt="plot of chunk unnamed-chunk-3" style="display: block; margin: auto;" />


Setting a Threshold
========================================================

- Thresholds that are too low:
    - Many false positive and true positive detections

<img src="Event_Detection-figure/unnamed-chunk-4-1.png" title="plot of chunk unnamed-chunk-4" alt="plot of chunk unnamed-chunk-4" style="display: block; margin: auto;" />


Optimal Threshold
========================================================

- High rate of true positive detections
- Low rate of false positive detections
- As few missed detections as possible
- Receiver Operating Characteristic (ROC) curve ...

Blanking Time
========================================================

- What is a blanking time?
    - Amount of time within which all values exceeding the threshold level constitute the same signal
    
<img src="Event_Detection-figure/unnamed-chunk-5-1.png" title="plot of chunk unnamed-chunk-5" alt="plot of chunk unnamed-chunk-5" style="display: block; margin: auto;" />


Setting the Blanking Time
========================================================

- Blanking times account for the physical and/or physiological constraints of animal behaviors
- What is the necessary time required between successive behavior events?

<div align='center'>
<img src="http://extrememarine.org.uk/wp-content/uploads/2016/12/sperm-whale-echolocation.jpg" width=800, height=400>
<font size=4> 
<br>(photo from http://extrememarine.org.uk/2016/12/sperm-whales-a-deep-sea-odyssey/)
</font>
</div>


ROC Curves
========================================================

- Three main Purposes:
    - Assess overall performance of event detector
    - Help set the optimal threshold level
    - Compare performance of different detectors on the same data
    

ROC Curves
========================================================

- The more area under the curve, the better the performance of the detector
<div align='center'>
<img src="https://openi.nlm.nih.gov/imgs/512/261/3861891/PMC3861891_CG-14-397_F10.png" width=500, height=500>
<font size=4> 
<br>(photo from https://openi.nlm.nih.gov/detailedresult.php?img=PMC3861891_CG-14-397_F10&req=4)
</font>
</div>


Case Study: Detecting Lunge Feeding Events
========================================================

<div align='center'>
<img src="http://www.norbertwu.com/nwp/subjects/bluewhales_web/originals/5659.JPG" width=750, height=600>
<font size=4> 
<br>(photo from http://www.norbertwu.com/nwp/subjects/bluewhales_web/gallery-02.html)
</font>
</div>


What whale is this?
========================================================

Data is from the whale bw11_210a which was tagged on 29 July 2011

![SOCAL BRS](images/SOCALBRS-logo.PNG)
<font size=3>
<br>(photo from http://sea-inc.net/socal-brs/)
</font>
![Goldbogen et al. 2013](images/Goldbogen2013.PNG)
***
![DeRuiter et al. 2017](images/DeRuiter2017.PNG)
![Goldbogen et al. 2015](images/Goldbogen2015.PNG)



Detecting Lunges from Jerk
========================================================

![Owen et al. 2016](images/Owen2016.png)
![Simon et al. 2012](images/Simon2012.png)


Determine Necessary Inputs for detect_peaks
========================================================

```detect_peaks(data, sr, FUN, thresh, bktime, plot_peaks, varargin)```

```detect_peaks(data, sr, FUN = NULL, thresh, bktime, plot_peaks = TRUE, ...)```
- data = acceleration matrix in whale frame (Aw)
- sr = sampling rate of acceleration matrix
- FUN = njerk
- thresh = default
- bktime = ?


Blanking Time for Detecting Lunges
========================================================


![Goldbogen et al. 2006](images/Goldbogen2006.png)

- "durations between consecutive lunges, the time between speed maxima, averaged 44.5±19.1 s" (Goldbogen et al. 2006)
- bktime = 30


Tag On vs. Tag Off
========================================================

<img src="Event_Detection-figure/unnamed-chunk-6-1.png" title="plot of chunk unnamed-chunk-6" alt="plot of chunk unnamed-chunk-6" style="display: block; margin: auto;" />

- Tag falls off the animal at about 3.5 hours since tag attachment


Crop Data
========================================================

```cropped_Aw <- crop(Aw, sampling_rate)```



<img src="Event_Detection-figure/unnamed-chunk-8-1.png" title="plot of chunk unnamed-chunk-8" alt="plot of chunk unnamed-chunk-8" style="display: block; margin: auto;" />


Running detect_peaks
========================================================

```detections <- detect_peaks(data = cropped_Aw, sr = sampling_rate, FUN = njerk, thresh = NULL, bktime = 30, plot_peaks = TRUE, sampling_rate = sampling_rate)```



<img src="Event_Detection-figure/unnamed-chunk-10-1.png" title="plot of chunk unnamed-chunk-10" alt="plot of chunk unnamed-chunk-10" style="display: block; margin: auto;" />


Using the Interactive Plot
========================================================

```"GRAPH HELP: For changing only the thresh level, click once within the plot and then click finish or push escape or push escape to specify the y-value at which your new thresh level will be. For changing just the bktime value, click twice within the plot and then click finish or push escape to specify the length for which your bktime will be. To change both the bktime and the thresh, click three times within the plot: the first click will change the thresh level, the second and third clicks will change the bktime. To return your results without changing the thresh and bktime from their default values, simply click finish or push escape."```


Using the Interactive Plot
========================================================

- Click the following coordinates [x , y]:
    - [30000 , 0.75]
- Click Finish

![plot of chunk unnamed-chunk-11](Event_Detection-figure/unnamed-chunk-11-1.png)


Comparing to Known Lunges
========================================================

- red dots = known lunging events
- gold crosses = detected lunging events

<img src="Event_Detection-figure/unnamed-chunk-12-1.png" title="plot of chunk unnamed-chunk-12" alt="plot of chunk unnamed-chunk-12" style="display: block; margin: auto;" />


ROC Curve
========================================================

- Determine the false positive rate and the true positive rate of detections
    - false positive rate = (number false positive detections / number total possible events)
        - number of total possible events = ((recording time / sampling_rate) / blanking time)
    - true positive rate = (number true positive detections / number known events)


Generating ROC Curve
========================================================

Optimal threshold?

<img src="Event_Detection-figure/unnamed-chunk-13-1.png" title="plot of chunk unnamed-chunk-13" alt="plot of chunk unnamed-chunk-13" style="display: block; margin: auto;" />


Rerun detect_peaks
========================================================

```detections <- detect_peaks(data = cropped_Aw, sr = sampling_rate, FUN = njerk, thresh = 0.95, bktime = 30, plot_peaks = FALSE, sampling_rate = sampling_rate)```

<img src="Event_Detection-figure/unnamed-chunk-14-1.png" title="plot of chunk unnamed-chunk-14" alt="plot of chunk unnamed-chunk-14" style="display: block; margin: auto;" />


Overall Performance of detect_peaks
========================================================

- gray = default threshold and behavior-specific blanking time
- orange = optimal threshold and behavior-specific blanking time
- blue = maximum true positive threshold (.65) and behavior-specific blanking time

***
<img src="Event_Detection-figure/unnamed-chunk-15-1.png" title="plot of chunk unnamed-chunk-15" alt="plot of chunk unnamed-chunk-15" style="display: block; margin: auto;" />


Default Threshold and Default Blanking Time
========================================================

```detections <- detect_peaks(data = cropped_Aw, sr = sampling_rate, FUN = njerk, thresh = NULL, bktime = NULL, plot_peaks = FALSE, sampling_rate = sampling_rate)```

<img src="Event_Detection-figure/unnamed-chunk-16-1.png" title="plot of chunk unnamed-chunk-16" alt="plot of chunk unnamed-chunk-16" style="display: block; margin: auto;" />


Comparing to Known Lunges
========================================================

- red points = known lunging events
- cyan crosses = detected lunging events from all default parameters

<img src="Event_Detection-figure/unnamed-chunk-17-1.png" title="plot of chunk unnamed-chunk-17" alt="plot of chunk unnamed-chunk-17" style="display: block; margin: auto;" />


Overall Performance of detect_peaks
========================================================

- cyan = default threshold and default blanking time
- gray = default threshold and behavior-specific blanking time
- orange = optimal threshold and behavior-specific blanking time
- blue = maximum true positive threshold (.65) and behavior-specific blanking time

***
<img src="Event_Detection-figure/unnamed-chunk-18-1.png" title="plot of chunk unnamed-chunk-18" alt="plot of chunk unnamed-chunk-18" style="display: block; margin: auto;" />
