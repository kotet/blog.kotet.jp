---
date: 2018-03-07
aliases:
- /2018/03/07/dcompute-gpgpu-with-native-d-for-opencl-and-cuda.html
title: "DCompute:ネイティブDによるOpenCLやCUDAのGPGPU【翻訳】"
tags:
- dlang
- tech
- translation
- d_blog
excerpt: "DComputeはGPUやその他アクセラレータを使う計算集約型コードのためにOpenCLやCUDA用のネイティブカーネルをDで書くことをサポートするフレームワークでありコンパイラ拡張です。"
---

この記事は、
[DCompute: GPGPU with Native D for OpenCL and CUDA – The D Blog](https://dlang.org/blog/2017/07/17/dcompute-gpgpu-with-native-d-for-opencl-and-cuda/)
を自分用に翻訳したものを
[許可を得て](http://dlang.org/blog/2017/06/16/life-in-the-fast-lane/#comment-1631)
公開するものである。

ソース中にコメントの形で原文を残している。
誤字や誤訳などを見つけたら今すぐ
[Pull request](https://github.com/{{ site.github.repository_nwo }}/edit/{{ site.github.source.branch }}/{{ page.path }})だ!

---

<!-- _Nicholas Wilson is a student at Murdoch University, studying for his BEng (Hons)/BSc in Industrial Computer Systems (Hons) and Instrumentation & Control/ Molecular Biology & Genetics and Biomedical Science. He just finished his thesis on low-cost defect detection of solar cells by electroluminescence imaging, which gives him time to work on DCompute and write about it for the D Blog. He plays the piano, ice skates, and has spent 7 years putting D to use on number bashing, automation, and anything else that he could make a computer do for him._ -->

Nicholas WilsonはMurdoch Universityの生徒です。
BEng (Hons)/BScのためにIndustrial Computer Systems (Hons)とInstrumentation & Control/ Molecular Biology & Genetics and Biomedical Scienceを学んでいます。
彼は電界発光イメージングによるソーラーセルの欠陥のローコストな検出についての卒業論文を書き終わったので、
DComputeの作業をしてそれについてD Blogに書く時間ができました。
彼はピアノとアイススケートをたしなみ、number bashing、オートマトン、その他様々なことをDでできるように7年をかけています。

---

<!-- ![](https://i1.wp.com/dlang.org/blog/wp-content/uploads/2017/07/ldc.png?resize=160%2C160) -->
<!-- DCompute is a framework and compiler extension to support writing native kernels for OpenCL and CUDA in D to utilise GPUs and other accelerators for computationally intensive code. In development are drivers to automate the interactions between user code and the tedious and error prone compute APIs with the goal of enabling the rapid development of high performance D libraries and applications. -->

![ldc](/assets/2018/03/ldc.png){:align="left"}
DComputeはGPUやその他アクセラレータを使う計算集約型コードのためにOpenCLやCUDA用のネイティブカーネルをDで書くことをサポートするフレームワークでありコンパイラ拡張です。
ハイパフォーマンスDライブラリやアプリケーションの高速な開発を可能にすることを目標にユーザーコードと退屈なものとエラーを起こしがちなコンピュートAPIとの相互作用を自動化するドライバが開発中です。

<!-- ### Introduction -->

### イントロダクション

<!-- After watching [John Colvin’s DConf 2016 presentation](http://dconf.org/2016/talks/colvin.html) in May of last year on using D’s metaprogramming to make the OpenCL API marginally less horrible to use, I thought, “This would be so much easier to do if we were able to write kernels in D, rather than doing string manipulations in OpenCL C”. At the time, I was coming up to the end of a rather busy semester and thought that would make a good winter[\[1\]](#fnote) project. After all, [LDC](https://github.com/ldc-developers/ldc), the LLVM D Compiler, has access to LLVM’s [SPIR-V](https://github.com/thewilsonator/llvm-target-spirv) and PTX backends, and I thought, “It can’t be too hard, its only glue code”. I _slightly_ underestimated the time it would take, finishing the first stage of [DCompute](http://github.com/libmir/dcompute) (because naming things is hard), mainlining the changes I made to LDC at the end of February, eight months later — just in time for the close of submissions to DConf, where I gave a [talk](http://dconf.org/2017/talks/wilson.html) on the progress I had made. -->

昨年5月にOpenCL APIの使用をちょっとひどいものにするDのメタプログラミングを行いながら[John ColvinのDConf 2016でのプレゼンテーション](http://dconf.org/2016/talks/colvin.html)を見たあと、私は思いました。
「Dでカーネルを書けるようになれば、これはOpenCL Cで文字列操作をするよりもっと簡単になるんじゃないか」
当時は比較的忙しい学期の終わりが来ており、これはいい冬[^1]のプロジェクトになると思いました。
なんといっても[LDC](https://github.com/ldc-developers/ldc)、LLVM D コンパイラはLLVMの[SPIR-V](https://github.com/thewilsonator/llvm-target-spirv)とPTXバックエンドへのアクセスができるので、私は「これは難しくない、ただのグルーコードだ」と考えました。
私は**少しばかり**これにかかる時間を甘く見ており、[DCompute](http://github.com/libmir/dcompute)(ものに名前をつけるのは難しいことです)の最初のステージ、LDCへの私の変更のメインライニングができたのは2月、つまり8ヶ月後になりました。ちょうどDConfの登録締切の時期で、私はそこで作ったものの進捗について[話しました](http://dconf.org/2017/talks/wilson.html)。

[^1]: 南半球

<!-- Apart from familiarising myself with the LDC and DMD front-end codebases, I also had to understand the LLVM SPIR-V and PTX backends that I was trying to target, because they require the use of special metadata (for e.g. denoting a function is a kernel) and address spaces, used to represent __g`lobal` & friends in OpenCL C and _`_global__` & friends in CUDA, and introduce these concepts into LDC. -->

LDCとDMDのフロントエンドコードベースと親しくなること以外にも、(関数がカーネルであると伝えるなどのための)特殊なメタデータやOpenCL Cの`__global`等やCUDAの`__global__`等を表現するためのアドレススペースを扱い、LDCにその概念を導入する必要があるため、ターゲットとするLLVM SPIR-VとPTXバックエンドも理解する必要がありました。

<!-- But once I was familiar with the code and had sorted the above discrepancies, it was mostly smooth sailing translating the OpenCL and CUDA modifiers into compiler-recognised attributes and wrapping the intrinsics into an easy to use and consistent interface. -->

しかし一度コードに親しくなり上記の差異を整理すれば、OpenCLとCUDAの修飾子をコンパイラが認識できる属性に翻訳し命令を簡単で一貫性のあるインターフェースにラッピングする作業は順調に進みました。

<!-- When it was all working and almost ready to merge into mainline LDC, I hit a bit of a snag with regards to CI: the SPIR-V backend that was being developed by Khronos was based on the quite old LLVM 3.6.1 and, despite my suggestions, did not have any releases. So I forward ported the backend and the conversion utility to the master branch of LLVM and made a [release](https://github.com/thewilsonator/llvm/releases) myself. Still in progress on this front are converting magic intrinsics to proper LLVM intrinsics and transitioning to a TableGen-driven approach for the backend in preparation for merging the backend into LLVM Trunk. This should hopefully be done soon™. -->

作業が進みほとんどLDCのメインラインにマージする準備が整った頃、私はCIにおける問題にぶつかりました。
Khronosで開発されたSPIR-Vバックエンドはとても古いLLVM 3.6.1をベースにしており、私の思いつきにかかわらず、リリースがありませんでした。
そこで私はバックエンドとコンバージョンユーティリティをLLVMのmasterブランチに向けてフォワードポートし自分で[リリース](https://github.com/thewilsonator/llvm/releases)しました。
これは進行中であり、magic intrinsicsの適切なLLVM命令への変換や、LLVM Trunkへバックエンドをマージするための準備のためのTableGen-drivenアプローチへの移行が進んでいます。
うまく行けばすぐに終わるはずです™。

<!-- ### Current state of DCompute -->

### DComputeの現状

<!-- With the current state of DCompute we are able to write kernels natively in D and have access to most of its language-defining features like [templates & static introspection](https://tour.dlang.org/tour/en/basics/templates), [UFCS](https://tour.dlang.org/tour/en/gems/uniform-function-call-syntax-ufcs), [scope guards](https://tour.dlang.org/tour/en/gems/scope-guards), [ranges & algorithms](https://tour.dlang.org/tour/en/gems/range-algorithms) and [CTFE](https://tour.dlang.org/tour/en/gems/compile-time-function-evaluation-ctfe). Notably missing, for hardware and performance reasons, are those features commonly excluded in kernel languages, like function pointers, virtual functions, dynamic recursion, RTTI, exceptions and the use of the garbage collector. Note that unlike OpenCL C++ we allow kernel functions to be templated and have overloads and default values. Still in development is support for images and pipes. -->

現在のDComputeではカーネルをネイティブにDで書くことができ、[テンプレートと静的イントロスペクション](https://tour.dlang.org/tour/ja/basics/templates)、
[UFCS](https://tour.dlang.org/tour/ja/gems/uniform-function-call-syntax-ufcs)、
[スコープガード](https://tour.dlang.org/tour/ja/gems/scope-guards)、
[レンジとそのアルゴリズム](https://tour.dlang.org/tour/ja/gems/range-algorithms)、
[CTFE](https://tour.dlang.org/tour/ja/gems/compile-time-function-evaluation-ctfe)などの言語機能にアクセスできます。
気をつけるべきこととして、ハードウェアとパフォーマンスの観点から関数ポインタ、仮想関数、動的再帰、RTTI、例外、ガベージコレクタの使用はカーネル言語から除外されています。
OpenCL C++と違いカーネル関数をテンプレート化したりオーバーロードやデフォルト値をもたせたりできる点に注目するべきでしょう。
imageとpipeのサポートは進行中です。

<!-- ### Example code -->

### コード例

<!-- To write kernels in D, we need to pass `-mdcompute-targets=<targets>` to LDC, where `<targets>` is a comma-separated list of the desired targets to build for, e.g. `ocl-120,cuda-350` for OpenCL 1.2 and CUDA compute capability 3.5, respectively (yes, we can do them all at once!). We get one file for each target, e.g. `kernels_ocl120_64.spv`, when built in 64-bit mode, which contains all of the code for that device. -->

Dでカーネルを書くには、`-mdcompute-targets=<targets>`をLDCに渡す必要があります。
`<targets>`はコンマで区切られたビルドしたいターゲットのリストで、たとえばOpenCL 1.2とCUDA compute capability 3.5の場合、それぞれ(そう、一度に全部書くことができます!)`ocl-120,cuda-350`と書きます。
たとえば64ビットモードのときは`kernels_ocl120_64.spv`のように、そのデバイスのためのすべてのコードを含む1つのファイルが各ターゲットごとに得られます。

<!-- The `vector add` kernel in D is: -->

Dにおける「ベクトルの加算」カーネルは以下のようになります:

```d
@compute(CompileFor.deviceOnly) module example;
import ldc.dcompute;
import dcompute.std.index;

alias gf = GlobalPointer!float;

@kernel void vadd(gf a, gf b, gf c) 
{
	auto x = GlobalIndex.x;
	a[x] = b[x]+c[x];
}
```


<!-- Modules marked with the `@compute` attribute are compiled for each of the command line targets, `@kernel` makes a function a kernel, and `GlobalPointer` is the equivalent of the `__global` qualifier in OpenCL. -->

`@compute`属性がついたモジュールは各コマンドラインターゲットに向けてコンパイルされ、`@kernel`は関数をカーネルにし、`GlobalPointer`はOpenCLの`__global`修飾子と等価です。

<!-- Kernels are not restricted to just functions — lambdas & tamplates also work: -->

カーネルは関数だけに制限されません。
ラムダやテンプレートも動作します:

<!-- ```d
@kernel void map(alias F)(KernelArgs!F args)
{
    F(args);
}
//In host code
AutoBuffer!float x,y,z; // y & z initialised with data
q.enqueue!(map!((a,b,c) => a=b+c))(x.length)(x, y, z);
``` -->

```d
@kernel void map(alias F)(KernelArgs!F args)
{
    F(args);
}
//以下ホストコード内
AutoBuffer!float x,y,z; // y & z はデータで初期化されています
q.enqueue!(map!((a,b,c) => a=b+c))(x.length)(x, y, z);
```

<!-- Where `KernelArgs` translates host types to device types (e.g. buffers to pointers or, as in this example, AutoBuffers to [AutoIndexed Pointers](https://github.com/libmir/dcompute/blob/master/source/dcompute/std/index.d#L298)) so that we encapsulate the differences in the host and device types. -->

`KernelArgs`はホストの型からデバイスの型
(たとえばポインタへのバッファ。またはこの例の場合[AutoIndexed Pointers](https://github.com/libmir/dcompute/blob/master/source/dcompute/std/index.d#L298)へのAutoBuffers)
に変換され、ホストやデバイスの種類の違いからカプセル化されています。

<!-- The last line is the expected syntax for launching kernels, `q.enqueue!kernel(dimensions)(args)`, akin to CUDA’s `kernel<<<dimensions,queue>>>(args)`. The libraries for launching kernels are in development. -->

最後の行はカーネルを起動するのに必要な文`q.enqueue!kernel(dimensions)(args)`で、CUDAの`kernel<<<dimensions,queue>>>(args)`と近いものです。
カーネル起動のためのライブラリは開発中です。

<!-- Unlike CUDA, where all the magic for transforming the above expression into code on the host lies in the compiler, `q.enqueue!func(sizes)(args)` will be processed by static introspection of the driver library of DCompute.   -->
<!-- The sole reason we can do this in D is that we are able to query the mangled name the compiler will give to a symbol via the symbol’s `.mangleof` property. This, in combination with D’s easy to use and powerful templates, means we can significantly reduce the mental overhead associated with using the compute APIs. Also, implementing this in the library will be much simpler, and therefore faster to implement, than putting the same behaviour in the compiler. While this may not seem much for CUDA users, this will be a breath of fresh air to OpenCL users (just look at the [OpenCL vector add host code example](http://www.heterogeneouscompute.org/wordpress/wp-content/uploads/2011/06/Chapter2.txt) steps 7-11). -->

上記の式をホストのコードに変換するすべてのマジックがコンパイラにあるCUDAと違い、`q.enqueue!func(sizes)(args)`はDComputeのドライバライブラリの静的イントロスペクションによって処理されます。
Dにおいてそのようなことができるたった一つの理由は、コンパイラがシンボルに与える修飾名をシンボルの`.mangleof`プロパティで取得できるからです。
これとDの簡単でパワフルなテンプレートの組み合わせによって、コンピュートAPIを使うことに関する心的オーバーヘッドを著しく減らすことができました。
また、そのライブラリへの実装もシンプルになり、したがって同じふるまいをコンパイラにさせるのに比べて早く実装できました。
CUDAユーザーに向けた部分はまだ十分ではありませんが、OpenCLユーザーにとっては新風となることでしょう
([OpenCLのベクトル加算ホストコード例](http://www.heterogeneouscompute.org/wordpress/wp-content/uploads/2011/06/Chapter2.txt)のステップ7-11を見てみてください)。

<!-- While you cant do that just yet in DCompute, development should start to progress quickly and hopefully become a reality soon. -->

まだDComputeでこのようなことはできませんが、開発は進み、うまく行けばまもなく現実のものになるでしょう。

<!-- I would like to thank John Colvin for the initial inspiration, Mike Parker for editing, and the LDC folks, David Nadlinger, Kai Nacke, Martin Kinke, with a special thanks to Johan Engelen, for their help with understanding the LDC codebase and reviewing my work. -->

最初のインスピレーションについてJohn Colvinに、編集についてMike Parkerに、そしてLDCのフォークにDavid Nadlinger、 Kai Nacke、 Martin Kinke、またスペシャルサンクスとしてLDCコードベースの理解の補助と作業のレビューについてJohan Engelenに謝辞を伝えたいです。

<!-- If you would like to help develop DCompute (or be kept in the loop), feel free to drop a line at the [libmir Gitter](https://gitter.im/libmir/public). Similarly, any efforts preparing the [SPIR-V](https://github.com/thewilsonator/llvm) [backend](https://github.com/thewilsonator/llvm-target-spirv) for inclusion into LLVM are also greatly appreciated. -->

DComputeの開発を援助したい(または最新情報を受け取りたい)場合、どうぞ自由に[libmir Gitter](https://gitter.im/libmir/public)に連絡してください。
同様に、LLVMへ組み込むための[SPIR-V](https://github.com/thewilsonator/llvm) [バックエンド](https://github.com/thewilsonator/llvm-target-spirv)の開発への参加も受け付けています。