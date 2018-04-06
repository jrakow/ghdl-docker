FROM ubuntu

ENV DEV_DEPENDENCIES \
	bzip2 \
	ca-certificates \
	curl \
	flex \
	gcc \
	gnat-5 \
	g++ \
	make \
	python3 \
	python3-pip \
	python3-setuptools \
	wget \
	zlib1g-dev

RUN apt-get update && \
	apt-get install --yes --no-install-recommends ${DEV_DEPENDENCIES}

RUN curl https://codeload.github.com/ghdl/ghdl/tar.gz/v0.35 | tar -xz && mv ghdl-0.35 ghdl
RUN curl ftp://ftp.halifax.rwth-aachen.de/gnu/gcc/gcc-6.4.0/gcc-6.4.0.tar.gz | tar -xz && mv gcc-6.4.0 gcc

WORKDIR /ghdl

RUN ./configure --with-gcc=/gcc --prefix=/usr/local
RUN make -j 8 copy-sources

RUN mkdir /gcc/objdir
WORKDIR /gcc
RUN ./contrib/download_prerequisites
WORKDIR /gcc/objdir
RUN ../configure --prefix=/usr/local --enable-languages=c,vhdl --disable-bootstrap --disable-lto --disable-multilib --disable-libssp --disable-libgomp --disable-libquadmath --disable-werror
RUN make -j 8
RUN make -j 8 install MAKEINFO=true

WORKDIR /ghdl
RUN make -j 8 ghdllib
RUN make -j 8 install

RUN pip3 install junitparser

WORKDIR /src

ENV RUN_DEPENDENCIES \
	gcc \
	git \
	lcov \
	libgnat-5 \
	make \
	python3 \
	ssh \
	xsltproc \
	zlib1g-dev
RUN apt-get autoremove --purge --yes ${DEV_DEPENDENCIES} && \
	apt-get install --yes --no-install-recommends ${RUN_DEPENDENCIES}

RUN rm -rf \
	/gcc \
	/ghdl \
	/var/lib/apt/lists/*
