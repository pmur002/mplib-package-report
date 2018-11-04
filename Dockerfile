
# Base image
FROM pmur002/mplib-shared
MAINTAINER Paul Murrell <paul@stat.auckland.ac.nz>

# add CRAN PPA
RUN apt-get update && apt-get install -y apt-transport-https
RUN echo 'deb https://cloud.r-project.org/bin/linux/ubuntu xenial/' > /etc/apt/sources.list.d/cran.list
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9

# Install additional software
# R stuff
RUN apt-get update && apt-get install -y \
    xsltproc \
    r-base=3.4* \ 
    libxml2-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    bibtex2html \
    subversion 

# For building the report
RUN Rscript -e 'install.packages(c("knitr", "devtools"), repos="https://cran.rstudio.com/")'
RUN Rscript -e 'library(devtools); install_version("xml2", "1.1.1", repos="https://cran.rstudio.com/")'
RUN Rscript -e 'library(devtools); install_version("Rcpp", "0.12.17", repos="https://cran.rstudio.com/")'
RUN apt-get update && apt-get install -y \
    texlive-metapost \
    texlive-luatex \ 
    texlive-latex-extra # standalone.cls

# Packages used in the report
RUN Rscript -e 'library(devtools); install_version("grImport", "0.9-1", repos="https://cran.rstudio.com/")'

RUN Rscript -e 'library(devtools); install_github("pmur002/gridbezier@v1.0-0")'
RUN Rscript -e 'library(devtools); install_github("pmur002/vwline/pkg@v0.2-1")'
RUN Rscript -e 'library(devtools); install_version("polyclip", "1.8-7", repos="https://cran.rstudio.com/")'
RUN Rscript -e 'library(devtools); install_github("pmur002/metapost@v1.0-0")'
RUN Rscript -e 'library(devtools); install_github("pmur002/mplib@v1.0-0")'

# Using COPY will update (invalidate cache) if the tar ball has been modified!
# COPY metapost_1.0-0.tar.gz /tmp/
# RUN R CMD INSTALL /tmp/metapost_1.0-0.tar.gz

RUN apt-get install -y locales && locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8

