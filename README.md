# Prefrontal feedback is associated with expectation-dependent adaptation in inferotemporal cortex

Code and data for the figures of

> Shafiei et al. *Prefrontal feedback is associated with expectation-dependent adaptation in inferotemporal cortex.* Communications Biology (under revision).

We recorded single units and field potentials from macaque inferotemporal cortex (IT) and ventrolateral prefrontal cortex (vlPFC) while two monkeys (F and V) viewed pairs of images in blocks with different repetition probabilities (repeating, alternating and neutral blocks).

This repository contains the scripts that draw the main and supplementary figures, and the processed data they read. Every plot script only draws its figure.

## Repository layout

```
main_figures/            plot scripts of Figs. 2-5
supplementary_figures/   plot scripts of the supplementary figures
data/                    processed data (.mat), one file per figure
functions/               helper functions used by some plot scripts
```

## Requirements

- MATLAB with the Statistics and Machine Learning Toolbox
- Functions in `functions/`

## How to run

1. Add the repository to the MATLAB path, including `functions/` and `data/`:
   ```matlab
   addpath(genpath('path/to/repository'))
   ```
2. Open a script and run it. It loads its data file from `data/` and opens the figure window.

Panels that contain jittered points use a random jitter, so single dots can sit slightly differently from run to run. Some labels, arrows, colour strips and stimulus images in the published figures were added by hand and are not drawn by the scripts.

## Main figures

| Figure | Content | Script | Data |
|---|---|---|---|
| Fig. 2 | Representational similarity analysis (RSA) of IT and vlPFC | `main_figures/fig2_plot.m` | `data/fig2_data.mat` |
| Fig. 3 | Repetition suppression and the block effect in IT | `main_figures/fig3_visualization.m` | `data/fig3_data.mat` |
| Fig. 4 | Expectation-dependent repetition effects in IT single units and field potentials | `main_figures/fig4_visualization.m` | `data/fig4_data.mat` |
| Fig. 5 | The block effect of IT neurons with low and high Granger index (GI) | `main_figures/fig5_visualization.m` | `data/fig5_data.mat` |

## Supplementary figures

Fig. S1 is a schematic of the task design and has no code.

| Figure | Content | Script | Data |
|---|---|---|---|
| Fig. S2 | Cross-validated RSMs, block-order and drift control | `figS2_plot.m` | `figS2_data.mat` |
| Fig. S3 | Block schedule and generalization of block-context information in IT | `figS3_plot.m` | `figS3_data.mat` |
| Fig. S4 | RSA of IT and vlPFC in both monkeys | `figS4_plot.m` | `figS4_data.mat` |
| Fig. S5 | Population distribution of adaptation indices (AI), all neurons and each monkey | `figS5_S6_plot.m` (first figure) | `figS5_S6_data.mat` |
| Fig. S6 | Distribution of stimulus-specific adaptation (SSA), all neurons and each monkey | `figS5_S6_plot.m` (second figure) | `figS5_S6_data.mat` |
| Fig. S7 | Block effect in 50 ms epochs | `figS7_plot.m` | `figS7_data.mat` |
| Fig. S8 | Fixation-break rate and pupil size in the repeating, neutral and alternating block | `figS8_plot.m` | `figS8_fixbreak_data.mat`, `figS8_pupil_data.mat` |
| Fig. S9 | Repetition suppression and the block effect in vlPFC (vlPFC version of Fig. 3) | `figS9_plot.m` | `figS9_data.mat` |
| Fig. S10 | Stimulus set: the block effect by stimulus category and image similarity | `figS10_plot.m` | `figS10_data.mat` |
| Fig. S11 | Fig. 3 for each monkey separately (IT) | `figS11_plot.m` | `figS11_data.mat` |
| Fig. S12 | Robustness of the expected-vs-unexpected correlation of Fig. 4 and interaction of expectation with adaptation | `figS12_plot.m` | `figS12_data.mat` |
| Fig. S13 | Expectation-dependent repetition effects in vlPFC (vlPFC version of Fig. 4) | `figS13_plot.m` | `figS13_data.mat` |
| Fig. S14 | Fig. 4 for each monkey separately (IT) | `figS14_plot.m` | `figS14_data.mat` |
| Fig. S15 | Dependence of vlPFC to IT Granger causality on the length of the vlPFC history | `figS15_plot.m` | `figS15_data.mat` |
| Fig. S16 | Recent trial history and the relationship between GI and the block effect | `figS16_plot.m` | `figS16_data.mat` |
| Fig. S17 | GI and the distribution of block type and trial type | `figS17_plot.m` | `figS17_data.mat` |
| Fig. S18 | Block effect of IT neurons with low and high GI in the reverse direction (IT to vlPFC) | `figS18_plot.m` | `figS18_data.mat` |
| Fig. S19 | Block effect of IT neurons with low and high GI in the baseline window (vlPFC to IT) | `figS19_plot.m` | `figS19_data.mat` |
| Fig. S20 | Fig. 5 for each monkey separately (IT) | `figS20_plot.m` | `figS20_data.mat` |

## Data

The .mat files in data/ contain the processed values that are plotted in the figures. They were derived from the recordings using our analysis scripts. The raw recordings (spike trains and field potentials) are not included in this repository, but are available from the authors upon reasonable request.

Monkey identifiers: 1 = Monkey F, 2 = Monkey V. Block types: RB = repeating block, AB = alternating block, neutral = random block. Trial types: RT = repeated, AT = alternated.

## Citation

Shafiei et al. Communications Biology (under revision).
