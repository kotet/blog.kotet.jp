---
date: 2018-03-08
title: "DCompute:GPU上で走るD【翻訳】"
tags:
- dlang
- tech
- translation
- d_blog
excerpt: "これはDComputeの2つ目の記事です。 前回の記事では、DComputeの発展と小さな例を扱いました。 カーネルをビルドすることには成功しましたが、それを既存のフレームワークや自力で簡単に実行する方法はありませんでした。 しかし今はそんなことはありません。"
---


この記事は、
[DCompute: Running D on the GPU – The D Blog](https://dlang.org/blog/2017/10/30/d-compute-running-d-on-the-gpu/)
を自分用に翻訳したものを
[許可を得て](http://dlang.org/blog/2017/06/16/life-in-the-fast-lane/#comment-1631)
公開するものである。

ソース中にコメントの形で原文を残している。
今回あんまり訳せてないので気になったら
[Pull request](https://github.com/{{ site.github.repository_nwo }}/edit/{{ site.github.source.branch }}/{{ page.path }})だ!

---

<!-- _Nicholas Wilson is a student at Murdoch University, studying for his BEng (Hons)/BSc in Industrial Computer Systems (Hons) and Instrumentation & Control/ Molecular Biology & Genetics and Biomedical Science. He just finished his thesis on low-cost defect detection of solar cells by electroluminescence imaging, which gives him time to work on DCompute and write about it for the D Blog.He plays the piano, ice skates, and has spent 7 years putting D to use on number bashing, automation, and anything else that he could make a computer do for him._ -->

Nicholas WilsonはMurdoch Universityの生徒です。
BEng (Hons)/BScのためにIndustrial Computer Systems (Hons)とInstrumentation & Control/ Molecular Biology & Genetics and Biomedical Scienceを学んでいます。
彼は電界発光イメージングによるソーラーセルの欠陥のローコストな検出についての卒業論文を書き終わったので、
DComputeの作業をしてそれについてD Blogに書く時間ができました。
彼はピアノとアイススケートをたしなみ、number bashing、オートマトン、その他様々なことをDでできるように7年をかけています。

---

<!-- ![](https://i1.wp.com/dlang.org/blog/wp-content/uploads/2017/07/ldc.png?resize=160%2C160)
DCompute is a framework and compiler extension to support writing native kernels for OpenCL and CUDA in D to utilize GPUs and other accelerators for computationally intensive code. Its compute API drivers automate the interactions between user code and the tedious and error prone APIs with the goal of enabling the rapid development of high performance D libraries and applications. -->

![ldc](/assets/2018/03/ldc.png){:align="left"}
DComputeはGPUやその他アクセラレータを使う計算集約型コードのためにOpenCLやCUDA用のネイティブカーネルをDで書くことをサポートするフレームワークでありコンパイラ拡張です。
ハイパフォーマンスDライブラリやアプリケーションの高速な開発を可能にすることを目標にしたそのコンピュートAPIドライバはユーザーコードと退屈なものとエラーを起こしがちなAPIの間の相互作用を自動化します。

<!-- ### Introduction -->

### イントロダクション

<!-- This is the second article on [DCompute](https://github.com/libmir/dcompute). In the [previous article](https://dlang.org/blog/2017/07/17/dcompute-gpgpu-with-native-d-for-opencl-and-cuda/), we looked at the development of DCompute and some trivial examples. While we were able to successfully build kernels, there was no way to run them short of using them with an existing framework or doing everything yourself. This is no longer the case. As of [v0.1.0](https://github.com/libmir/dcompute/releases/tag/v0.1.0), DCompute now comes with native wrappers for both OpenCL and CUDA, enabling kernel dispatch as easily as CUDA. -->

これは[DCompute](https://github.com/libmir/dcompute)の2つ目の記事です。
[前回の記事](/2018/03/dcompute-gpgpu-with-native-d-for-opencl-and-cuda)[^1]
では、DComputeの発展と小さな例を扱いました。
カーネルをビルドすることには成功しましたが、それを既存のフレームワークや自力で簡単に実行する方法はありませんでした。
しかし今はそんなことはありません。
[v0.1.0](https://github.com/libmir/dcompute/releases/tag/v0.1.0)では、DComputeはOpenCLとCUDAのネイティブラッパーであると同時に、CUDAよりも簡単なカーネルディスパッチを実現するものでもあります。

[^1]: 原文: [https://dlang.org/blog/2017/07/17/dcompute-gpgpu-with-native-d-for-opencl-and-cuda/](https://dlang.org/blog/2017/07/17/dcompute-gpgpu-with-native-d-for-opencl-and-cuda/)

<!-- In order to run a kernel we need to pass it off to the appropriate compute API, either CUDA or OpenCL. While these APIs both try to achieve similar things they are different enough that to squeeze that last bit of performance out of them you need to treat each API separately. But there is sufficient overlap that we can make the interface reasonably consistent between the two. The C bindings to these APIs, however, are very low level and trying to use them is very tedious and extremely prone to error (yay `void*`).   -->
<!-- In addition to the tedium and error proneness, you have to redundantly specify a lot of information, which further compounds the problem. Fortunately this is D and we can remove a lot of the redundancy through introspection and code generation. -->

カーネルを実行するためにはCUDAかOpenCL、どちらか適切なコンピュートAPIにそれを渡さなければなりません。
どちらのAPIも同じことができますが、パフォーマンスのためにそれぞれのAPIを別々に扱うのに十分なほど違ってもいます。
しかしそれでも2つの間には適度な一貫性をもったインターフェースを作ることができるほどには重なる部分があります。
しかしこれらのAPIのCバインディングは非常にローレベルで、それを使うことは非常に退屈かつエラーを引き起こしやすいです(yay `void*`)。
退屈さとエラー性に加えて、冗長な情報の指定法が組み合わさってきます。
幸運にもこれはDであり、イントロスペクションとコード生成によって冗長性を大きく減らすことができます。

<!-- The drivers wrap the C API, providing a clean and consistent interface that’s easy to use. While the documentation is a little sparse at the moment, the source code is for the most part straightforward (if you’re familiar with the C APIs, looking where a function is used is a good place to start). There is the occasional piece of magic to achieve a sane API. -->

このドライバはC APIをラップし、クリーンで一貫性があり、簡単に使えるインターフェースを提供します。
ドキュメントはいまのところちょっと不足気味ですが、ソースコードの殆どは素直に書かれています(C APIに慣れているなら、関数が使われているところから読んでみるといいでしょう)。
ときおり、まともなAPIを実現するためにちょっとしたマジックがあったりします。

<!-- ### Taming the beasts -->

### 野獣を飼いならす

<!-- OpenCL’s `clGet*Info` functions are the way to access properties of the class hidden behind the `void*`. A typical call looks like -->

OpenCLの`clGet*Info`関数は`void*`に隠れたクラスのプロパティにアクセスするためのものです。
典型的にはこのようになります:

```d
enum CL_FOO_REFERENCE_COUNT = 0x1234;
cl_foo* foo = ...; 
cl_int refCount;
clGetFooInfo(foo, CL_FOO_REFERENCE_COUNT, refCount.sizeof, &refCount,null);
```

<!-- And that’s not even one for which you have to call, to figure out how much memory you need to allocate, then call again with the allocated buffer (and $DEITY help you if you want to get a `cl_program`’s binaries). -->

And that’s not even one for which you have to call, to figure out how much memory you need to allocate, then call again with the allocated buffer (and $DEITY help you if you want to get a `cl_program`’s binaries).

<!-- Using D, I have been able to turn that into this: -->

Dを使うとこのようになります:

```d
struct Foo
{
    void* raw;
    static struct Info
    {
        @(0x1234) int referenceCount;
        ...
    }
    mixin(generateGetInfo!(Info, clGetFooInfo));
}

Foo foo  = ...;
int refCount = foo.referenceCount;
```

<!-- All the magic is in [`generateGetInfo`](https://github.com/libmir/dcompute/blob/master/source/dcompute/driver/ocl/util.d) to generate a property for each member in `Foo.Info`, enabling much better scalability and bonus documentation. -->

すべてのマジックは`Foo.Info`の各メンバに対しプロパティを生成し、スケーラビリティとドキュメントを与える[`generateGetInfo`](https://github.com/libmir/dcompute/blob/master/source/dcompute/driver/ocl/util.d)にあります。

<!-- CUDA also has properties exposed in a similar manner, however they are not essential (unlike OpenCL) for getting things done so their development has been deferred. -->

CUDAにも同じようなやり方で公開されるプロパティがありますが、(OpenCLとは違い)これは必須ではないため、開発は先送りされています。

<!-- Launching a kernel is a large point of pain when dealing with the C API of both OpenCL and (only marginally less horrible) CUDA, due to the complete lack of type safety and having to use the `&` operator into a `void*` far too much. In DCompute this incantation simply becomes -->

OpenCLと(酷さはそんなに変わらない)CUDAの両方のC APIを扱うとき、型安全の欠如と`void*`への`&`オペレータの使用のために、カーネルの起動は苦労するものです。
DComputeではその呪文がOpenCLの場合は

```d
Event e = q.enqueue!(saxpy)([N])(b_res, alpha, b_x, b_y, N);
```

<!-- for OpenCL (1D with N work items), and -->

このように(1D with N work items)、そしてCUDAの場合

```d
q.enqueue!(saxpy)([N, 1, 1], [1 ,1 ,1])(b_res, alpha, b_x, b_y, N);
```

<!-- for CUDA (equivalent to `saxpy<<<N,1,0,q>>>(b_res,alpha,b_x,b_y, N);`) -->
このように(`saxpy<<<N,1,0,q>>>(b_res,alpha,b_x,b_y, N);`と等価)シンプルになります。

<!-- Where `q` is a queue, `N` is the length of buffers (`b_res`, `b_x` & `b_y`) and `saxpy` (single-precision _a x plus y_) is the kernel in this example. A full example may be found [here](https://github.com/libmir/dcompute/blob/master/source/dcompute/tests/main.d), along with the magic that drives the [OpenCL](https://github.com/libmir/dcompute/blob/4182fb8e1b2532adee2c6af3859856cc45cad85e/source/dcompute/driver/ocl/queue.d#L79) and [CUDA](https://github.com/libmir/dcompute/blob/4182fb8e1b2532adee2c6af3859856cc45cad85e/source/dcompute/driver/cuda/queue.d#L60) enqueue functions. -->

この例で`q`はキュー、`N`はバッファーの長さ、(`b_res`, `b_x` & `b_y`)と`saxpy`(single-precision _a x plus y_)はカーネルです。
[OpenCL](https://github.com/libmir/dcompute/blob/4182fb8e1b2532adee2c6af3859856cc45cad85e/source/dcompute/driver/ocl/queue.d#L79)と
[CUDA](https://github.com/libmir/dcompute/blob/4182fb8e1b2532adee2c6af3859856cc45cad85e/source/dcompute/driver/cuda/queue.d#L60)
のエンキュー関数のマジックに関する完全な例は[ここ](https://github.com/libmir/dcompute/blob/master/source/dcompute/tests/main.d)で見つかるでしょう。

<!-- ### The future of DCompute -->

### DComputeの未来

<!-- While DCompute is functional, there is still much to do. The drivers still need some polish and user testing, and I need to set up continuous integration. A driver that unifies the different compute APIs is also in the works so that we can be even more cross-platform than the industry cross-platform standard. -->

DComputeは機能的ですが、まだ十分ではありません。
ドライバーは洗練とユーザーテストが必要で、継続的インテグレーションもセットアップしなければなりません。
異なるコンピュートAPIをまとめるドライバも業界のクラスプラットフォーム標準よりもっとクロスプラットフォームにできるので、作業中です。

<!-- Being able to convert [SPIR-V into SPIR](https://www.khronos.org/spir/) would enable targeting `cl_khr_spir`-capable 1.x and 2.0 CL implementations, dramatically increasing the number of devices that can run D kernel code (there’s nothing stopping you using the OpenCL driver for other kernels though). -->

[SPIR-VをSPIRへ](https://www.khronos.org/spir/)変換できれば1.xと2.0のCL実装で`cl_khr_spir`をターゲットにする能力が得られ、D カーネルコードを実行できるデバイスの数は急激に増えます(他のカーネルのOpenCLドライバーを使わない理由はありません)。

<!-- On the compiler side of things, supporting OpenCL image and CUDA texture & surface operations in LDC would increase the applicability of the kernels that could be written.   -->
<!-- I currently maintain a forward-ported fork of [Khronos’s SPIR-V LLVM](https://github.com/KhronosGroup/SPIRV-LLVM) to generate SPIR-V from LLVM IR. I plan to use [IWOCL](http://www.iwocl.org/) to coordinate efforts to merge it into the LLVM trunk, and in doing so, remove the need for some of the hacks in place to deal with the oddities of the SPIR-V backend. -->

コンパイラ側のものとしては、OpenCLのimageやCUDAのtextureやsurface操作をLDCがサポートすれば書けるカーネルの幅が広がります。
私は現在LLVM IRからSPIR-Vを生成するための[Khronos’s SPIR-V LLVM](https://github.com/KhronosGroup/SPIRV-LLVM)のフォワードポートフォークを管理しています。
私はLLVM trunkへそれをマージするために取り組みを調整するために[IWOCL](http://www.iwocl.org/)を使おうと考えており、そうするといくらかSPIR-Vの古いところに対処するためのハックが必要なくなります。

<!-- ### Using DCompute in your projects -->

### プロジェクトでDComputeを使う

<!-- If you want to use [DCompute](https://github.com/libmir/dcompute), you’ll need a recent [LDC](https://github.com/ldc-developers/ldc) built against LLVM with the [NVPTX](https://llvm.org/docs/NVPTXUsage.html) (for CUDA) and/or SPIRV (for OpenCL 2.1+) targets enabled and should add `"dcompute": "~>0.1.0"` to your `dub.json`. LDC 1.4+ releases have NVPTX enabled. If you want to target OpenCL, you’ll need to build LDC yourself against [my fork of LLVM](https://github.com/thewilsonator/llvm/tree/compute). -->

[DCompute](https://github.com/libmir/dcompute)を使うつもりなら、[NVPTX](https://llvm.org/docs/NVPTXUsage.html) (CUDA用)とSPIRV (OpenCL 2.1+用)ターゲットのどちらかまたは両方が有効化されたLLVMで[LDC](https://github.com/ldc-developers/ldc)をビルドし、`"dcompute": "~>0.1.0"`を`dub.json`に追記する必要があります。
1.4以降のLDCのリリースではNVPTXは有効化されています。
OpenCLをターゲットとする場合、[私のLLVMフォーク](https://github.com/thewilsonator/llvm/tree/compute)でLDCをビルドしてください。