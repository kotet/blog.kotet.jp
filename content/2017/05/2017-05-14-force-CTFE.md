---
date: 2017-05-14
title: "CTFEを強制するテンプレート"
tags:
- dlang
- tech
---

CTFE可能な関数を確実にCTFEさせて、CTFEできないときはエラーを吐くようなテンプレートを作った。
`if (__traits(compiles, F(Args)))`のところ、何かもうすこしちゃんとした書き方がある気がする。

```d
template CTFE(alias F, Args...) if (__traits(compiles, F(Args)))
{
    enum CTFE = F(Args);
}
```

### 使用例:

```d
void main()
{
    import std.stdio;
    import std.math;

    CTFE!(sqrt, 2.0).writeln();
    sqrt(2.0).writeln();

    CTFE!(pow, 2, 3).writeln();
    pow(2, 3).writeln();
}
```

普通に`sqrt`や`pow`を呼んだ場合はそのままになっているが、`CTFE`テンプレートを使うと実行結果に展開されている。

```d
void main()
{
	import std.stdio;
	import std.math;
	writeln(1.41421);
	writeln(sqrt(2.00000));
	writeln(8);
	writeln(pow(2, 3));
	return 0;
}
```

もちろんCTFEできないものはエラーになる。

```d
void main()
{
    import std.stdio;
    import std.math;
    import std.random;

    CTFE!(sqrt, uniform(0.0, 1.0)).writeln();
    CTFE!(uniform, 0.0, 1.0).writeln();
}
```

```console
$ dmd test.d
/usr/include/dmd/phobos/std/random.d(1338): Error: static variable initialized cannot be read at compile time
/usr/include/dmd/phobos/std/random.d(1372):        called from here: rndGen()
/usr/include/dmd/phobos/std/random.d(1372):        called from here: uniform(a, b, rndGen())
test.d(12):        called from here: uniform(0.00000, 1.00000)
/usr/include/dmd/phobos/std/random.d(1338): Error: static variable initialized cannot be read at compile time
/usr/include/dmd/phobos/std/random.d(1372):        called from here: rndGen()
/usr/include/dmd/phobos/std/random.d(1372):        called from here: uniform(a, b, rndGen())
test.d(3):        called from here: uniform(0.00000, 1.00000)
test.d(13): Error: template instance test.CTFE!(uniform, 0.00000, 1.00000) error instantiating
```