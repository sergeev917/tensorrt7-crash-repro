Steps to reproduce
===

1. Place `CuDNN-v7.6.5.32` distribution archive into `vendor` subdirectory.
The file is expected to be named `cudnn-10.2-linux-x64-v7.6.5.32.tgz` and
have SHA1 checksum = `438d7608aa0478f377967a1e5036bce3d7d2f79f`.

2. Place `TensorRT-7.0.0.11` distribution archive into `vendor` subdirectory.
The file is expected to be named `TensorRT-7.0.0.11.Ubuntu-18.04.x86_64-gnu.cuda-10.2.cudnn7.6.tar.gz`
and have SHA1 checksum = `1f17eb8c0b2f1ea0c7bf935cd209a6d6f0d23f93`.

3. Run `./build_and_run.sh`. The script will build a docker image and run it.
The expected result of the running part looks like:

```
Plugin creator registration succeeded - ONNXTRT_NAMESPACE::GridAnchor_TRT
Plugin creator registration succeeded - ONNXTRT_NAMESPACE::NMS_TRT
[...]
munmap_chunk(): invalid pointer
```

Additional info
===

Relevant output from valgrind:

```
==11== Invalid free() / delete / delete[] / realloc()
==11==    at 0x2A6D923B: operator delete(void*) (in /usr/lib/valgrind/vgpreload_memcheck-amd64-linux.so)
==11==    by 0xF49D87: std::_Hashtable<std::string, std::pair<std::string const, unsigned long>, std::allocator<std::pair<std::string const, unsigned long> >, std::__detail::_Select1st, std::equal_to<std::string>, std::hash<std::string>, std::__detail::_Mod_range_hashing, std::__detail::_Default_ranged_hash, std::__detail::_Prime_rehash_policy, std::__detail::_Hashtable_traits<true, false, true> >::_M_insert_unique_node(unsigned long, unsigned long, std::__detail::_Hash_node<std::pair<std::string const, unsigned long>, true>*) (in /w/main)
==11==    by 0xF49EA3: std::__detail::_Map_base<std::string, std::pair<std::string const, unsigned long>, std::allocator<std::pair<std::string const, unsigned long> >, std::__detail::_Select1st, std::equal_to<std::string>, std::hash<std::string>, std::__detail::_Mod_range_hashing, std::__detail::_Default_ranged_hash, std::__detail::_Prime_rehash_policy, std::__detail::_Hashtable_traits<true, false, true>, true>::operator[](std::string const&) (in /w/main)
==11==    by 0x114FF2B: onnx2trt::ImporterContext::registerTensor(onnx2trt::TensorOrWeights, std::string const&) (in /w/main)
==11==    by 0x11560A0: onnx2trt::ModelImporter::importModel(onnx2trt_onnx::ModelProto const&, unsigned int, onnxTensorDescriptorV1 const*) (in /w/main)
==11==    by 0x115831F: onnx2trt::ModelImporter::parseWithWeightDescriptors(void const*, unsigned long, unsigned int, onnxTensorDescriptorV1 const*) (in /w/main)
==11==    by 0x3673EE: main (main.cc:76)
==11==  Address 0xaa33f9d8 is 600 bytes inside a block of size 712 alloc'd
==11==    at 0x2A6D817F: operator new(unsigned long) (in /usr/lib/valgrind/vgpreload_memcheck-amd64-linux.so)
==11==    by 0x114CE5F: createNvOnnxParser_INTERNAL (in /w/main)
==11==    by 0x367130: nvonnxparser::(anonymous namespace)::createParser(nvinfer1::INetworkDefinition&, nvinfer1::ILogger&) (NvOnnxParser.h:247)
==11==    by 0x36738B: main (main.cc:71)
==11==
```
