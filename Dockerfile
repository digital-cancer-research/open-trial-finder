## base R Shiny image
FROM rocker/shiny
 
## require configuration file path
ARG CONFIG_FILE_PATH
 
## make a directory in the container
RUN mkdir /home/shiny-app
 
## Install R dependencies
 
# for indexTrialData.Rmd...
RUN R -e "install.packages(c('DBI', 'RODBC', 'RPostgres', 'RSQLite', 'jsonlite', 'plyr', 'dplyr', 'tidyr', 'formattable', 'kableExtra', 'stringr', 'splitstackshape', 'reshape2', 'tictoc', 'leaflet', 'PostcodeioR', 'igraph', 'tidygeocoder', 'caret', 'rpart', 'rpart.plot', 'quanteda', 'corpus', 'tidytext'))"

# for TRIAL_MATCH_SHINY.Rmd...
RUN R -e "install.packages(c('markdown', 'flexdashboard', 'shinyWidgets', 'leaflet', 'htmltools', 'DT', 'BiocManager'))"
 
# for trial_report.Rmd...
# (no others needed)

# Bioconductor packages
RUN R -e "BiocManager::install('AnnotationDbi', ask=FALSE)"
RUN R -e "BiocManager::install('org.Hs.eg.db', ask=FALSE)"
RUN R -e "BiocManager::install('KEGGREST', ask=FALSE)"
RUN R -e "BiocManager::install('KEGGlincs', ask=FALSE)"
RUN R -e "BiocManager::install('hgu133a.db', ask=FALSE)"
 
## copy the necessary files
# COPY ${CONFIG_FILE_PATH} /home/shiny-app/trialMatchConfiguration.json
COPY ./trialMatchConfiguration.json /home/shiny-app/trialMatchConfiguration.json

COPY conditionSynonyms6.csv /home/shiny-app/conditionSynonyms6.csv
COPY digitalECMTlogo48px.PNG /home/shiny-app/digitalECMTlogo48px.PNG
COPY indexTrialData.Rmd /home/shiny-app/indexTrialData.Rmd
COPY TRIAL_MATCH_SHINY.Rmd /home/shiny-app/TRIAL_MATCH_SHINY.Rmd
COPY trial_report.Rmd /home/shiny-app/trial_report.Rmd
COPY indexedTrialData.sqlite /home/shiny-app/indexedTrialData.sqlite
  
## set working directory so shiny can access trial report file
WORKDIR /home/shiny-app

## schedule data refresh
RUN apt-get update && apt-get -y install cron
RUN echo -e "SHELL=/bin/sh\nPATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin\n\n0 0 * * 0 Rscript /home/shiny-app/indexTrialData.Rmd > /var/log/latest_index_trial_data.log 2>&1\n" > /etc/cron.d/index_trial_data_cron
 
# RUN Rscript /home/shiny-app/indexTrialData.Rmd
 
## Expose the application port
EXPOSE 3500

## Run the R Shiny app
CMD Rscript -e "rmarkdown::run('/home/shiny-app/TRIAL_MATCH_SHINY.Rmd', shiny_args = list(host = '0.0.0.0', port = 3500))"
