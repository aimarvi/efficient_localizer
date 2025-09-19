# An Efficient Multifunction fMRI Localizer (EMFL)

Companion repository for the paper: **“An Efficient Multifunction fMRI Localizer for High-Level Visual, Auditory, and Cognitive Regions in Humans”**

The stimuli used for the study are provided in the [stims](https://github.com/aimarvi/efficient_localizer/tree/main/stims) folder. We recommend running at least three runs of EMFL to reproduce the results we show in the paper, in any order. If you use EMFL or re-use parts of this repo, please cite as: 

_Marvi, A. I., Hutchinson, S., Fedorenko, E., Saxe, R. R., Kamps, F. S., Regev, T. I., Chen, E. M., & Kanwisher, N. G. (2025). An Efficient Multifunction fMRI Localizer for High-Level Visual, Auditory, and Cognitive Regions in Humans. (in press)_

## Usage

_NOTE: running this design requires [PsychToolBox 3](https://psychtoolbox.org/) and a compatible version of MATLAB_

```javascript
subj_id = ...
run_num = ... # 1-5

run_effloc(subj_id, run_num)
```

