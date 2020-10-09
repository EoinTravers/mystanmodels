# Some useful keyboard shortcuts for package authoring:
#
#   Build and Reload Package:  'Ctrl + Shift + B'
#   Check Package:             'Ctrl + Shift + E'
#   Test Package:              'Ctrl + Shift + T'
#   Build docs:                roxygen2::roxygenise()

.stan_folder = path.expand('~/stanmodels')

#' @title Load a compiled stan model, or compile it if necessary
#'
#' @description
#'
#' @param model_name The name of the model to load
#' @param force_recompile Recompile the model even if it already exists?
#'     Default FALSE
#'     Recompilation will only happen if the .stan file has changed.
#' @param avoid_recompile If the model doesn't exist, don't bother compiling it?
#'     Default FALSE
#'
#' @details
#' Stan model code is found in ./inst/stan/
#' (relative to whatever directory you've cloned this repository to).
#' Compiled models are saved to ~/.mystanmodels/ (where ~ is your home directory).
#'
#' @examples
#' \dontrun{
#' model = lab_stanmodel('simple_lm')
#' N = 100
#' x = rnorm(N, 0, 1)
#' y = 10 + x * 2 + rnorm(N, 0, 1)
#' data = list(x=x, y=y, N=N)
#' posterior_samples = rstan::sampling(model, data=data, iter=2000)
#' est_map = rstan::optimizing(model, data=data)
#' est_vb = rstan::vb(model, data=data)
#' print(posterior_samples)
#' print(est_map$par)
#' print(est_vb)
#' }

load_stanmodel = function(model_name,
                          force_recompile = FALSE,
                          avoid_recompile = FALSE){
  if(force_recompile & avoid_recompile){
    stop("Arguments force_recompile and avoid_recompile can't both be TRUE")
  }
  if(force_recompile){
    message(sprintf("Trying to recompile model '%s'.", model_name))
    .remove_compiled_model(model_name) # Delete old .rds file
    model = .compile_stanmodel(model_name)
  } else {
    rds_file = file.path(.stan_folder, paste0(model_name, '.rds'))
    if(file.exists(rds_file)){
      # Load precompiled model
      message(sprintf("Loading compiled model '%s'.", model_name))
      mtime = file.info(rds_file)$mtime
      message('Compilation date: ', mtime)
      model = readRDS(rds_file)
    } else {
      if(avoid_recompile){
        stop('Model not compiled, and avoid_recompile is set to TRUE.')
      } else {
        message(sprintf("Compiling model '%s' for the first time.", model_name))
        model = .compile_stanmodel(model_name)
      }
    }
  }
  return(model)
}

.compile_stanmodel = function(model_name){
  # Compile model, or load it if already saved.
  file_name = paste0(model_name, '.stan')
  fp = file.path(.stan_folder, file_name)
  if(file.exists(fp)==FALSE){
    stop(sprintf("Model '%s' not found in %s", model_name, .stan_folder))
  }
  model = rstan::stan_model(file=fp, model_name=model_name,
                            auto_write = TRUE, save_dso = TRUE)
  return(model)
}

.remove_compiled_model = function(model_name){
  # Delete the .rds file
  file_name = paste0(model_name, '.rds')
  fp = file.path(.stan_folder, file_name)
  if(file.exists(fp)){
    file.remove(fp)
  }
}


#' @title Check where your stan models are stored.
#' @description Add .stan files to this folder to make them available across projects.
get_my_stanfolder = function(){
  print(sprintf('Stan models are saved in %s/', .stan_folder))
}

#' @title Get the stan code for the model specified
get_my_stancode = function(model_name){
  file_name = paste0(model_name, '.stan')
  fp = file.path(.stan_folder, file_name)
  code = readChar(fp, file.info(fp)$size)
  return(code)
}

#' @title Check when a model was last compiled
get_model_date = function(model_name){
  file_name = paste0(model_name, '.rds')
  fp = file.path(.stan_folder, file_name)
  if(file.exists(fp)){
    return(file.info(fp)$mtime)
  } else {
    stop(sprintf("Model '%s' not found.", model_name))
  }
}

#' @title List all the models in ~/stanmodels/
list_my_stanmodels = function(){
  # List all files ending in .stan
  files = list.files(.stan_folder, pattern='\\.stan$', recursive = TRUE)
  stringr::str_remove_all(files, '\\.stan')
}

