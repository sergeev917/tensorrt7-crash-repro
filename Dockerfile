FROM nvidia/cuda:10.2-devel-ubuntu18.04
SHELL ["/bin/bash", "-c"]
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get -qq -o=Dpkg::Use-Pty=0 update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        curl \
        g++-8 \
        gnupg2 \
        vim \
        valgrind \
        wget && \
    apt-get install -y --no-install-recommends \
        cuda-nvcc-10-2 \
        cuda-misc-headers-10-2 \
        cuda-cudart-dev-10-2 \
        libcublas-dev \
        cuda-driver-dev-10-2 \
        cuda-nvml-dev-10-2 \
        cuda-nvrtc-dev-10-2
WORKDIR /w
RUN mkdir -p /w/vendor/{include,lib}
COPY vendor/cudnn-10.2-linux-x64-v7.6.5.32.tgz /w/
RUN [[ "$(sha1sum /w/cudnn*.tgz | cut -d' ' -f1)" != "438d7608aa0478f377967a1e5036bce3d7d2f79f" ]] && \
    { echo "ERR different cudnn archive used!" ; exit 1; } ; \
    tar xfa ./cudnn*.tgz && \
    mv cuda/include/cudnn.h /w/vendor/include/ && \
    mv cuda/lib64/* /w/vendor/lib/ && \
    rm -rf ./cudnn*.tgz cuda/
COPY vendor/TensorRT-7.0.0.11.Ubuntu-18.04.x86_64-gnu.cuda-10.2.cudnn7.6.tar.gz /w/
RUN [[ "$(sha1sum /w/TensorRT*.tar.gz | cut -d' ' -f1)" != "1f17eb8c0b2f1ea0c7bf935cd209a6d6f0d23f93" ]] && \
    { echo "ERR different tensorrt archive used!" ; exit 1; } ; \
    tar xfa ./TensorRT*.tar.gz && \
    mv TensorRT*/include/* /w/vendor/include/ && \
    mv TensorRT*/targets/x86_64-linux-gnu/lib/* /w/vendor/lib/ && \
    rm -rf TensorRT*
RUN wget "https://media.githubusercontent.com/media/onnx/models/8883e49e68de7b43e263d56b9ed156dfa1e03117/vision/object_detection_segmentation/ssd/model/ssd-10.onnx"
COPY main.cc /w/
RUN g++ -O0 -ggdb3 \
    -o main \
    main.cc \
    -I ./vendor/include \
    ./vendor/lib/libnvinfer_static.a \
    ./vendor/lib/libmyelin_compiler_static.a \
    ./vendor/lib/libmyelin_pattern_library_static.a \
    ./vendor/lib/libmyelin_executor_static.a \
    ./vendor/lib/libmyelin_pattern_runtime_static.a \
    ./vendor/lib/libnvonnxparser_static.a \
    ./vendor/lib/libnvinfer_plugin_static.a \
    ./vendor/lib/libonnx_proto.a \
    ./vendor/lib/libprotobuf.a \
    ./vendor/lib/libcudnn_static.a \
    /usr/lib/x86_64-linux-gnu/libcublas_static.a \
    /usr/lib/x86_64-linux-gnu/libcublasLt_static.a \
    /usr/local/cuda-10.2/targets/x86_64-linux/lib/libcudart_static.a \
    /usr/local/cuda-10.2/targets/x86_64-linux/lib/libculibos.a \
    /usr/local/cuda-10.2/targets/x86_64-linux/lib/libcudadevrt.a \
    -lrt -ldl -pthread \
    -lcuda \
    -lnvrtc
ENTRYPOINT ["/w/main", "./ssd-10.onnx"]
