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

RUN apt-get install -y libncurses5-dev mpi

COPY nvhpc_2020_209_Linux_x86_64_cuda_multi.tar.gz $SOURCE_DIR
#RUN wget https://developer.download.nvidia.com/hpc-sdk/20.9/nvhpc_2020_209_Linux_x86_64_cuda_multi.tar.gz && \
RUN apt-get install -y --no-install-recommends bsdtar
RUN bsdtar xpzf nvhpc_2020_209_Linux_x86_64_cuda_multi.tar.gz && \
    sudo nvhpc_2020_209_Linux_x86_64_cuda_multi/install && \
    rm -rf nvhpc_2020_209_Linux_x86_64_cuda_multi.tar.gz nvhpc_2020_209_Linux_x86_64_cuda_multi/
# RUN wget https://developer.download.nvidia.com/hpc-sdk/20.9/nvhpc-20-9_20.9_amd64.deb https://developer.download.nvidia.com/hpc-sdk/20.9/nvhpc-2020_20.9_amd64.deb && \
#     sudo apt-get install ./nvhpc-20-9_20.9_amd64.deb ./nvhpc-2020_20.9_amd64.deb && \
#     rm *.deb

# WORKDIR $SOURCE_DIR/nrn
RUN apt-get install -y autoconf libtool python3-distutils python3-dev cython3 flex bison mpich
RUN rm /usr/bin/python && ln -s /usr/bin/python3 /usr/bin/python && \
    cd $SOURCE_DIR/nrn && \
    git checkout 677b1da8c0fcc8d7fa9af56fbaa35b1e49df2571 && \
    sed -i -e 's/GLOBAL minf/RANGE minf/g' src/nrnoc/hh.mod && \
    sed -i -e 's/TABLE minf/:TABLE minf/g' src/nrnoc/hh.mod && \
    ./build.sh && \
    ./configure --prefix=$INSTALL_DIR --without-iv --with-paranrn --with-nrnpython=`which python` && \
    make -j && \
    make install
ENV PATH=$INSTALL_DIR/x86_64/bin:$INSTALL_DIR/bin:$PATH
RUN cd $SOURCE_DIR/CoreNeuron && \
    git checkout 18f35f61a6acd7578994b0b041479c5559774300 && \
    cd $SOURCE_DIR && git clone https://github.com/nrnhines/ringtest.git && cd ringtest && \
    nrnivmodl mod && \
    mkdir -p coreneuron_x86 && cd coreneuron_x86 && \
    cmake $SOURCE_DIR/CoreNeuron -DADDITIONAL_MECHPATH=$SOURCE_DIR/ringtest/mod && \
    make || ln $SOURCE_DIR/ringtest/coreneuron_x86/share/mod2c/nrnunits.lib $SOURCE_DIR/ringtest/coreneuron_x86/share/ && make

