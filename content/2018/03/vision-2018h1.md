---
date: 2018-03-20
aliases:
- /2018/03/20/vision-2018h1.html
title: "D言語のビジョン2018年前半期【翻訳】"
tags:
- dlang
- d_wiki
- tech
- translation 
excerpt: "このドキュメントではDの高レベルなビジョンについて2学期制的粒度で論じます。 これは毎年1月と7月にリリースされます。 ここで示された目標はあくまでDのリーダーシップが取り組んでいることであり、明示的に促進されるもの、もしくはD言語の成功にとって重要だと強く信じられているものです。 他の形での貢献も常に受け入れられ、このドキュメントに合わせる必要はありません。"
---

この記事は、
[Vision/2018H1 - D Wiki](https://wiki.dlang.org/Vision/2018H1)
を自分用に翻訳したものを原文と同じ
[GNU Free Documentation License](http://www.gnu.org/copyleft/fdl.html)
で公開するものである。

ソース中にコメントの形で原文を残している。
何か気になるところがあれば
[Pull request](https://github.com/{{ site.github.repository_nwo }}/edit/{{ site.github.source.branch }}/{{ page.path }})だ!

---
<!-- ### Meta -->

### このページについて

<!-- This document discusses the high-level vision for D with semestrial granularity. It is released in January and July of each year. Note that the goals presented are those the D leadership works on, explicitly fosters, or strongly believes are important for the success of the D language. Other contributions are always welcome and do not need to be necessarily aligned with this document. -->

このドキュメントではDの高レベルなビジョンについて2学期制的粒度で論じます。
これは毎年1月と7月にリリースされます。
ここで示された目標はあくまでDのリーダーシップが取り組んでいることであり、明示的に促進されるもの、もしくはD言語の成功にとって重要だと強く信じられているものです。
他の形での貢献も常に受け入れられ、このドキュメントに合わせる必要はありません。

<!-- ### H2 2017 Review -->

### H2 2017 レビュー

<!-- #### The D Language Foundation -->

#### D言語財団

<!-- Expenses for H2 2017 have averaged at $1605 per month. These include mostly recurring expenses (scholarships, contract payments). -->

H2 2017における経費は月平均1605ドルです。
このほとんどが経常費です(奨学金や支払い契約)。

<!-- The Foundation has funds for over three years assuming no changes in expenses and no money inflow. We, however, expect both donations and expenses to increase. -->

支払額が今後変化せず、まったく流入がないと仮定すると財団には3年分の資金があります。
しかしそれでも向上のための寄付と出費が必要だと考えています。

<!-- The scholarship recipients have created [154 pull requests](https://github.com/search?utf8=%E2%9C%93&q=user%3Adlang+author%3ARazvanN7+author%3Aedi33416+author%3ADarredevil+author%3Asomzzz+created%3A2017-07-01..2017-12-31&type=Issues). -->

奨学生は[154のプルリクエスト](https://github.com/search?utf8=%E2%9C%93&q=user%3Adlang+author%3ARazvanN7+author%3Aedi33416+author%3ADarredevil+author%3Asomzzz+created%3A2017-07-01..2017-12-31&type=Issues)を作りました。

<!-- #### Organization -->

#### 組織

<!-- The core team (Walter Bright, Andrei Alexandrescu, Ali Cehreli, Martin Nowak, Vladimir Panteleev, Sebastian Wilzbach, Mike Parker) kept operations working. There are new potential core collaborators. -->

コアチーム(Walter Bright, Andrei Alexandrescu, Ali Cehreli, Martin Nowak, Vladimir Panteleev, Sebastian Wilzbach, Mike Parker)は活動を続けています。
新しい潜在的コアコラボレーターがいます。

<!-- #### Participation -->

#### 関与

<!-- H2 2017 has marked a 28.5% increase in total pull requests compared to to H2 2016: [1812](https://github.com/pulls?utf8=%E2%9C%93&q=is%3Apr+user%3Adlang+created%3A2017-07-01..2017-12-31) vs. [1410](https://github.com/pulls?utf8=%E2%9C%93&q=is%3Apr+user%3Adlang+created%3A2016-07-01..2016-12-31). Of these, 124 are open. -->

H2 2016の[1410](https://github.com/pulls?utf8=%E2%9C%93&q=is%3Apr+user%3Adlang+created%3A2016-07-01..2016-12-31)と比較して、H2 2017は[1812](https://github.com/pulls?utf8=%E2%9C%93&q=is%3Apr+user%3Adlang+created%3A2017-07-01..2017-12-31)と、プルリクエストの合計は28.5%の増加を見せています。
これらのうち124がオープンです。

<!-- We have continued to grant merge rights to strong contributors and fostered an increase in contribution quality and _esprit de corps_. -->

我々は価値あるコントリビュータのマージの受け入れや、コントリビューションのクオリティと団結心(_esprit de corps_)の向上の促進を続けてきました。

<!-- [Downloads of dmd](http://erdani.com/d/downloads.daily.png) have increased substantially, but we assume the data collection is imperfect because it does not account for repeated downloads from the same URL. So bots, repeated unsuccessful attempts, or manipulation can influence the statistics. We are working on a better tool. -->

[Dmdのダウンロード数](http://erdani.com/d/downloads.daily.png)は大幅に増加しましたが、このデータ収集は同じURLからの繰り返しのダウンロードを勘定に入れていないため不完全であると予測します。
つまりボットによる失敗する試行、または操作の繰り返しが統計に影響します。
我々はより良いツールについて取り組んでいます。

<!-- Visits to the [dlang.org](https://dlang.org) website have been on the rise; an all-time high of 19,370 average daily visits has been attained in January 2018. -->

ウェブサイト[dlang.org](https://dlang.org)への訪問数も増加しています。
2018年1月には日平均19370回という最高記録を達成しています。

<!-- #### Safety and Memory Management -->

#### セーフティとメモリ管理

<!-- Work on safe containers has slowed down but is still ongoing. -->

セーフコンテナの作業はスローダウンしているものの進んでいます。

<!-- Of new note is Alexandru Jercaianu's work on a new allocator that offers a safe free primitive. That opens new avenues for approaching memory management. -->

新たに注目すべき点として、Alexandru Jercaianuのセーフなフリープリミティブを提供する新しいアロケーターについての作業が挙げられます。

<!-- ### H1 2018 Priorities -->

### H1 2018 優先事項

<!-- #### Technical -->

#### 技術面

<!-- We are doubling down on work on the following essential directions: -->

我々は以下の極めて重要な方針の作業に注力しています:

<!-- 1. **Lock down the language definition:** D is a powerful language but its definition is not precise enough. A number of subtleties can only be assessed only by running the compiler, not by perusing the specification. This semester we are pushing for a better, more precise, and more complete specification of the D language. -->

1. **言語定義のロックダウン:** Dはパワフルな言語ですがその定義は十分に正確ではありません。
  数多くの細部が仕様の精査によってではなくコンパイラの実行によってのみ判断されています。
  この学期で、D言語のより良い、より正確な、より完全な仕様の策定を推し進めていきます。
<!-- 2. **@safety:** we aim to enable large-scale uses of D with safety guarantees. -->
2. **@safety:** Dの使用においての安全性の保証の大きなスケールでの実現を目指していきます。
<!-- 3. **@nogc:** Use of D without a garbage collector, most likely by using reference counting and related methods Unique/Weak references) for reclamation of resources. This task is made challenging by the safety requirement. We believe we have an attack in the upcoming allocators/collections combos. -->
3. **@nogc:** ガーベージコレクターを使わないDの使用、多くの場合参照カウントやそれに類するメソッド(Unique/Weak references)を使うことによるリソースの再利用。
  このタスクは安全性要求によってチャレンジングなものになります。
  われわれはアロケータとコレクションのコンボに対する対策があると信じています。
<!-- 4. **Improve interoperability with other languages:** Finishing -betterC should improve incremental migration of C and C++. -->
4. **他の言語との相互運用性の改善:** -betterCの完成はCやC++のインクリメンタルな移行を改善します。
<!-- 5. **Improve introspection abilities:** Make D the most powerful and easiest to use language for advanced introspection, code generation, and flexible designs. The approach must be two pronged - language improvements and libraries that use them gainfully. -->
5. **イントロスペクション機能の改善:** 高度なイントロスペクション、コード生成、柔軟なデザインによってDは最もパワフルかつ簡単に使うことができる言語になります。
  このアプローチは2方向からのものでなければなりません。
  つまり、言語の改善とそれを活用するライブラリです。
<!-- 6. **Tooling:** Define and allow others to define tools that help the use of the D language by everyone. -->
6. **ツール:** 定義と、誰もがD言語の使用を助けるツールを定義できるようにすること。

<!-- Virtually all efforts we drive should be assessed and benchmarked relative to these goals. -->

実際的には、我々の行うすべての取り組みはそれらの目標に関連して評価されベンチマークされる必要があります。

<!-- #### Non-Technical -->

#### 非技術面

<!-- We have enjoyed an unprecedented growth spurt starting December 2017, and need to improve our organizational structures in response. That includes: -->

われわれは2017年11月から突然発生した過去最大級の成長に遭遇しており、それに応じて組織構造を改善する必要があります。
それには以下の項目が含まれます:

<!-- *   Distribution
    *   Improve the process of porting the front-end to alternate backends (gdc, ldc).
    *   Pursue distribution of gdc as part of the gcc compiler suite.
    *   Improve installers, updaters, and related tooling.
    *   Foster development of IDEs, IDE plugins, editor helpers. -->

 - **配布**
   - フロントエンド他のバックエンド(gdc、ldc)へ移植するプロセスの改善
   - gdcのgccコンパイラスイートの一部としての配布の継続
   - インストーラー、アップデータ、その他関連ツールの改善
   - IDE、IDEプラグイン、エディタヘルパーの開発の促進

<!-- *   Contributor base
    *   Improve our _esprit de corps_ motivating talented community members to become high-impact contributors
    *   Forge new relationships with universities, Expand our scholarship offering to new universities
    *   Offer employment to the most active members of the community
    *   Foster academic contributions (papers, courses, workshops)
    *   Foster industrial contributions (joint projects, joint scholarships)
    *   Convert interesting discussions on our own forums into interesting discussions on high-traffic forums such as reddit, hackernews, twitter, and facebook
    *   Convert interesting debates and discussions into code and DIPs
    *   Convert scattered, uncoordinated contributions into focused, large, high-impact projects. The evaluation from an impact perspective must be pervasive to all project/contributions/proposal assessments. -->

 - **コントリビューターベース**
    - 団結心を高め才能あるコミュニティーメンバーがハイインパクトコントリビューターになるための動機付けをする
    - 大学と新たな関係を構築し、新たな大学へ奨学金を拡大する
    - コミュニティーで特に活動的なメンバーに雇用オファーする
    - アカデミックなコントリビューション(論文、コース、ワークショップ)を促進
    - 産業のコントリビューション(プロジェクト、奨学金との連携)を促進
    - 我々のフォーラムの興味深い議論をreddit、hackernews、twitter、facebookなどのようなハイトラフィックなフォーラムでの議論への転換
    - 興味深いディベートやディスカッションのコードやDIPへの変換
    - 散らばって、うまく調整されていないコントリビューションの集中し、巨大な、ハイインパクトなプロジェクトへの転換。
        インパクトの視点からの評価はすべてのプロジェクト、コントリビューション、提案評価に浸透すべきです。

<!-- *   Better community management
    *   Make the joining process more inviting and enjoyable
    *   Have a clear path for a community member to get a question/concerned addressed, whether it's a technical question, a bug, a request for an improvement, or a meta topic. -->

 - **より良いコミュニティマネージメント**
    - 参加プロセスを魅力的で面白いものに
    - コミュニティーメンバーが質問や技術的質問、バグ、改善の要求、メタトピックなどの関連事項を受け付ける方法を明確化する

<!-- *   Make it easier for people to use the D language and contribute to it
    *   Tooling
    *   Documentation
    *   Contributing detailed issues
    *   Contributing fixes and improvements
    *   Communication at all levels -->

 - **人々がD言語を使い、コントリビュートすることを簡単にする**
    - ツール
    - ドキュメント
    - 細かなイシューへのコントリビューティング
    - 修正、改善のコントリビューティング
    - 全レベルにおけるコミニケーション

<!-- *   Public Relations
    *   Drive DConf 2018 to a great success
    *   Improve the standing of the D language on the landscape of programming languages
    *   Establish the DIP as a clear, solid means to get a language enhancement going
    *   Improve participation in the academic and industrial community
    *   Make our message heard and lead the discussion with strong technical content (blogs, articles, interviews, online discussions) -->

 - **売り込み**
    - DConf 2018を成功に導く
    - プログラミング言語の中でのD言語の地位向上
    - 言語機能向上のための明快かつ充実したDIPの構築
    - アカデミックや産業コミュニティへの関与を改善
    - 我々のメッセージを聞いてもらえるようにして、議論を導く勢いのある技術的コンテンツ(ブログ、記事、インタビュー、オンラインディスカッション)にする