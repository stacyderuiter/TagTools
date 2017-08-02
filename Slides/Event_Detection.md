Event Detection
========================================================
author: David Sweeney 
date: 8 August 2017
autosize: true
incremental: true


Event Detection Theory
========================================================

- What is event detection?
    - The process of discerning between signal noise and a behavioral event
    

Noise vs. Event
========================================================

- What is noise?
    - Irrelevant and undesired signal stimuli
- What is an event?
    - Informative and unique signal stimuli characteristic of a behavioral event
    

Detection Threshold
========================================================

- What is a threshold?
    - The ratio of an event's signal strength to that of the signal noise that constitutes a present behavior event
    

Detection Threshold
========================================================

- The goal is to have the largest ratio of true positive detections to false positive detections


Setting a Threshold
========================================================

- Thresholds that are too high:
    - Many missed detections
    - Low probability of FP and TP
- Thresholds that are too low:
    - Many FP and TP detections


Optimal Threshold
========================================================

- High rate of true positive detections
- Low rate of false positive detections
- As few missed detections as possible



Optimal Threshold
========================================================

- ROC curves are used to determine the optimal threshold


Blanking Time
========================================================

- What is a blanking time?
    - Amount of time within which all values exceeding the threshold level constitute the same signal
    

Setting the Blanking Time
========================================================

- Blanking times account for the physical and/or physiological constraints of animal behaviors


Optimal Threshold
========================================================

- What is the necessary time required between successive behavior events?


ROC Curves
========================================================

- Reciever Operating Characteristic (ROC) curve
- Two main Purposes:
    - Assess overall performance of event detector
    - Help set the optimal threshold level
    

ROC Curves
========================================================

<div align='center'>
<img src="images/ROCcurve.png" width=700, height=675>
</div>


# Example: Detecting Lunge Feeding Events
========================================================

