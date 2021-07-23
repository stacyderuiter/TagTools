---
title: "Title here..."
author: "(Matlab/Octave version)"
date: "Date here..."
output: 
  html_document:
    toc: true
    toc_depth: 2
    toc_float: true
    number_sections: true
    code_folding: hide
---

```{r, setup, include = FALSE}
library(tagtools)
knitr::opts_chunk$set(
  echo=TRUE, eval=FALSE,
  results='markup',
  fig.show='hold',
  tidy=FALSE,     # display code as typed
  size="small")   # slightly smaller font for code
```

<script>
function showAndHideButton() {
    var x = document.getElementById("myDIV");
    if (x.style.display === "none") {
        x.style.display = "block";
    } else {
        x.style.display = "none";
    }
}
</script>
 
<button onclick="showAndHideButton()">Show/hide answer</button>
 
<div id="myDIV" style="display:none">
 
Answer text here.
 
</div>


Welcome! 

In this practical you will... 

These practicals all assume that you have Matlab or Octave installed on your computer, some basic experience working with them, and that you can can execute provided code, making some user-specific changes along the way. We will provide you with quite a few lines/chunks of code. To boost your own learning, you would do well to try and write them before opening what we give, using this just to check your work. 

# 

# Review 

You have learned to... 

*If you'd like to continue working through these practicals... You should always feel free to search for whichever practical seems most relevant to your data or interests.* 