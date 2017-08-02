Event Detection
========================================================
author: David Sweeney 
date: 8 August 2017
autosize: true


Event Detection Theory
========================================================

- What is event detection?
    - The process of discerning between noise and a signal (behavioral event)
    
<img src="Event_Detection-figure/unnamed-chunk-1-1.png" title="plot of chunk unnamed-chunk-1" alt="plot of chunk unnamed-chunk-1" style="display: block; margin: auto;" />


Noise vs. Signal
========================================================

- What is noise?
    - Irrelevant and undesired signal stimuli
- What is an event?
    - Informative and unique signal stimuli characteristic of a behavioral event
- Event detection is impossible without noise
    

Detection Threshold
========================================================

- What is a threshold?
    - A ratio of signal power to noise power (_Principles of Underwater Sound for Engineers_ by Robert Urick)
- A signal that exceeds this ratio constitutes a detected behavior event

    

Setting a Threshold
========================================================

- The goal is to have the largest ratio of true positive detections to false positive detections
- Thresholds that are too high:
    - Many missed detections
    - Not many false positive and true positive detections
- Thresholds that are too low:
    - Many false positive and true positive detections


Setting a Threshold
========================================================




Optimal Threshold
========================================================

- High rate of true positive detections
- Low rate of false positive detections
- As few missed detections as possible

<img src="Event_Detection-figure/unnamed-chunk-2-1.png" title="plot of chunk unnamed-chunk-2" alt="plot of chunk unnamed-chunk-2" style="display: block; margin: auto;" />


Optimal Threshold
========================================================

- High rate of true positive detections
- Low rate of false positive detections
- As few missed detections as possible
- ROC curves

<img src="Event_Detection-figure/unnamed-chunk-3-1.png" title="plot of chunk unnamed-chunk-3" alt="plot of chunk unnamed-chunk-3" style="display: block; margin: auto;" />

Blanking Time
========================================================

- What is a blanking time?
    - Amount of time within which all values exceeding the threshold level constitute the same signal
    
<img src="Event_Detection-figure/unnamed-chunk-4-1.png" title="plot of chunk unnamed-chunk-4" alt="plot of chunk unnamed-chunk-4" style="display: block; margin: auto;" />


Setting the Blanking Time
========================================================

- Blanking times account for the physical and/or physiological constraints of animal behaviors
- What is the necessary time required between successive behavior events?

<div align='center'>
<img src="http://www2.hawaii.edu/~zinner/101/students/YvetteEcholocation/echolocation.jpg" width=800, height=400>
<font size=4> 
<br>(photo from http://www2.hawaii.edu/~zinner/101/students/YvetteEcholocation/echolocation.jpg)
</font>
</div>


ROC Curves
========================================================

- Receiver Operating Characteristic (ROC) curve
- Two main Purposes:
    - Assess overall performance of event detector
    - Help set the optimal threshold level
    

ROC Curves
========================================================

- The more area under the curve, the better the performance of the detector
<div align='center'>
<img src="https://openi.nlm.nih.gov/imgs/512/261/3861891/PMC3861891_CG-14-397_F10.png" width=500, height=550>
<font size=4> 
<br>(photo from https://openi.nlm.nih.gov/imgs/512/261/3861891/PMC3861891_CG-14-397_F10.png)
</font>
</div>


Example: Detecting Lunge Feeding Events
========================================================

<div align='center'>
<img src="http://www.norbertwu.com/nwp/subjects/bluewhales_web/originals/5659.JPG" width=750, height=600>
<font size=4> 
<br>(photo from http://www.norbertwu.com/nwp/subjects/bluewhales_web/originals/5659.JPG)
</font>
</div>


Detecting Lunges from Jerk
========================================================

![Owen et al. 2016](images/Owen2016.png)
***
![Simon et al. 2012](images/Simon2012.png)


Determine Necessary Inputs for detect_peaks
========================================================

```detect_peaks(data, sr, FUN, thresh, bktime, plot_peaks, varargin)```

```detect_peaks(data, sr, FUN = NULL, thresh = NULL, bktime = NULL, plot_peaks = NULL, ...)```
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

<img src="Event_Detection-figure/unnamed-chunk-5-1.png" title="plot of chunk unnamed-chunk-5" alt="plot of chunk unnamed-chunk-5" style="display: block; margin: auto;" />

- Tag falls off the animal at about 3.5 hours since tag attachment


Crop Data
========================================================

```cropped_Aw <- crop(Aw, sampling_rate)```



<img src="Event_Detection-figure/unnamed-chunk-7-1.png" title="plot of chunk unnamed-chunk-7" alt="plot of chunk unnamed-chunk-7" style="display: block; margin: auto;" />


Running detect_peaks
========================================================

```detections <- detect_peaks(data = Aw, sr = sampling_rate, FUN = njerk, thresh = NULL, bktime = 30, plot_peaks = TRUE, sampling_rate = sampling_rate)```



<img src="Event_Detection-figure/unnamed-chunk-9-1.png" title="plot of chunk unnamed-chunk-9" alt="plot of chunk unnamed-chunk-9" style="display: block; margin: auto;" />


Using the Interactive Plot
========================================================

```"GRAPH HELP: For changing only the thresh level, click once within the plot and then click finish or push escape or push escape to specify the y-value at which your new thresh level will be. For changing just the bktime value, click twice within the plot and then click finish or push escape to specify the length for which your bktime will be. To change both the bktime and the thresh, click three times within the plot: the first click will change the thresh level, the second and third clicks will change the bktime. To return your results without changing the thresh and bktime from their default values, simply click finish or push escape."```


Using the Interactive Plot
========================================================

- Click the following coordinates [x , y]:
    - [30000 , 0.75]
- Click Finish
    
![plot of chunk unnamed-chunk-10](Event_Detection-figure/unnamed-chunk-10-1.png)
***

```
List of 6
 $ start_time: num [1:110] 326 690 1124 1187 1491 ...
 $ end_time  : num [1:110] 326 690 1124 1190 1494 ...
 $ peak_time : num [1:110, 1] 327 691 1125 1191 1493 ...
 $ peak_max  : num [1:110, 1] 0.871 1.149 0.806 0.931 1.259 ...
 $ thresh    : num 0.75
 $ bktime    : num 30
```


Comparing to Known Lunges
========================================================
Known Events

```
     [,1]
[1,]  340
[2,]  700
[3,] 1195
[4,] 1505
[5,] 1910
[6,] 3980
```
***
Detected Events

```
     [,1]
[1,]  327
[2,]  691
[3,] 1125
[4,] 1191
[5,] 1493
[6,] 1900
```


ROC Curve
========================================================

- Determine the false positive rate and the true positive rate of detections
    - false positive rate = (# false positive detections / # total possible events)
        - # total possible events = ((# of samples / sampling_rate) / blanking time)
    - true positive rate = (# true positive detections / # known events)
        - # of known events is determined manually


Generating ROC Curve
========================================================

<img src="Event_Detection-figure/unnamed-chunk-14-1.png" title="plot of chunk unnamed-chunk-14" alt="plot of chunk unnamed-chunk-14" style="display: block; margin: auto;" />


Rerun detect_peaks
========================================================

```detections <- detect_peaks(data = cropped_Aw, sr = sampling_rate, FUN = njerk, thresh = 0.4 , bktime = 30, plot_peaks = FALSE, sampling_rate = sampling_rate)```


