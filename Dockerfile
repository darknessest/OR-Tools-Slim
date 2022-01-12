# Create a virtual environment with all tools installed
FROM alpine:3.15
# Install system build dependencies
ENV PATH=/usr/local/bin:$PATH

ENV run_deps python3 py3-numpy py3-pandas py3-matplotlib
ENV build_deps python3-dev py3-pip py3-wheel git build-base linux-headers cmake xfce4-dev-tools swig
ENV python_deps absl-py mypy-protobuf

RUN apk add --no-cache $run_deps


################
##  OR-TOOLS  ##
################

ENV GIT_URL https://github.com/google/or-tools

ARG GIT_BRANCH
ENV GIT_BRANCH ${GIT_BRANCH:-stable}

# download everything and build
# pay attentions to the number of threads
WORKDIR /root
RUN apk add --no-cache $build_deps && \
    pip3 install $python_deps && \
    git clone --depth=1 -b "${GIT_BRANCH}" --single-branch "$GIT_URL" /project && \
    cd /project && \
    cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release -DBUILD_DEPS=ON -DBUILD_PYTHON=ON &&\
    cmake --build build -v -j4 && \
    cp build/python/dist/ortools-*.whl . && \
    NAME=$(ls *.whl | sed -e "s/\(ortools-[0-9\.]\+\)/\1+musl/") && mv *.whl "${NAME}" && \
    rm build/python/dist/ortools-*.whl && \
    pip3 install *.whl && \
    cd .. && rm -rf project && \
    apk del $build_deps

WORKDIR /