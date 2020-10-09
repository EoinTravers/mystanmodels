# mystanmodels

This package provides a simple wrapper for reusing compiled rstan models across packages.

## Usage

### Install

Install the package using devtools: `devtools::install_github("eointravers/mystanmodels")`

### Set up

Create a folder at `~/stanmodels/`, where `~` is your home folder.
If you're not sure where that is, try the following command in R:

```r
mystanmodels::get_my_stanfolder()
## [1] "Stan models are saved in /home/eoin/stanmodels/"
```

Copy your stan model code into this folder. 
You can use subfolders to organise your code, 
e.g. `~/stanmodels/sdt/equal_variance.stan`

### Use models

```r
library(rstan)
library(mystanmodels)

stan_data = list(
  N = nrow(iris),
  K = 1, # N predictors
  X = as.matrix(iris$Petal.Length, ncol=1),
  y = iris$Petal.Width)


# Compile model defined in ~/stanmodels/simple_lm.stan, 
# and save it for future use. This takes a while.
simple_lm = load_stanmodel('simple_lm')
## Compiling model 'simple_lm' for the first time.

samples = sampling(simple_lm, data=stan_data)
# Alternatively....
# vb_fit = vb(simple_lm, data=stan_data)
# opt_fit = optimizing(simple_lm, data=stan_data)
```

Then, in a later session

```r
simple_lm = load_stanmodel('simple_lm')
## Loading compiled model 'simple_lm'.
## Compilation date: 2020-10-09 12:01:24
```

Other options are `load_stanmodel('simple_lm', force_recompile=T)`,
which should be self-explanatory, and
`load_stanmodel('simple_lm', avoid_recompile=T)`,
which throws an error if the model isn't already compiled.

#### Other functions

- `get_my_stanfolder()`
- `get_my_stancode(model_name)` returns the contents of the .stan file
- `get_model_date(model_name)` checks whe the model was last compiled
- `list_my_stanmodels()` returns a list of all available models.
