FROM nvidia/cuda:11.1-devel-ubuntu18.04
RUN rm -rf /etc/apt/sources.list.d

RUN apt-get update --fix-missing && \
    apt-get install -y --no-install-recommends \
        git make libgtest-dev cmake wget unzip libtinfo-dev libz-dev \
        libcurl4-openssl-dev libopenblas-dev g++ sudo

ENV BASE_DIR=$HOME/coreneuron_tutorial \
    INSTALL_DIR=$BASE_DIR/install \
    SOURCE_DIR=$BASE_DIR/sources

RUN mkdir -p $INSTALL_DIR $SOURCE_DIR

WORKDIR $SOURCE_DIR
RUN git clone --recursive https://github.com/BlueBrain/CoreNeuron.git
RUN git clone https://github.com/nrnhines/nrn.git
