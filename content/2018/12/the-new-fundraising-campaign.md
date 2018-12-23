---
title: "D言語財団の新規ファンディングキャンペーン【翻訳】"
date: 2018-12-25
tags:
- dlang
- tech
- translation
- d_blog
- advent_calendar
---

### はじめに

これは
[D言語 Advent Calendar 2018](https://qiita.com/advent-calendar/2018/dlang)
25日目の寄付と翻訳記事です。

#### 寄付

少額ながら今回の記事で取り上げられているキャンペーンに寄付をしました。

![](/img/blog/2018/12/donation.png)

#### 翻訳

[The New Fundraising Campaign – The D Blog](https://dlang.org/blog/2018/11/10/the-new-fundraising-campaign/)
を
[許可を得て](http://dlang.org/blog/2017/06/16/life-in-the-fast-lane/#comment-1631)
翻訳しました。

誤訳等あれば気軽に
[Pull requestを投げてください](https://github.com/kotet/blog.kotet.jp)。

---

![](/img/blog/2018/12/pull-requests-250.png)

<!-- On January 23, 2011, [Walter announced that development of the core D projects had moved to GitHub](https://www.digitalmars.com/d/archives/digitalmars/D/announce/D_Programming_Language_source_dmd_phobos_etc._has_moved_to_github_19886.html#N19886). It’s somewhat entertaining to go through the thread and realize that it’s almost entirely about people coming to terms with using git, a reminder that there was a time when git was still relatively young and had yet to dominate the source control market. -->

2011年1月23日、[WalterはDのコアプロジェクトをGitHubに移すとアナウンスしました](https://www.digitalmars.com/d/archives/digitalmars/D/announce/D_Programming_Language_source_dmd_phobos_etc._has_moved_to_github_19886.html#N19886)。
このスレッドではGitの使用について折り合いをつけようとする人々が見られておもしろいです。
当時Gitは若く、まだソース管理の市場を支配してはいませんでした。

<!-- ![](https://i0.wp.com/dlang.org/blog/wp-content/uploads/2018/11/pull-requests-250.png?resize=250%2C250) -->


<!-- The move to GitHub has since been cited by both Walter and Andrei as a big win, thanks to a subsequent increase in contributions. It was smooth sailing for quite some time, but eventually some grumbling began to be heard below the surface. Pull Requests (PRs) were being ignored. Reviews weren’t happening fast enough. The grumbling grew louder. There were long communication delays. PRs were sometimes closed by frustrated contributors, demotivated and unwilling to contribute further. -->

その後のコントリビューションの増加のため、
GitHubへの移行は大成功だったとWalterとAndreiは言及しています。
だいたい順風満帆でしたが、水面下ではしだいに不満が聞かれるようになりました。
プルリクエスト（PR）が無視されるのです。
レビューが詰まっていました。
不平は大きくなっていきます。
コミュニケーションに大きな遅延が発生していました。
PRはいらついたコントリビューターによって閉じられ、
その後のコントリビュートのモチベーションは下がっていきます。

<!-- [The oldest open PR in the DMD queue](https://github.com/dlang/dmd/pull/2155) as I write is dated June 10, 2013. If we dig into it, we see that it was ultimately done in by a break in communication. The contributor was asking for more feedback, then there was silence for nine months. Six months later, when asked to rebase, the contributor no longer had time for it. A year and a half. -->

執筆時点で[オープンのままDMDのキューに溜まっている最古のPR](https://github.com/dlang/dmd/pull/2155)
は2013年6月10日のものです。
読んでみると、コミュニケーションの中断で終わっていることがわかります。
コントリビューターはフィードバックを求め、その後9ヶ月音沙汰がありません。
6ヶ月後にリベースを求めた時には、もうコントリビューターには暇がありませんでした。
１年半経っていますからね。

<!-- There are other reasons why PRs can stall, but in the end many of them have one thing in common: there’s no one pushing all parties involved toward a resolution. There’s no one following up every few days to make sure communication hasn’t broken down, or that any action that must be taken is followed through. Everyone involved in maintaining the PR queue has other roles and responsibilities both inside and outside of D development, but none of them have the bandwidth to devote to regular PR management. -->

PRがストールする原因は他にもありますが、最終的には1つに集約されます。
解決に向かって推し進めていく人がいないのです。
コミュニケーションが途切れないよう数日おきにフォローアップする人もいないし、
継続的にすべき行動をする人もいません。
PRの管理をする誰もがDの開発の内外にPRの管理以外の役割と責任を持っており、
定期的なPR管理に費やせる帯域がありません。

<!-- We _have_ had people step up and try to revive old PRs. We _have_ seen some of them closed or merged. But there are some really challenging or time\-consuming PRs in the list. The one linked above, for example. The last comment is from Sebastian Wilzbach in March of this year, who points out that it will be difficult to revive because it’s based on the old C++ code base. So who has the motivation to get it done? -->

進み出て古いPRを復活させようとする人もいました。
いくつかはクローズされたりマージされました。
しかしリストにはとてもチャレンジングだったり、時間のかかるPRもあります。
たとえば、上でリンクしたものなどです。
今年3月のSebastian Wilzbachのコメントによると、
このコードは古いC++のコードベースをもとにしているため復活が難しいとあります。
誰かやろうと思う人はいますか？

<!-- I promised in the forums that I would soon be launching targeted funding campaigns. This seems like an excellent place to start. -->

私はフォーラムで、近く目的を絞ったファンディングキャンペーンを立ち上げると約束しました。
これは良い第一歩となると思います。

<!-- Fostering an environment that encourages more contributions benefits everyone who uses D. The pool of people in the D community who have the skill and knowledge necessary to manage those contributions is small. If they had the time, we wouldn’t have this problem. A community effort to compensate one of them to make more time for it seems a just cause. -->

コントリビューションを促進する環境の育成はDを使う全員にとって利益になります。
コントリビューションを管理するために必要なスキルと知識を持ち合わせているDコミュニティの人材は少ないです。
彼らに時間があれば、問題は解決できます。
コミュニティが彼らの一人に報酬を支払うことで、直接的に時間を作ります。

<!-- The D Language Foundation is asking the community as a whole to contribute to a fund to pay a part\-time PR manager $1,000 per month for a period of three months, from November 15 to February 14. The manager will be paid the full amount after February 14, in one lump sum. At that time, we’ll evaluate our progress and decide whether to proceed with another three\-month campaign. -->

D言語財団はコミュニティ全体に向けて非常勤PR管理者に11月15日から2月14日までの3ヶ月間、
月1000ドルを支払うための資金提供を呼びかけました。
管理者には2月14日以降に一括で給与が支払われます。
その時に進捗を評価して、次の3ヶ月のキャンペーンを行うか決定します。

<!-- We’ve already roped someone in who’s willing to do the job. Nicholas Wilson has been rummaging around the PR queue lately, trying to get merged those he has an immediate interest in. He’s also shown an interest in improving the D development process as a whole. That, and the fact that he said yes, makes him an ideal candidate for the role. -->

我々は既に仕事をさせています。
最近Nicholas WilsonはPRキューを探し回り、特に興味を引いたもののマージを試みていました。
彼はDの開発プロセス全体の改善にも興味を示していました。
以上のことと、彼自信もYesと言ってくれたという事実から、彼はこの役目の理想的な候補者でした。

<!-- He’ll have two primary goals: preventing active PRs from becoming stale, and reviving PRs that have gone dormant. He’ll also be looking into open Bugzilla issues when he’s got some time to fill. He’ll have the weight of the Foundation behind his finger when he pokes it in the shoulder of anyone who is being unresponsive (and that includes everyone on the core team). Where he is unable to merge a PR himself, he’ll contact the people he needs to make it happen. -->

彼には主に2つの目標があります。
アクティブなPRの維持と、休止中のPRの復活です。
時間がある時はオープンなBugzillaのissueも見ます。
反応を返さない人の肩を小突く時、彼の指には財団（とコアチーム全員）の影響力が乗っています。
彼がPRをマージできないとなった時には、行動して欲しい人に連絡します。

<!-- Click on the campaign card below and you’ll be taken to the campaign page. Our target is $3,000 by February, 14. If we exceed that goal, the overage will go toward the next three\-month cycle should we continue. If we decide not to continue, overage will go to the General Fund. -->

下のキャンペーンカードをクリックするとキャンペーンページに飛びます。
目標は2月14日までに3000ドルです。
ゴールを超えた場合、超過分は次の3ヶ月に回されます。
我々が継続をしないと決めた場合、超過分はGeneral Fundに回されます。

<iframe style="height: 325px;width: 300px;border: medium none;" src="https://www.flipcause.com/embed/html_widget/NDUwNTY="></iframe>

<!-- Note that there are options for recurring donations that go beyond the campaign period. All donations through any campaign we launch through Flipcause go to the D Language Foundation’s account. In other words, they aren’t tied specifically to a single campaign. If you choose to initiate a recurring donation through any of our campaigns, you’ll be helping us meet our goal for that campaign and, once the campaign ends, your donations will go toward our general fund. If you do set up a monthly or quarterly donation, leave a note if you want to continue putting it toward paying the PR manager and we’ll credit it toward future PR manager campaigns. -->

キャンペーン期間を超えて継続的に寄付することもできます。
我々がFlipcauseでおこす全てのキャンペーンへの寄付はD言語財団のアカウントに届きます。
言い換えると、1つのキャンペーンに縛られることはありません。
キャンペーンを通じて継続支援を始めたなら、そのキャンペーンの目標を支援し、
なおかつキャンペーンが終了した後は寄付がGeneral Fundに送られます。
毎月または毎四半期の寄付をセットするとき、
PR管理者への給与支払いの支援をし続けたい場合は書いておいてくれれば、
それを将来のPR管理者キャンペーンに使います。

<!-- When you’re viewing the blog on a desktop system, you’ll be able to see all of our active campaigns by clicking on the Donate Now button that I’ve added to the sidebar. Of course, the other donation options that have always been supported [are still available from the donation page](https://dlang.org/foundation/donate.html), accessible through the menu bar throughout dlang.org. -->

このブログ（訳注：[dlang.org/blog](https://dlang.org/blog)）をデスクトップ環境で見ている場合、
サイドバーに追加されたDonate Nowボタンをクリックするとアクティブなすべてのキャンペーンを見ることができます。
もちろん、現在行われている他の寄付も
[寄付のページから行うことができて](https://dlang.org/foundation/donate.html)、
dlang.org全体を通してメニューバーからアクセスできます。

<!-- Thanks to Nicholas for agreeing to take on this job, and thanks in advance to everyone who supports us in getting it done! -->

最後に、仕事を引き受けてくれたNicholas、それとこれから支援をしてくれる皆さんに感謝します！