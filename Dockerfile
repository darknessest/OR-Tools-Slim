# Create a virtual environment with all tools installed
FROM alpine:3.20
# Install system build dependencies
ENV PATH=/usr/local/bin:$PATH

ARG run_deps="python3 py3-numpy py3-pandas py3-matplotlib"
ARG build_deps="python3-dev py3-pip py3-wheel git build-base linux-headers cmake xfce4-dev-tools swig"
ARG python_deps="absl-py mypy-protobuf virtualenv"

RUN apk add --no-cache $run_deps


################
##  OR-TOOLS  ##
################

ARG GIT_URL="https://github.com/google/or-tools"

ARG GIT_BRANCH
ENV GIT_BRANCH ${GIT_BRANCH:-stable}

# download everything and build
# pay attentions to the number of threads
WORKDIR /root
RUN apk add --no-cache $build_deps && \
    pip install $python_deps --no-cache-dir --break-system-packages && \
    git clone --depth=1 -b "${GIT_BRANCH}" --single-branch "$GIT_URL" /project && \
    cd /project && \
    cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release -DBUILD_DEPS=ON -DBUILD_PYTHON=ON &&\
    cmake --build build -v -j8 && \
    cp build/python/dist/ortools-*.whl . && \
    NAME=$(ls *.whl | sed -e "s/\(ortools-[0-9\.]\+\)/\1+musl/") && mv *.whl "${NAME}" && \
    rm build/python/dist/ortools-*.whl && \
    pip install *.whl --break-system-packages && \
    cd .. && rm -rf project && \
    apk del $build_deps

WORKDIR /
