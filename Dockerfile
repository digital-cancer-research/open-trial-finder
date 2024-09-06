## base R Shiny image
FROM rocker/shiny
 
## require configuration file path
ARG CONFIG_FILE_PATH
 
## make a directory in the container
RUN mkdir /home/shiny-app
 
## Install R dependencies
 
# for indexTrialData.Rmd...
RUN R -e "install.packages(c('DBI', 'RODBC', 'RPostgres', 'RSQLite', 'jsonlite', 'plyr', 'dplyr', 'tidyr', 'formattable', 'kableExtra', 'stringr', 'splitstackshape', 'reshape2', 'tictoc', 'leaflet', 'PostcodeioR', 'igraph', 'tidygeocoder', 'caret', 'rpart', 'rpart.plot', 'quanteda', 'corpus', 'tidytext'))"
RUN R -e "install.packages("BiocManager")"
RUN R -e "BiocManager::install("AnnotationDbi")"
RUN R -e "BiocManager::install("org.Hs.eg.db")"
RUN R -e "BiocManager::install("KEGGREST")"
RUN R -e "BiocManager::install("KEGGlincs")"
RUN R -e "BiocManager::install("hgu133a.db")"
 
# for TRIAL_MATCH_SHINY.Rmd...
RUN R -e "install.packages(c('markdown', 'flexdashboard', 'shinyWidgets', leaflet', 'htmltools', 'DT')"
 
# for trial_report.Rmd...
# (no others needed)
 
## copy the necessary files
COPY ${CONFIG_FILE_PATH} /home/shiny-app/trialMatchConfiguration.json
COPY conditionSynonyms6.csv /home/shiny-app/conditionSynonyms6.csv
COPY digitalECMTlogo48px.PNG /home/shiny-app/digitalECMTlogo48px.PNG
COPY indexTrialData.Rmd /home/shiny-app/indexTrialData.Rmd
COPY TRIAL_MATCH_SHINY.Rmd /home/shiny-app/TRIAL_MATCH_SHINY.Rmd
COPY trial_report.Rmd /home/shiny-app/trial_report.Rmd
COPY indexedTrialData.sqlite /home/shiny-app/indexedTrialData.sqlite
  
## schedule data refresh
RUN apt-get update && apt-get -y install cron
RUN echo -e "SHELL=/bin/sh\nPATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin\n\n0 0 * * 0 Rscript /home/shiny-app/indexTrialData.Rmd > /var/log/latest_index_trial_data.log 2>&1\n" > /etc/cron.d/index_trial_data_cron
 
# RUN Rscript /home/shiny-app/indexTrialData.Rmd
 
## Expose the application port
EXPOSE 3500
## Run the R Shiny app
CMD Rscript /home/shiny-app/TRIAL_MATCH_SHINY.Rmd