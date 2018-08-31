---
date: 2017-04-26
title: "Dのメタプログラミングは面白くない - C++との比較【翻訳】"
tags:
- dlang
- tech
- translation
excerpt: "講演者の静かな声と、ほとんどC++のコードのみを映し出すスライド(通常キーノートで期待していたものではありません)にもかかわらず、 Louis DionneのMeeting C++ 2016でのメタプログラミングについてのトーク は本当に面白いものでした。"
---

この記事は、

[Metaprogramming is less fun in D](https://epi.github.io/2017/03/18/less_fun.html)

を自分用に翻訳したものを
[許可を得て](https://epi.github.io/2017/03/18/less_fun.html#comment-3271891957)
公開するものである。
コードのコメントも翻訳してある。
[ソース](https://raw.githubusercontent.com/{{ site.github.repository_nwo }}/{{ site.github.source.branch }}/{{ page.path }})に原文を併記してあるので、誤字や誤訳などを見つけたら今すぐ
[Pull request](https://github.com/{{ site.github.repository_nwo }}/edit/{{ site.github.source.branch }}/{{ page.path }})だ!

---

<!-- Despite the speaker's calm voice and the slides showing almost nothing but
code in C++ (which isn't what you'd normally expect from a keynote),
Louis Dionne's [talk on metaprogramming at Meeting C++ 2016](https://www.youtube.com/watch?v=X_p9X5RzBJE)
was a truly exciting one. -->

講演者の静かな声と、ほとんどC++のコードのみを映し出すスライド(通常キーノートに期待するものではありません)にもかかわらず、
Louis Dionneの[Meeting C++ 2016でのメタプログラミングについてのトーク](https://www.youtube.com/watch?v=X_p9X5RzBJE)
は本当に面白いものでした。

<!-- It's been years since last time I did some metaprogramming in C++, and
this talk brought me back old memories of that feeling when I'd put
together some incredibly clever pieces of template black magic
and it finally worked. _Oh, that was soo cunning. I'm the best hacker._
I'm sure you know that feeling too. -->

私が最後にC++でメタプログラミングをしてから何年も立ち、
私がテンプレートの信じられないほど巧妙な黒魔術の数々をまとめて、ついにそれを動かした時の古い記憶、感情をこのトークは思い起こさせました。
**なんて狡猾なんだろう、私は最高のハッカーだ。**
あなたもその気持ちを知っているでしょう。

<!-- I was happy to learn that the picture has changed significantly since that time,
and cluttering the code with many nested levels of angle brackets
adorned here and there with some double colons is no longer the thing.
With [Hana](http://www.boost.org/doc/libs/release/libs/hana/)
you basically write code that looks
like your usual runtime function or operator calls, but under the hood
these functions are generics that operate on the information
carried in types of their arguments. There's no run-time
state involved in these operations, so in the generated machine code
they are all optimized out. Impressive. -->

私は状況が大きく変わったことを知って嬉しかったです。
ダブルコロンによってあちこち装飾された、何重にもネストした山括弧でコードを散らかすことはもはや一般的ではありません。
[Hana](http://www.boost.org/doc/libs/release/libs/hana/)によって
あなたは普通のランタイム関数またはオペレーターコールのように見えるコードを書きますが、その関数は裏ではそれらの引数の型からの情報に作用するジェネリクスになります。
実行時の状態はこれらの操作に関係せず、生成されるマシンコードはすべて最適化されます。
素晴らしい。

<!-- ## Case study: Event system -->

### ケーススタディ:イベントシステム

<!-- Let's take a look at the example discussed in the talk (starting at about 38:30).
If you've watched it already, you can [skip this part](#better).
I'll copy the entire example here so that it's close at hand for
reference in further discussion. -->

このトークで議論されている例(だいたい38:30に始まります)を見てみましょう。
あなたがそれをすでに見ているならば、[このパートをスキップする](#better)こともできます。
これ以降の議論で参考になるよう、私はここにサンプルの全体をコピーします。

<!-- Consider an event system that identifies events by their names.
We can register any number of callbacks (handlers) to be called when an
event is triggered. Later, we trigger the events,
expecting that all callbacks registered for a given event will execute. -->

名前でイベントを識別するイベントシステムを考えてみましょう。
イベントが発生した時に呼ばれるコールバック(ハンドラ)を複数登録することができます。
その後イベントを発生させると、そのイベントに登録されたすべてのコールバックが実行されます。

<!-- {% highlight c++ %}
int main() {
  event_system events({"foo", "bar", "baz"});

  events.on("foo", []() { std::cout << "foo triggered!" << '\n'; });
  events.on("foo", []() { std::cout << "foo again!" << '\n'; });
  events.on("bar", []() { std::cout << "bar triggered!" << '\n'; });
  events.on("baz", []() { std::cout << "baz triggered!" << '\n'; });

  events.trigger("foo");
  events.trigger("baz");
  // events.trigger("unknown"); // WOOPS! Runtime error!
}
{% endhighlight %} -->

```cpp
int main() {
  event_system events({"foo", "bar", "baz"});

  events.on("foo", []() { std::cout << "foo triggered!" << '\n'; });
  events.on("foo", []() { std::cout << "foo again!" << '\n'; });
  events.on("bar", []() { std::cout << "bar triggered!" << '\n'; });
  events.on("baz", []() { std::cout << "baz triggered!" << '\n'; });

  events.trigger("foo");
  events.trigger("baz");
  // events.trigger("unknown"); // おっと!ランタイムエラーです!
}
```

<!-- We start with a Java-style run-time only implementation. We use a hash map
to find a vector of functions to call given an event name. Initially,
an empty vector is inserted into the map for each known event. -->

Javaスタイルの実行時のみの実装から始めましょう。
イベント名に応じた関数のvectorを探すためにハッシュマップを使います。
はじめ、空のvectorが各イベントのマップに挿入されています。

<!-- {% highlight c++ %}
struct event_system {
  using Callback = std::function<void()>;
  std::unordered_map<std::string, std::vector<Callback>> map_;

  explicit event_system(std::initializer_list<std::string> events) {
    for (auto const& event : events)
      map_.insert({event, {}});
  }
{% endhighlight %} -->

```cpp
struct event_system {
  using Callback = std::function<void()>;
  std::unordered_map<std::string, std::vector<Callback>> map_;

  explicit event_system(std::initializer_list<std::string> events) {
    for (auto const& event : events)
      map_.insert({event, {}});
  }
```

<!-- Now, to register a callback, we find the right vector in the map, and push
the callback at its end. -->

コールバックを登録するために、マップから正しいvectorを探し、その末尾にコールバックをプッシュします。


<!-- {% highlight c++ %}
  template <typename F>
  void on(std::string const& event, F callback) {
    auto callbacks = map_.find(event);
    assert(callbacks != map_.end() &&
      "trying to add a callback to an unknown event");

    callbacks->second.push_back(callback);
  }
{% endhighlight %} -->

```cpp
  template <typename F>
  void on(std::string const& event, F callback) {
    auto callbacks = map_.find(event);
    assert(callbacks != map_.end() &&
      "trying to add a callback to an unknown event");

    callbacks->second.push_back(callback);
  }
```

<!-- Finally, triggering an event causes calling all callbacks in the vector for
the specified event. -->

そしてイベントを発生させるとそのイベントのvectorの中にあるすべてのコールバックが呼ばれます。

<!-- {% highlight c++ %}
  void trigger(std::string const& event) {
    auto callbacks = map_.find(event);
    assert(callbacks != map_.end() &&
      "trying to trigger an unknown event");

    for (auto& callback : callbacks->second)
      callback();
  }
{% endhighlight %} -->

```cpp
  void trigger(std::string const& event) {
    auto callbacks = map_.find(event);
    assert(callbacks != map_.end() &&
      "trying to trigger an unknown event");

    for (auto& callback : callbacks->second)
      callback();
  }
```

<!-- That's all well and good, but frequently it's already known at design time
what the possible events are and when they should be triggered.
So why do we have to pay for the search in map each time we trigger an event?
And worse, if we mistype the name of an event, we may be unlucky enough
to only know it when it's too late. -->

これでもいいのですが、発生しうるイベントには何があるか、それがいつ発生するべきかはたいてい設計時点でわかっています。
ならば、イベントが発生するたびに毎回マップを検索するコストを払う必要はないでしょう？
更に悪いことに、イベントの名前を打ち間違えた場合、運が悪いと手遅れになってから気づくことになります。

<!-- ## Compile-time lookup -->

### コンパイル時ルックアップ

<!-- Hana can save us such annoyances by allowing us to do the lookup at compile
time, with only cosmetic changes to the above code. First, we update the call site
with compile-time string literals in place of the run-time ones. -->

Hanaは上のコードをちょっと修正するだけでコンパイル時のルックアップを可能にし、そのような苛立ちから我々を救ってくれます。
まず、実行時のそれと同じ場所のコンパイル時文字列リテラルによってコールサイトを書き換えます。

<!-- {% highlight c++ %}
int main() {
  auto events = make_event_system("foo"_s, "bar"_s, "baz"_s);

  events.on("foo"_s, []() { std::cout << "foo triggered!" << '\n'; });
  events.on("foo"_s, []() { std::cout << "foo again!" << '\n'; });
  events.on("bar"_s, []() { std::cout << "bar triggered!" << '\n'; });
  events.on("baz"_s, []() { std::cout << "baz triggered!" << '\n'; });
  // events.on("unknown"_s, []() {}); // compiler error!

  events.trigger("foo"_s); // no overhead
  events.trigger("baz"_s);
  // events.trigger("unknown"_s); // compiler error!
}
{% endhighlight %} -->

```cpp
int main() {
  auto events = make_event_system("foo"_s, "bar"_s, "baz"_s);

  events.on("foo"_s, []() { std::cout << "foo triggered!" << '\n'; });
  events.on("foo"_s, []() { std::cout << "foo again!" << '\n'; });
  events.on("bar"_s, []() { std::cout << "bar triggered!" << '\n'; });
  events.on("baz"_s, []() { std::cout << "baz triggered!" << '\n'; });
  // events.on("unknown"_s, []() {}); // コンパイルエラー!

  events.trigger("foo"_s); // オーバーヘッドはありません
  events.trigger("baz"_s);
  // events.trigger("unknown"_s); // コンパイルエラー!
}
```

<!-- Note the `_s` suffix on all event names. It requires a
[special string literal operator](http://www.boost.org/doc/libs/1_63_0/libs/hana/doc/html/structboost_1_1hana_1_1string.html#ad77f7afff008c2ce15739ad16a8bf0a8)
which will probably make it into the C++ standard in 2020, but it's
already implemented in Clang and GCC, so why not using it now?
The operator builds a stateless object
where the string itself is stored in the object's type, e.g.
`"foo"_s` becomes an instance of `hana::string<'f', 'o', 'o'>`. -->

各イベント名の`_s`サフィックスに注目してください。
それはおそらく2020年にC++標準になるであろう
[特殊文字列リテラルオペレータ](http://www.boost.org/doc/libs/1_63_0/libs/hana/doc/html/structboost_1_1hana_1_1string.html#ad77f7afff008c2ce15739ad16a8bf0a8)
を必要としますが、ClangとGCCではすでに実装されています。
使わない理由はありませんね?
このオペレータは文字列をオブジェクトの型に持つステートレスなオブジェクトを構築します。
たとえば`"foo"_s`は`hana::string<'f', 'o', 'o'>`のインスタンスになります。

<!-- ### Implementation with hana::map -->

#### hana::mapでの実装

<!-- Now let's replace the run-time map with `hana::map`,
declaring a vector of callbacks for each event with a bit of
[template parameter pack expansion magic](http://en.cppreference.com/w/cpp/language/parameter_pack). -->

実行時マップを、各イベントのコールバックのvectorをちょっとした
[テンプレートパラメータパック拡張マジック](http://en.cppreference.com/w/cpp/language/parameter_pack)
で宣言する`hana::map`で置き換えましょう。

<!-- {% highlight c++ %}
template <typename ...Events>
struct event_system {
  using Callback = std::function<void()>;
  hana::map<hana::pair<Events, std::vector<Callback>>...> map_;
{% endhighlight %} -->

```cpp
template <typename ...Events>
struct event_system {
  using Callback = std::function<void()>;
  hana::map<hana::pair<Events, std::vector<Callback>>...> map_;
```

<!-- Now we can just default construct the `event_system`, which will
default construct `map_`, and
consequently all the vectors of callbacks it contains
will be initialized to empty vectors. -->

これでデフォルトで`event_system`が構築し、デフォルトで`map_`を構築することができ、
その結果として含まれるすべてのコールバックのvectorが空のvectorに初期化されます。

<!-- {% highlight c++ %}
template <typename ...Events>
event_system<Events...> make_event_system(Events ...events) {
  return {};
}
{% endhighlight %} -->

```cpp
template <typename ...Events>
event_system<Events...> make_event_system(Events ...events) {
  return {};
}
```

<!-- Finally, we replace the run-time lookup with its compile-time equivalent. -->

最終的に、実行時ルックアップをコンパイル時のそれと置き換えます。

<!-- {% highlight c++ %}
  template <typename Event, typename F>
  void on(Event e, F callback) {
    auto is_known_event = hana::contains(map_, e);
    static_assert(is_known_event,
      "trying to add a callback to an unknown event");

    map_[e].push_back(callback);
  }

  template <typename Event>
  void trigger(Event e) const {
    auto is_known_event = hana::contains(map_, e);
    static_assert(is_known_event,
      "trying to trigger an unknown event");

    for (auto& callback : map_[e])
      callback();
  }
{% endhighlight %} -->

```cpp
  template <typename Event, typename F>
  void on(Event e, F callback) {
    auto is_known_event = hana::contains(map_, e);
    static_assert(is_known_event,
      "trying to add a callback to an unknown event");

    map_[e].push_back(callback);
  }

  template <typename Event>
  void trigger(Event e) const {
    auto is_known_event = hana::contains(map_, e);
    static_assert(is_known_event,
      "trying to trigger an unknown event");

    for (auto& callback : map_[e])
      callback();
  }
```

<!-- What happens here is that the vector that should be accessed is determined
at compile time, and each instantiation of the function templates
above just accesses its own vector. We expect that there's no additional run-time
cost compared to hand written functions for each event, e.g. -->

アクセスすべきvectorはコンパイル時に決定され、上記の各関数テンプレートのインスタンス化はそのvectorにアクセスするだけです。
たとえば下のように各イベントの関数を手書きするのと比べて追加の実行時コストはないでしょう。

<!-- {% highlight c++ %}
  template <typename F>
  void trigger_foo(F callback) {
    for (auto& callback : callbacks_foo)
      callback();
  }
{% endhighlight %} -->

```cpp
  template <typename F>
  void trigger_foo(F callback) {
    for (auto& callback : callbacks_foo)
      callback();
  }
```

<!-- If your application triggers events frequently, changing from dynamic to static
dispatch may result in a noticeable speedup. The chart below
shows the time to call `trigger` for an event with exactly one callback
registered. With compile-time lookup based on `hana::map` it's about 14 times
faster than run-time lookup in `unordered_map`, and only about 15% slower
than just calling an `std::function`. -->

アプリケーションがイベントを頻繁に発生させるとき、動的なディスパッチを性的なものに置き換えると顕著な高速化になります。
下のチャートは1つのコールバックが登録されているイベントの`trigger`を呼ぶ時間を表しています。
`hana::map`を基にしたコンパイル時ルックアップは大体`unordered_map`の実行時ルックアップの14倍速く、
ただ`std::function`を呼び出すことと比べて15%遅いだけです。

<!-- ![Event system performance: D vs. C++](/img/cppdmeta/hana.svg) -->

![Event system performance: D vs. C++](/assets/2017/04/26/hana.svg)

<!-- ### You can have both at the same time -->

### 両方を同時に得る

<!-- There are cases in which the event to be triggered will be decided only
at run time, e.g.: -->

発生するイベントが実行時にのみ決まる場合があります。たとえば:

<!-- {% highlight c++ %}
  std::string e = read_from_stdin();
  events.trigger(e);
{% endhighlight %} -->

```cpp
  std::string e = read_from_stdin();
  events.trigger(e);
```

<!-- Our event system can be easily extended to handle such cases.
Just like in the first version with run-time only lookup, we use an
unordered map. We don't want to store the callback vectors twice, so
the values in the map are pointers to vectors already stored inside the
static map. -->

このイベントシステムはそのようなケースをハンドリングするために容易に拡張できます。
最初の実行時オンリールックアップを使ったバージョンのように、unordered mapを使います。
コールバックvectorを2重に持ちたくないため、マップの値はすでに静的マップに保存されているvectorへのポインタです。

<!-- {% highlight c++ %}
  std::unordered_map<std::string, std::vector<Callback>* const> dynamic_;

  event_system() {
    hana::for_each(hana::keys(map_), [&](auto event) {
      dynamic_.insert({event.c_str(), &map_[event]});
    });
  }
{% endhighlight %} -->

```cpp
  std::unordered_map<std::string, std::vector<Callback>* const> dynamic_;

  event_system() {
    hana::for_each(hana::keys(map_), [&](auto event) {
      dynamic_.insert({event.c_str(), &map_[event]});
    });
  }
```

<!-- Being able to trigger the run-time-determined event is now just a matter
of overloading the trigger method that does exactly the same as the
one we had in the pure run-time implementation. -->

実行時に決定するイベントを発生させられるようにするには、純実行時実装と同じようにトリガメソッドをオーバーロードするだけです。

<!-- {% highlight c++ %}
  void trigger(std::string const& event) {
    auto callbacks = dynamic_.find(event);
    assert(callbacks != dynamic_.end() &&
      "trying to trigger an unknown event");

    for (auto& callback : *callbacks->second)
      callback();
  }
{% endhighlight %} -->

```cpp
  void trigger(std::string const& event) {
    auto callbacks = dynamic_.find(event);
    assert(callbacks != dynamic_.end() &&
      "trying to trigger an unknown event");

    for (auto& callback : *callbacks->second)
      callback();
  }
```

<!-- <a name="better"></a> -->

<a name="better"></a>

<!-- ## _Can we do better_? -->

### **もっとうまくできないか?**

<!-- At this point in the talk (59:30) you'll hear Louis saying: -->

トークのこの時点(59:30)で、Louisがこう言っています:

<!-- > All I need to support compile-time and run-time lookup is a single overload.
> That is pretty powerful, and I do not know any other language that allows me to do that. -->

> コンパイル時と実行時のルックアップのサポートに必要なのはシングルオーバーロードです。
> それは非常に強力で、私は他にそれが可能な言語を知りません。

<!-- It was obvious to me that [D](http://dlang.org/)
could do it better, and it took me about 10 minutes to sketch an equivalent
implementation.
But I can understand: if I were to advertise effects of years of hard work
I'd done, I wouldn't want people to look for something else. ;) -->

[D言語](http://dlang.org/)がそれをもっとうまくできるのは明らかでした、10分で同等の実装を作ることができました。
しかし私は理解できます: もし私が何年もの努力の積み重ねの結果を宣伝するならば、私は人々が他のものを探すことを望みません。 ;)

<!-- Don't you know D? You could've heard of it as "C++ done right", but that's not entirely
true. D also has its own baggage of bad decisions and quirks.
Over time, it's collected ad-hoc standard library additions in completely different styles.
Its documentation is sometimes outdated or misses that one thing you're looking for.
Its community and the support it receives from the industry are
incomparably smaller to that received by C++.
But leaving all of that aside, after years of using D for various tasks,
I must agree that it really lives up to its promise of being ["a practical language for practical programmers who need to get the job done quickly,
reliably, and leave behind maintainable, easy to understand code."](https://dlang.org/overview.html) -->

Dをご存じでない?
「ちゃんとしたC++」として聞いたことがあるかもしれませんが、それは完全には真実ではありません。
Dは悪い決定の荷物や癖を抱えてもいます。
時間の経過とともに、全く異なるスタイルの追加がアドホックな標準ライブラリに集まってきます。
ドキュメントは時に時代遅れになっているか、探しているものが抜けています。
そのコミュニティも、それが業界から受けたサポートもC++で受けたそれとは比較にならないほど小さなものです。
しかしそのすべてをさておいて、何年もDを様々なタスクに使用した上で、
["信頼性・保守性の高い・読みやすいコードを書いて仕事をサクサク進める必要のある 現実的なプログラマのための、 現実的な言語"](https://dlang.org/overview.html) [^1]
であるという約束に恥じないものであるということに私は同意せざるを得ません。

[^1]: 訳注: 訳を[こちら](http://www.kmonos.net/alang/d/overview.html)から引用しました

<!-- So let's see if D can do The Overload Trick and at least
match the C++/Hana duo in expressiveness in this use case. -->

そこで、Dがこのオーバーロードトリックをすることができ、表現力でC++/Hanaの組み合わせと少なくともこのユースケースで肩を並べるものかどうか見てみましょう。

<!-- ### Interface -->

#### インターフェース

<!-- Let's start with what we expect at the call site. -->

コールサイトで期待されるものから始めましょう。

<!-- {% highlight d %}
void main() {
  EventSystem!("foo", "bar", "baz") events;

  events.on!"foo"(() { writeln("foo triggered!"); });
  events.on!"foo"(() { writeln("foo again!"); });
  events.on!"bar"(() { writeln("bar triggered!"); });
  events.on!"baz"(() { writeln("baz triggered!"); });
  // events.on!"unknown"(() {}); // compile error!

  events.trigger!"foo";
  events.trigger!"baz";
  events.trigger("bar"); // overload for dynamic dispatch
  // events.trigger!"unknown"; // compile error!
}
{% endhighlight %} -->


```d
void main() {
  EventSystem!("foo", "bar", "baz") events;

  events.on!"foo"(() { writeln("foo triggered!"); });
  events.on!"foo"(() { writeln("foo again!"); });
  events.on!"bar"(() { writeln("bar triggered!"); });
  events.on!"baz"(() { writeln("baz triggered!"); });
  // events.on!"unknown"(() {}); // コンパイルエラー!

  events.trigger!"foo";
  events.trigger!"baz";
  events.trigger("bar"); // 動的ディスパッチのオーバーロード
  // events.trigger!"unknown"; // コンパイルエラー!
}
```

<!-- It looks pretty similar to what we had in C++.
The most important difference is that
in D, there's no special syntax for compile-time strings, and regular strings
can be passed as template parameters.
For this reason, the idea of stateless objects
with strings encoded in types won't add any value here (but it is
technically possible to implement it, see below). -->

C++でやったのとなかなか良く似ています。
Dでの最も重要な違いは、コンパイル時文字列のための特殊なシンタックスがなく、普通の文字列がテンプレートパラメータとして渡せることです。
そのため、型でエンコードされた文字列によるステートレスなオブジェクトのアイデアは意味がありません
(しかし実装することは技術的に可能です。下を見てください)。

<!-- The `EventSystem` struct template can
be instantiated by just passing the event names as arguments,
and the default static initializers are sufficient for all its
members, so there's no need for a factory function. -->

`EventSystem`構造体テンプレートはただイベント名を引数として渡すだけでインスタンス化でき、
すべてのメンバがデフォルト静的初期化子で事足り、ファクトリ関数を必要としません。

<!-- Function templates `on` and `trigger` also accept compile-time `string`s.
Since each string is a single token, the parentheses around the
template argument lists can be skipped, just as those around
an empty run-time argument list. This minor syntactic quirk
turned `trigger!("foo")()` into less cluttered `trigger!"foo"`. -->

関数テンプレート`on`と`trigger`はコンパイル時`string`も受け入れます。
各文字列はシングルトークンのため、空の実行時引数リストと同じように、テンプレート引数リストの括弧は省略することができます。
この小さな構文の特徴は`trigger!("foo")()`をより乱雑さのない`trigger!"foo"`にします。

<!-- The distiction between run-time and compile-time arguments is preserved
with regular language rules. You don't need to remember that in this 
particular case  the `_s` suffix implies a compile-time entity.
Note that we trigger `foo` and `baz` via static dispatch, but we also
expect that an overload is available that accepts a run-time
evaluated event name when we trigger `bar`. -->

実行時とコンパイル時引数の区別は、標準の言語規則で決まっています。
`_s`サフィックスがコンパイル時エンティティを暗示する特殊なケースを覚えておく必要はありません。
`foo`や`baz`を静的ディスパッチで発生させることに注目してください。
しかし`bar`を発生させるとき、実行時に評価されるイベント名を受け入れるオーバーロードも利用できるでしょう。

<!-- ### Compile-time lookup -->

#### コンパイル時ルックアップ

<!-- Now on to the implementation: -->

ここから実装です:

<!-- {% highlight d %}
struct EventSystem(events...) {
  alias Callback = void delegate();
  Callback[][events.length] callbacks_;   // like std::array<std::vector<Callback>, sizeof...(events)> in C++
{% endhighlight %} -->

```d
struct EventSystem(events...) {
  alias Callback = void delegate();
  Callback[][events.length] callbacks_;   // C++の std::array<std::vector<Callback>, sizeof...(events)> のようなもの
```

<!-- There's no equivalent of `hana::map` in [Phobos](http://dlang.org/phobos/),
but since all values in the map are of the same type, we can
declare a fixed-length array of them and use
[`staticIndexOf`](https://dlang.org/phobos/std_meta.html#staticIndexOf)
to map event names to indices in the array. The [argument list](http://dlang.org/ctarguments.html)
that this struct template receives as `events...` may include various compile-time
entities, including types, template names, constant values of different primitive
or composite types. In particular, `string`s will do just fine.  -->

[Phobos](http://dlang.org/phobos/)には`hana::map`と同等のものはありません。
しかしマップ内のすべての値は同じ型のため、その固定長配列を宣言し、イベント名を配列のインデックスに対応させるために
[`staticIndexOf`](https://dlang.org/phobos/std_meta.html#staticIndexOf)を使うことができます。
`events...`としてこの構造体テンプレートが受け取る[引数リスト](http://dlang.org/ctarguments.html)は型や、
テンプレート名、異なるプリミティブまたはコンポジット型の定数を含む様々なコンパイル時エンティティを含みます。
特に、文字列はうまく行くでしょう。

<!-- The implementation of `on` and `trigger` also looks pretty
similar to the C++ version, except that first we look for the index
of the requested vector of callbacks, and then get the vector from the
array via this index. -->

`on`と`trigger`の実装もC++バージョンとよく似ていますが、
これは要求されたコールバックのvectorのインデックスを探し、そのインデックスを介して配列からvectorを取得します。

<!-- {% highlight d %}
  void on(string event)(Callback c) {
    enum index = staticIndexOf!(event, events);
    static assert(index >= 0,
      "trying to add a callback to an unknown event: " ~ event);

    callbacks_[index] ~= c;
  }

  void trigger(string event)() {
    enum index = staticIndexOf!(event, events);
    static assert(index >= 0,
      "trying to trigger an unknown event: " ~ event);

    foreach (callback; callbacks_[index])
      callback();
  }
{% endhighlight %} -->

```d
  void on(string event)(Callback c) {
    enum index = staticIndexOf!(event, events);
    static assert(index >= 0,
      "trying to add a callback to an unknown event: " ~ event);

    callbacks_[index] ~= c;
  }

  void trigger(string event)() {
    enum index = staticIndexOf!(event, events);
    static assert(index >= 0,
      "trying to trigger an unknown event: " ~ event);

    foreach (callback; callbacks_[index])
      callback();
  }
```

<!-- Note the `enum` in place where C++ version used `auto`. The type is
also inferred automatically, but using `enum` forces `index` to be
computed at compile time and only then it can be used in `static assert`. -->

C++バージョンで`auto`を使用していた場所の`enum`に注目してください。
この型も自動的に推論されますが、`enum`を使うと`index`をコンパイル時に計算することが強制され、
`static assert`でのみ使用することができます。

<!-- The lookup (compile-time linear search with `staticIndexOf`) is done only once
per instantiation (i.e. once per key),
and there is no run-time cost associated with it.
Also, indexing the array via statically known index doesn't
add any run-time overhead. -->

このルックアップ(`staticIndexOf`によるコンパイル時線形探索)はインスタンス化あたり(つまりキーあたり)一度のみ行われ、
結びつける実行時コストはありません。
また、静的に判明するインデックスによる配列のインデクシングには実行時のオーバヘッドはありません。

<!-- ### Overloading trigger() -->

#### trigger()のオーバーロード

<!-- And now, the overload of `trigger` accepting a dynamic key.
There's nothing unusual in having both template and non-template
overloads side by side, so let's focus only on the implementation of run-time lookup.
One way would be to use a [built-in associative array](https://dlang.org/spec/hash-map.html),
populated during construction of the map object (you can try it yourself),
but for a small number of keys, a linear search comparing the
requested key with all known keys shouldn't be much worse. -->

そして、動的なキーを受け付けるよう`trigger`をオーバーロードします。
テンプレートと非テンプレートオーバーロードの両方が隣り合って有るのは珍しいことではないため、
実行時ルックアップの実装のみに専念しましょう。
マップオブジェクトの構築中にある(自分で試すことができます)
[組み込み連想配列](https://dlang.org/spec/hash-map.html)を使うこともできますが、
少数のキーに対しては、すべてのキーと要求されたキーとを比較する線形探索でもそんなに悪くないはずです。

<!-- {% highlight d %}
  void trigger(string event) {
    foreach (i, e; events) {
      if (event == e) {
        foreach (c; callbacks_[i])
          c();
        return;
      }
    }
    assert(false, "trying to trigger an unknown event: " ~ event);
  }
{% endhighlight %} -->

```d
  void trigger(string event) {
    foreach (i, e; events) {
      if (event == e) {
        foreach (c; callbacks_[i])
          c();
        return;
      }
    }
    assert(false, "trying to trigger an unknown event: " ~ event);
  }
```

<!-- What's going on here? The outer `foreach` iterates over `events`
which is a compile-time tuple of `string`s. It's not really a loop--the
compiler pastes the body of this _static_ `foreach` once for each
element of the tuple, substituting that element for `e` and its index
for `index`. The result is as if we have three `if`s one after another: -->


何が起きているのでしょう?
外側の`foreach`は、`string`のコンパイル時タプルである`events`をイテレートしています。
これは本当はループではありません – コンパイラはこの**静的**`foreach`の本文を一度タプルの各要素に対してペーストし、
その要素を`e`に、インデックスを`index`に置き換えます。
結果としてまるで3つの`if`が連続してあるようになります:

<!-- {% highlight d %}
      if (event == "foo") {
        foreach (callback; callbacks_[0])
          callback();
        return;
      }
      if (event == "bar") {
        foreach (callback; callbacks_[1])
          callback();
        return;
      }
      if (event == "baz") {
        foreach (callback; callbacks_[2])
          callback();
        return;
      }
{% endhighlight %} -->

```d
      if (event == "foo") {
        foreach (callback; callbacks_[0])
          callback();
        return;
      }
      if (event == "bar") {
        foreach (callback; callbacks_[1])
          callback();
        return;
      }
      if (event == "baz") {
        foreach (callback; callbacks_[2])
          callback();
        return;
      }
```

<!-- ### One-on-one -->

#### 1対1

<!-- That's all. You can [download both versions](/files/cppdmeta.tar.gz),
stare at the code for a while and compile them.
The D version can be compiled with DMD, GDC or LDC. On my machine, it
consistently compiles noticeably faster than the C++ one (minimum of 10
consecutive attempts, all compiled on x86_64 with -O3): -->

これで全てです。
[両方のバージョンをダウンロードし](https://epi.github.io/files/cppdmeta.tar.gz)、しばらくコードを眺めコンパイルすることができます。
DバージョンはDMD、GDCまたはLDCでコンパイルできます。
私のマシン上では、C++のそれと比べて著しく速くコンパイルされました(最低10回の連続試行、すべてx86_64で-O3でコンパイル):

<!-- |            |  C++ (g++, clang++)  |     D (gdc, ldc2)  |
|------------|:------:|:-------:|
|GCC/GDC   6.2.0 |  0.98s |   0.45s |
|Clang 3.9.1/LDC 1.1.0 |  1.09s |   0.67s | -->

|                      |  C++ (g++, clang++)  |     D (gdc, ldc2)  |
|----------------------|:--------------------:|:------------------:|
|GCC/GDC   6.2.0       |  0.98s               |   0.45s            |
|Clang 3.9.1/LDC 1.1.0 |  1.09s               |   0.67s            |

<!-- I wouldn't draw any serious conclusions from the time it takes to
compile a tiny toy program, but in general,
[D was designed for fast compilation](http://www.drdobbs.com/cpp/increasing-compiler-speed-by-over-75/240158941),
not to mention that the volume of library code brought in
is much smaller. -->

小さなトイプログラムのコンパイルにかかる時間から重要な結論を引き出すことはできませんが、一般的に、
[Dは高速なコンパイルができるよう設計されており](http://www.drdobbs.com/cpp/increasing-compiler-speed-by-over-75/240158941)、
取り込まれるライブラリコードの量がはるかに少ないというのは言うまでもありません。

<!-- And what if we mistyped a name of an event? The D frontend (common for
all 3 major compilers) tries to balance
between the volume and usefulness of error messages, and here
it does the job very well. The only thing we'll see is: -->

そしてイベントの名前を打ち間違えた時どうなるか?
Dフロントエンド(3つの主要なコンパイラ全てで共通)はエラーメッセージの量と有用性のバランスを取ろうとし、ここでは非常にうまく機能します。
我々が見ることになるのはこれだけです:

<!-- {% highlight none %}
es.d(23): Error: static assert  "trying to trigger an unknown event: unknown"
es.d(102):        instantiated from here: trigger!"unknown"
{% endhighlight %} -->

```
es.d(23): Error: static assert  "trying to trigger an unknown event: unknown"
es.d(102):        instantiated from here: trigger!"unknown"
```

<!-- And in C++?
In my shell I had to scroll up through about a hundred lines of heavily
punctuated messages to see that important one coming from the `static_assert`
(although with Clang's highlighting it wasn't as bad as with GCC's).
There used to be a tool for transforming C++ error messages into something
digestible for humans. Is it still around? -->

C++ではどうでしょう?
私のシェルでは、`static_assert`からの重要なメッセージを見るために大体100行の大きく強調されたメッセージをスクロールしなければなりませんでした
(ClangのハイライトはGCCのものよりは悪くなかったですが)。
昔はC++のエラーメッセージを人が消化できるものに変換するツールがありました。
あれはまだあるんでしょうか?

<!-- The last thing to check is if we didn't lose performance. In the graph
below you can see the comparison of D vs. C++ version for both
static and dynamic dispatch. The D version seems to be slightly faster
in both cases, but it's only a limited microbenchmark. The D dynamic lookup
might just perform better here because we use a different algorithm
that favors small sets. And the ~10% speedup for the static lookup
most likely comes from `std::function` doing a bit more work
on each call than `delegate` does (check the assembly:
[D](https://godbolt.org/g/kXgIIX),
[C++](https://godbolt.org/g/zFXTHG).) It won't be noticed in a
larger application doing anything meaningful in the callback, so
let's just assume both versions perform equally well. -->

最後にチェックするのはパフォーマンスを失っていないかどうかです。
下のグラフで静的、動的ディスパッチのDバージョン vs. C++バージョンの比較を見ることができます。
Dバージョンは両方のケースで速いように見えますが、これは限られたマイクロベンチマークです。
Dの動的ルックアップは小さなセットを好む違うアルゴリズムを使っているためより良い結果を出しているのかもしれません。
静的ルックアップの~10%のスピードアップは、`std::function`が各コールで`delegate`がするよりも少し多くの仕事をしている可能性が高いです
(アセンブリをチェックしてください: [D](https://godbolt.org/g/kXgIIX)、[C++](https://godbolt.org/g/zFXTHG))。
より大きなアプリケーションではコールバックでなにか意味のあることをしていることには気づきません。
ので、2つのバージョンは同等に良い結果を出していると仮定しましょう。

<!-- ![Event system performance: D vs. C++](/img/cppdmeta/d.svg) -->

![Event system performance: D vs. C++](/assets/2017/04/26/d.svg)

<!-- In conclusion, with D we've achieved a similar result
as in C++, but without resorting to a complex library.
The D implementation looks straightforward, and uses only a few
basic features of the language and standard library.
There's no feeling of being super-clever
nor did I have to learn anything new.
But isn't it exactly what we expect
from _maintainable, easy to understand code_? -->

結論として、Dでは複雑なライブラリに頼ることなくC++と同様の結果が得られました。
Dの実装は明快で、少ない言語の基本機能と標準ライブラリのみを使っています。
超絶クレバーになった感じはせず、新しいことを学ぶ必要もありませんでした。
しかしそれはまさに**保守性の高く、理解しやすい**コードに期待することではないですか?

<!-- So is it really better? There's no absolute scale for that, but
if other factors aren't more important, I'd likely be in favor of
a solution that doesn't rely on an external library,
compiles faster and produces less scary error messages
if something goes wrong. -->

本当により良いのでしょうか?それについて絶対的なものさしはありません、しかし他の要素が比較的重要でない場合は、
おそらく私は外部ライブラリに依存せず、コンパイルが速く、
なにかうまく行かなかった時に恐ろしいエラーメッセージを大量に生成しないソリューションに賛成するでしょう。

<!-- ## hana::map equivalent in D -->

### Dでのhana::map相当のもの

<!-- But what if we wanted a data structure in D that behaves like
`hana::map`?
After all, we won't always have values of the same type, and using
an intermediate integer index feels a little bit unprofessional.
Is it possible? -->

しかしDで`hana::map`のように振る舞うデータストラクチャが必要になったらどうでしょうか?
結局、常に同じ型の値を持つとは限りませんし、整数インデックスを介して使うのはちょっとプロフェッショナルな感じがしません。
これは可能なのでしょうか?

<!-- ### Prerequisites -->

#### 前提条件

<!-- It turns out, the only obstacle is that a compile-time
entity (type or value) cannot be used as a run-time argument to
overloaded indexing operators.
To overcome this,  the same technique as Hana uses can be applied in D.
Consider a struct template parameterized with a single value or type.
I don't know how to name it so let it be an `Entity`. -->

唯一の障害はコンパイル時エンティティ(型または値)はオーバーロードされたインデクシングオペレータへの実行時引数として使えないことであることがわかりました。
これを克服するため、Hanaが使うのと同じ技術をDに適用することができます。
単一の値または型でパラメータ化された構造体テンプレートを考えてみましょう。
私はそれをなんと呼ぶか知らないため、`Entity`としましょう。

<!-- {% highlight d %}
struct Entity(arg...)
  if (arg.length == 1)
{
  static if (is(arg[0])) {
    alias Type = arg[0];
  } else static if (is(typeof(arg[0]) T)) {
    alias Type = T;
    enum value = arg[0];
  }
}
{% endhighlight %} -->

```d
struct Entity(arg...)
  if (arg.length == 1)
{
  static if (is(arg[0])) {
    alias Type = arg[0];
  } else static if (is(typeof(arg[0]) T)) {
    alias Type = T;
    enum value = arg[0];
  }
}
```

<!-- We can instantiate concrete struct types and create objects
by writing e.g. `Entity!"foo"()` or `Entity!double()`.
Such objects have no state, but their
types will select different instantiations of template functions. -->

たとえば`Entity!"foo"()`または`Entity!double()`と書くことで具体的な構造体型をインスタンス化し、オブジェクトを生成できます。
そのようなオブジェクトは状態を持ちませんが、異なるテンプレート関数のインスタンス化をされます。

<!-- Unlike regular function calls, constructing a struct object requires
parentheses, which makes it a bit more verbose than Hana's `_c` and `_s`
suffixes. There is a number of ways to make it more concise,
parameterized `enum` being one of them: -->

普通の関数呼び出しと異なり、構造体オブジェクトの構築には括弧が必要で、Hanaの`_c`や`_s`サフィックスと比べて少し冗長になります。
より簡潔にするにはいくつか方法があり、パラメータ化された`enum`はそのひとつです:

<!-- {% highlight d %}
enum c(arg...) = Entity!arg();

static assert(is(c!int.Type == int));
static assert(is(c!"foo".Type == string));
static assert(c!"foo".value == "foo");
static assert(c!42.value == 42);
{% endhighlight %} -->

```d
enum c(arg...) = Entity!arg();

static assert(is(c!int.Type == int));
static assert(is(c!"foo".Type == string));
static assert(c!"foo".value == "foo");
static assert(c!42.value == 42);
```

<!-- Similar syntax for user-defined literals was reportedly used first
in [`std.conv.octal`](https://dlang.org/phobos/std_conv.html#.octal). -->

ユーザ定義リテラルのよく似たシンタックスが[`std.conv.octal`](https://dlang.org/phobos/std_conv.html#.octal)
で最初に使われたと伝えられています。

<!-- ### Storage for values -->

#### 値の格納

<!-- Now let's get to the map itself. We want something that can store values
of different types
(like [`std.typecons.Tuple`](https://dlang.org/phobos/std_typecons.html#.Tuple),
and where keys are types or compile-time values, instantiated like this: -->

マップそのものに取り掛かりましょう。
異なる型の値を保持でき([std.typecons.Tuple](https://dlang.org/phobos/std_typecons.html#.Tuple)のように)、
キーは型かコンパイル時の値で、このようにインスタンス化される何かがほしいです:

<!-- {% highlight d %}
struct Bar {}
Map!(
  "foo",  int,           // string "foo" maps to a value of type int
  Bar,    string,        // type Bar maps to a value of type string
  "한",   string[]) map; // string "한" maps to a value of type string[]
{% endhighlight %} -->

```d
struct Bar {}
Map!(
  "foo",  int,           // 文字列 "foo" をint型の値にマップします
  Bar,    string,        // 型 Bar をstring型の値にマップします
  "한",   string[]) map; // 文字列 "한" をstring[]型の値にマップします
```

<!-- We need to separate the interleaving keys and value types and declare storage
for the values themselves: -->

不連続なキーと値を分割し、値の記憶域を宣言する必要があります:

<!-- {% highlight d %}
struct Map(spec...) {
  alias Keys = Even!spec;
  alias Values = Odd!spec;
  Values values;
{% endhighlight %} -->

```d
struct Map(spec...) {
  alias Keys = Even!spec;
  alias Values = Odd!spec;
  Values values;
```

<!-- `Even` and `Odd` aren't standard things, but we can quickly implement them
on our own: -->

`Even`と`Odd`は標準のものではありませんが、素早く実装することができます:

<!-- {% highlight d %}
template Stride(size_t first, size_t stride, A...) {
  static if (A.length > first)
    alias Stride = AliasSeq!(A[first], Stride!(stride, stride, A[first .. $]));
  else
    alias Stride = AliasSeq!();
}

alias Odd(A...) = Stride!(1, 2, A);
alias Even(A...) = Stride!(0, 2, A);
{% endhighlight %} -->

```d
template Stride(size_t first, size_t stride, A...) {
  static if (A.length > first)
    alias Stride = AliasSeq!(A[first], Stride!(stride, stride, A[first .. $]));
  else
    alias Stride = AliasSeq!();
}

alias Odd(A...) = Stride!(1, 2, A);
alias Even(A...) = Stride!(0, 2, A);
```

<!-- Now, `values` is a built-in tuple consisting of elements of all types
in the type list `Values`.
It can be indexed using a constant integer, e.g. `map.values[2]`.
It can also be iterated over using the "static `foreach`"
construct we saw before.
That means we've got iteration over keys or values for free. Try: -->

`values`は型リスト`Values`のすべての型の要素からなる組み込みタプルです。
これは`map.values[2]`のように整数定数を使ってインデックスできます。
先ほど見た「静的`foreach`」を使いイテレートすることもできます。
これはキーまたは値を自由にイテレートすることができるということを意味します。
やってみましょう:

<!-- {% highlight d %}
  // initialize via Struct Literal syntax
  auto map =
    Map!("foo", int, Bar, string, "한", string[])(
      42, "baz", ["lorem", "ipsum", "dolor"]);

  // iterate over keys
  foreach (K; map.Keys)
    writeln(K.stringof);

  // iterate over types of values
  foreach (V; map.Values)
    writeln(V.stringof);

  // iterate over values
  foreach (value; map.values)
    writeln(value);
{% endhighlight %} -->

```d
  // 構造体リテラル構文で初期化
  auto map =
    Map!("foo", int, Bar, string, "한", string[])(
      42, "baz", ["lorem", "ipsum", "dolor"]);

  // キーでイテレート
  foreach (K; map.Keys)
    writeln(K.stringof);

  // 値の型でイテレート
  foreach (V; map.Values)
    writeln(V.stringof);

  // 値でイテレート
  foreach (value; map.values)
    writeln(value);
```

<!-- ### Operators -->

#### オペレータ

<!-- Hana offers free function template `contains` to check whether a given key
is in the map. In D, the `in` operator is usually used. It can
be overloaded by implementing
[`opBinaryRight`](https://dlang.org/spec/operatoroverloading.html#binary).
Since it only depends on compile-time information (types of its arguments),
it can be declared `static`: -->

Hanaは与えられたキーがマップに存在するかをチェックするための自由な関数テンプレート`contains`を提供します。
Dでは、ふつう`in`オペレータが使われます。
これは[`opBinaryRight`](https://dlang.org/spec/operatoroverloading.html#binary)
を実装することでオーバーロードすることができます。
それはコンパイル時の情報(引数の型)のみに依存するため、`static`として宣言できます:

<!-- {% highlight d %}
  static bool opBinaryRight(string op, Key...)(Entity!Key key)
    if (op == "in")
  {
    enum index = staticIndexOf!(Key, Keys);
    return index >= 0;
  }
{% endhighlight %} -->

```d
  static bool opBinaryRight(string op, Key...)(Entity!Key key)
    if (op == "in")
  {
    enum index = staticIndexOf!(Key, Keys);
    return index >= 0;
  }
```

<!-- Let's see if it works: -->

動作するのを見てみましょう:

<!-- {% highlight d %}
  static assert(c!"foo" in map);
  static assert(c!Bar in map);
  static assert(c!"한" in map);
  static assert(c!42 !in map);
{% endhighlight %} -->

```d
  static assert(c!"foo" in map);
  static assert(c!Bar in map);
  static assert(c!"한" in map);
  static assert(c!42 !in map);
```

<!-- To look up a value using a compile-time key, we use `staticIndexOf`
and add a meaningful message if the key is not found: -->

コンパイル時キーを使って値をルックアップするには`staticIndexOf`を使い、もしキーが見つからなかった時は意味のあるメッセージを添えます:

<!-- {% highlight d %}
  private template IndexOf(alias Key) {
    enum IndexOf = staticIndexOf!(Key, Keys);
    static assert(IndexOf >= 0,
      "trying to access a nonexistent key: " ~ Key);
  }
{% endhighlight %} -->

```d
  private template IndexOf(alias Key) {
    enum IndexOf = staticIndexOf!(Key, Keys);
    static assert(IndexOf >= 0,
      "trying to access a nonexistent key: " ~ Key);
  }
```

<!-- This can be used to implement indexing operators. Why not a single one?
Unlike in C++, where `operator[]` returns an lvalue reference which can
be further manipulated using e.g. assignment operators, in D the
operators for
[read-only indexing](https://dlang.org/spec/operatoroverloading.html#array),
[indexing with simple assignment](https://dlang.org/spec/operatoroverloading.html#assignment),
and [indexing with compound assignment](https://dlang.org/spec/operatoroverloading.html#op-assign)
are overloaded separately. -->

これはインデクシングオペレーターたちを実装するのに使えます。
なぜ1つではなく「たち」と言ったのか?
`operator[]`が代入演算子のように更に操作できる左辺参照を返すC++とは違い、
Dで[リードオンリーインデクシング](https://dlang.org/spec/operatoroverloading.html#array)、
[単純な代入のインデクシング](https://dlang.org/spec/operatoroverloading.html#assignment)、
[複合代入のインデクシング](https://dlang.org/spec/operatoroverloading.html#op-assign)、
のオペレータは別々にオーバーロードされます。

<!-- {% highlight d %}
  auto opIndex(Key...)(Entity!Key key) const {
    return values[IndexOf!Key];
  }

  auto opIndexAssign(T, Key...)(auto ref T value, Entity!Key key) {
    return values[IndexOf!Key] = value;
  }

  auto opIndexOpAssign(string op, T, Key...)(auto ref T value, Entity!Key key) {
    return mixin(`values[IndexOf!Key] ` ~ op ~ `= value`);
  }
{% endhighlight %} -->

```d
  auto opIndex(Key...)(Entity!Key key) const {
    return values[IndexOf!Key];
  }

  auto opIndexAssign(T, Key...)(auto ref T value, Entity!Key key) {
    return values[IndexOf!Key] = value;
  }

  auto opIndexOpAssign(string op, T, Key...)(auto ref T value, Entity!Key key) {
    return mixin(`values[IndexOf!Key] ` ~ op ~ `= value`);
  }
```

<!-- In all cases, `T` and `Key` are inferred from the types of the arguments.
Evaluation of `IndexOf!Key` and indexing in `values` are both done at compile time.
Let's test it: -->

すべてのケースで、`T`と`Key`は引数の型から推測されます。
`IndexOf!Key`の評価と`values`のインデクシングはともにコンパイル時に完了します。
テストしてみましょう:

<!-- {% highlight d %}
  // compile-time lookup, run-time assignment
  map[c!"foo"] = 42;        // opIndexAssign
  map[c!Bar] = "baz";
  map[c!"한"] ~= "lorem";    // opIndexOpAssign!"~"
  map[c!"한"] ~= "ipsum";
  map[c!"한"] ~= "dolor";

  // compile-time lookup, run-time comparison
  assert(map[c!"foo"] == 42);  // opIndex
  assert(map[c!Bar] == "baz");
  assert(map[c!"한"] == ["lorem", "ipsum", "dolor"]);
{% endhighlight %} -->

```d
  // コンパイル時ルックアップ、実行時代入
  map[c!"foo"] = 42;        // opIndexAssign
  map[c!Bar] = "baz";
  map[c!"한"] ~= "lorem";    // opIndexOpAssign!"~"
  map[c!"한"] ~= "ipsum";
  map[c!"한"] ~= "dolor";

  // コンパイル時ルックアップ、実行時比較
  assert(map[c!"foo"] == 42);  // opIndex
  assert(map[c!Bar] == "baz");
  assert(map[c!"한"] == ["lorem", "ipsum", "dolor"]);
```

<!-- ### Performance -->

#### パフォーマンス

<!-- That's all! We have a map that allows lookup and iteration in compile time
with run-time-like syntax, just like `hana::map`, and it's nothing
special--just a bunch of your everyday trivial one-liners. -->

これで全部です!
我々は`hana::map`のように、実行時風シンタックスでコンパイル時にルックアップとイテレーションができるマップを手にしました。
それは何ら特別なものではありません。
ただの日常の何でもないワンライナーの集まりです。

<!-- You may want to try modifying `EventSystem` to use `Map` that we've
just implemented. If you're impatient, you can find one possible
implementation in [the same archive](/files/cppdmeta.tar.gz).
I couldn't notice any measurable difference in compilation time between
this version and the previous one, and the run-time performance is
also very similar, as shown in the graph below. -->

実装した`Map`を使って`EventSystem`を修正してみたいかもしれません。
我慢できないなら、[同じアーカイブ](https://epi.github.io/files/cppdmeta.tar.gz)に実装があります。
このバージョンと前のバージョンの間でコンパイル時間の計測可能な違いは私には検出できません。
そして下のグラフでわかるように、実行時のパフォーマンスも同じです。

<!-- ![Event system based on static Map in D vs. previous solutions](/img/cppdmeta/dmap.svg) -->

![Event system based on static Map in D vs. previous solutions](/assets/2017/04/26/dmap.svg)

<!-- The question is whether this would be the right design choice in D.
Operators `[]` and `in` are just syntactic sugar that could easily
be replaced with "normal" template functions like `get` and `contains`, making
the awkward `c!arg` unnecessary. Iteration over a list of compile-time
entities or elements of value tuples
is a built-in language feature, and doesn't need it either. -->

問題はこれがDでの正しいデザインチョイスかどうかです。
オペレータ`[]`と`in`は`get`や`contains`のような「普通の」テンプレート関数で簡単に置き換えられる糖衣構文で、
厄介な`c!arg`を作る必要はありません。
コンパイル時エンティティのリストや、値のタプルの要素のイテレーションは組み込み言語機能で、どちらも必要ありません。

<!-- ## Summing up -->

### 要約

<!-- This isn't the first attempt at emulating Hana in D. See for example
[this post on type objects](https://maikklein.github.io/2016/03/01/metaprogramming-typeobject/),
with an interesting example of quicksort on types.
Hana's tricks making metafunctions look like regular run-time code
are applicable in D, but thanks to D's built-in metaprogramming features
they do not substantially improve code readability or programmer
productivity. Until the [new CTFE engine](http://forum.dlang.org/thread/btqjnieachntljobzrho@forum.dlang.org)
is complete and merged, they will probably only [hurt build times](https://forum.dlang.org/post/ntkhtqdoxpvwcatyvbhf@forum.dlang.org)
without giving much in return. -->

これはDでHanaのエミュレートを試みる最初のものではありません。
たとえば[型オブジェクトに関するこの投稿](https://maikklein.github.io/2016/03/01/metaprogramming-typeobject/)
を見てください、型のクイックソートの興味深い例があります。
普通の実行時のコードのように見えるメタ関数を作るHanaのトリックはDにも適用できますが、Dの組み込みメタプログラミング機能のおかげで、
それでコードの可読性やプログラマの生産性が大幅に向上したりはしません。
[新しいCTFEエンジン](http://forum.dlang.org/thread/btqjnieachntljobzrho@forum.dlang.org)
が完成しマージされるまでは、おそらく無用に
[ビルド時間を長くする](https://forum.dlang.org/post/ntkhtqdoxpvwcatyvbhf@forum.dlang.org)
だけです。

<!-- The talk concludes with a few examples of what will be possible
with features proposed for C++20 – named arguments, `foreach` over
a type list, and serialization to JSON with reflection.
You probably won't be surprised that all of this have been possible in D for years,
but with a cleaner syntax and less intellectual effort required, stripping
metaprogramming of all the fun you could have doing it in C++. -->

トークはC++20の提案された機能で可能になることのいくつかの例で締めくくられます。
名前付き引数、型リストのforeach、リフレクションによるJSONへのシリアライズ。
その全てが何年も前にDで、より洗練された構文に、より少ない知的努力によって、メタプログラミングからC++でそれをする時の面白さをすべて取り除いた上で可能だったことなのであなたは驚かないかもしれません。