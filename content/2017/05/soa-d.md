---
date: 2017-05-19
aliases:
- /2017/05/19/soa-d.html
title: "なぜ、どういう時にSOAを使うべきなのか【翻訳】"
tags:
- dlang
- tech
- translation
---

この記事は

[Why and when you should use SoA ·](https://maikklein.github.io/post/soa-d/)

を自分用に訳したものを
[許可を得て](https://maikklein.github.io/post/soa-d/#comment-3309967000)
公開するものである。
コードのコメントも一部翻訳されている。
ところどころ訳が怪しいところがあるので、なにか見つけた人は[contribute](https://github.com/kotet/blog.kotet.jp)だ!

---

### SoAとは何か?

SoAとは単に`配列の構造体(Structure of arrays)`を意味します。

```d
//AoS: 構造体の配列(Array of structures)
struct Vec2{
    float x;
    float y;
}
Array!Vec2 vectors;
```

```d
//SoA: 配列の構造体
struct Vec2{
    float[] x;
    float[] y;
}
```

### なぜSoAは便利なのか?

`クライアント・サーバー・アーキテクチャー`で小さな`udpゲームサーバー`を書くことを想像してみてください。
あなたにはクライアントが接続できるサーバーがあります。
`サーバー`は現在接続しているクライアントたちを覚えておく必要があります。
サーバーはメッセージを`recvfrom`でポールし、あなたがudpをよく知らない場合、
`recvfrom`はソケットにバインドされたポートとアドレスへ送られるパケットを返します。

パケットが来たとき、最初に知りたいのはパケットが接続しているクライアントから来たかどうかかもしれません。
あなたにはそれをこのように書く傾向があることでしょう:

```cpp
struct Server{
    struct RemoteClient{
        Address address;
        SysTime lastReceivedPacket;
        //more data
    }
    Array!RemoteClient remoteClients;

    void poll(){
        //Address address
        //recvfrom(buffer, address);
    }
}
```

どのクライアントがパッケージを送ったのか知りたい時、正しい`remoteClient`を探すために単に`remoteClients`配列を使うことができます。
問題はアドレスフィールドにしか興味がないが、`RemoteClient`をイテレートする必要があるということです。
これはそれが必要ないとしても、`lastReceivedPacket`のような他のすべてのデータを不必要にロードしているということを意味します。

そして実際のアプリケーションで`RemoteClient`の中にどれくらいのデータがありうるか知りたいなら、
こちらが[Enet Peer](https://github.com/lsalzman/enet/blob/master/include/enet/enet.h#L258)の構造体です。
これは`Peer`であり`RemoteClient`ではないためフェアな比較ではないかもしれませんが、
これはデータがかなり大きくなるかもしれないということを示しています。

```c
typedef struct _ENetPeer
{ 
   ENetListNode  dispatchList;
   struct _ENetHost * host;
   enet_uint16   outgoingPeerID;
   enet_uint16   incomingPeerID;
   enet_uint32   connectID;
   enet_uint8    outgoingSessionID;
   enet_uint8    incomingSessionID;
   ENetAddress   address;            /**< Internet address of the peer */
   void *        data;               /**< Application private data, may be freely modified */
   ENetPeerState state;
   ENetChannel * channels;
   size_t        channelCount;       /**< Number of channels allocated for communication with peer */
   enet_uint32   incomingBandwidth;  /**< Downstream bandwidth of the client in bytes/second */
   enet_uint32   outgoingBandwidth;  /**< Upstream bandwidth of the client in bytes/second */
   enet_uint32   incomingBandwidthThrottleEpoch;
   enet_uint32   outgoingBandwidthThrottleEpoch;
   enet_uint32   incomingDataTotal;
   enet_uint32   outgoingDataTotal;
   enet_uint32   lastSendTime;
   enet_uint32   lastReceiveTime;
   enet_uint32   nextTimeout;
   enet_uint32   earliestTimeout;
   enet_uint32   packetLossEpoch;
   enet_uint32   packetsSent;
   enet_uint32   packetsLost;
   enet_uint32   packetLoss;          /**< mean packet loss of reliable packets as a ratio with respect to the constant ENET_PEER_PACKET_LOSS_SCALE */
   enet_uint32   packetLossVariance;
   enet_uint32   packetThrottle;
   enet_uint32   packetThrottleLimit;
   enet_uint32   packetThrottleCounter;
   enet_uint32   packetThrottleEpoch;
   enet_uint32   packetThrottleAcceleration;
   enet_uint32   packetThrottleDeceleration;
   enet_uint32   packetThrottleInterval;
   enet_uint32   pingInterval;
   enet_uint32   timeoutLimit;
   enet_uint32   timeoutMinimum;
   enet_uint32   timeoutMaximum;
   enet_uint32   lastRoundTripTime;
   enet_uint32   lowestRoundTripTime;
   enet_uint32   lastRoundTripTimeVariance;
   enet_uint32   highestRoundTripTimeVariance;
   enet_uint32   roundTripTime;
   enet_uint32   roundTripTimeVariance;
   enet_uint32   mtu;
   enet_uint32   windowSize;
   enet_uint32   reliableDataInTransit;
   enet_uint16   outgoingReliableSequenceNumber;
   ENetList      acknowledgements;
   ENetList      sentReliableCommands;
   ENetList      sentUnreliableCommands;
   ENetList      outgoingReliableCommands;
   ENetList      outgoingUnreliableCommands;
   ENetList      dispatchedCommands;
   int           needsDispatch;
   enet_uint16   incomingUnsequencedGroup;
   enet_uint16   outgoingUnsequencedGroup;
   enet_uint32   unsequencedWindow [ENET_PEER_UNSEQUENCED_WINDOW_SIZE / 32]; 
   enet_uint32   eventData;
   size_t        totalWaitingData;
} ENetPeer;
```

では`SoA`ではどのようになるか見てみましょう。

```cpp
struct Server{
    struct RemoteClients{
        size_t length;
        Address[] address;
        SysTime[] lastReceivedPacket;
        //more data
    }
    RemoteClients remoteClients;

    void poll(){
        //Address address
        //recvfrom(buffer, address);
    }
}
```

すべての`remoteClients.address`のアドレスにアクセスでき、不必要なデータをキャッシュにロードする必要はありません。

### SoAは使いにくくないのか?

多くの言語ではそのとおりです。

```cpp
struct RemoteClients{
    size_t length;
    Address[] address;
    SysTime[] lastReceivedPacket;
    //more data
}
```

配列を割り当て、それが動的配列の場合は拡張しなければならないために定義は単純化されています。
要素の挿入と削除についても気にかける必要もあります、
`lastReceivedPacket`を追加せずにアドレスだけを`RemoteClients`に追加するようなことがあってはいけません。
データはゆるく対になっているためです。
以前の`AoS`の時は`RemoteClient`に`remoteClients[index]`でアクセスできましたが、
今は`RemoteClient`にその要素`remoteClients.addresses[index]`や`remoteClients.lastReceivedPacket[index]`でアクセスします。

### DでのSoAの実装

まずデモンストレーションから始めましょう。

```d
struct Vec2{
    float x;
    float y;
}
auto s = SOA!(Vec2)();

s.insertBack(1.0f, 2.0f);
s.insertBack(Vec2(1.0, 2.0f));
writeln(s.x); // [1, 1]
writeln(s.y); // [2, 2]
```

データで構造体を作ることができ、`SOA`は構造体をみて内部的に適切な配列を作ります。
持っているフィールドと同じ数の配列があるため、`insertBack`はちょっと普通の配列と異なります。
これは`insertBack`が可変長である必要があることを意味します。
`insertBack`はかわりにそれ自身の構造体も受け入れます。

**以下のコードは実際に使うことを意図して書かれたコードではなく、単なる概念実証です。**

```d
struct SOA(T){
    import std.experimental.allocator;
    import std.experimental.allocator.mallocator;

    import std.meta: staticMap;
    import std.typecons: Tuple;
    import std.traits: FieldNameTuple;

    alias toArray(T) = T[];
    alias toType(string s) = typeof(__traits(getMember, T, s));

    alias MemberNames = FieldNameTuple!T;
    alias Types = staticMap!(toType, MemberNames);
    alias ArrayTypes = staticMap!(toArray, Types);

    this(size_t _size, IAllocator _alloc = allocatorObject(Mallocator.instance)){
        alloc = _alloc;
        size = _size;
        allocate(size);
    }

    ref auto opDispatch(string name)(){
        import std.meta: staticIndexOf;
        alias index = staticIndexOf!(name, MemberNames);
        static assert(index >= 0);
        return containers[index];
    }

    void insertBack(Types types){
        if(length == size) grow;
        foreach(index, ref container; containers){
            container[length] = types[index];
        }
        length = length + 1;
    }

    void insertBack(T t){
        if(length == size) grow;
        foreach(index, _; Types){
            containers[index][length] = __traits(getMember, t, MemberNames[index]);
        }
        length = length + 1;
    }

    size_t length() const @property{
        return _length;
    }

    ~this(){
        if(alloc is null) return;
        foreach(ref container; containers){
            alloc.dispose(container);
        }
    }

private:
    void length(size_t len)@property{
        _length = len;
    }

    Tuple!ArrayTypes containers;
    IAllocator alloc;

    size_t _length = 0;
    size_t size = 0;
    short growFactor = 2;

    void allocate(size_t size){
        if(alloc is null){
            alloc = allocatorObject(Mallocator.instance);
        }
        foreach(index, ref container; containers){
            container = alloc.makeArray!(Types[index])(size);
        }
    }

    void grow(){
        import std.algorithm: max;
        size_t newSize = max(1,size * growFactor);
        size_t expandSize = newSize - size;

        if(size is 0){
            allocate(newSize);
        }
        else{
            foreach(ref container; containers){
                alloc.expandArray(container, expandSize);
            }
        }
        size = newSize;
    }
}
```

```d
alias toArray(T) = T[];
alias toType(string s) = typeof(__traits(getMember, T, s));

alias MemberNames = FieldNameTuple!T;
alias Types = staticMap!(toType, MemberNames);
alias ArrayTypes = staticMap!(toArray, Types);
```

`MemberNames`は単なるフィールドの名前群です。
たとえば`構造体 Vec2{float x; float y}`は型`AliasSeq!("x", "y")`になります。
`toType`はメンバ名をとり実際の型にします。
例として上の`toType!("x")`は型`float`を返します。

`staticMap`の助けを得てメンバ名を実際の型に変換することができます。
たとえば上の`AliasSeq!("x", "y")`は`AliasSeq!(float, float)`に変わります。

もうすぐ型を配列に変換する必要が出てきます。
`AliasSeq!(float, float)`を`AliasSeq!(float[], float[])`にです。
それを`toArray`と`staticMap`でします。

その後配列のタプルを作ることができます。

```d
Tuple!ArrayTypes containers;
```

要素の挿入はかなり簡単です。

```d
void insertBack()(Types types){
    if(length == size) grow;
    foreach(index, ref container; containers){
        container[length] = types[index];
    }
    length = length + 1;
}
```

`insertBack`が受け入れるべき型はすでにわかっています。
構造体のフィールド郡の型をうけいれるべきです。
そして配列のタプルである`containers`をコンパイル時にイテレートします。

それから適切な`argument`に`types[index]`でアクセスし、それを配列に挿入するだけです。

構造体そのものを挿入することもできます。

```d
void insertBack(T t){
    if(length == size) grow;
    foreach(index, _; Types){
        containers[index][length] = __traits(getMember, t, MemberNames[index]);
    }
    length = length + 1;
}
```

`index`を取得するために型をイテレートします。
`index`を適切なコンテナを得るためと、構造体の適切なフィールド名を見つけるために使います。
順序は常に同じためこれは動作します。

上のコードを`Vec2`ようにするとだいたいこんなふうになります。

```d
void insertBack(Vec2 t){
    if(length == size) grow;
    containers[0][length] = t.x;
    containers[1][length] = t.y;
    length = length + 1;
}
```

配列にフィールド名でアクセスできます。
Dでこれは`opDispatch`によって非常に簡単にできます。

```d
ref auto opDispatch(string name)(){
    import std.meta: staticIndexOf;
    alias index = staticIndexOf!(name, MemberNames);
    static assert(index >= 0);
    return containers[index];
}
```

上のサンプルを`Vec2`用にした場合ではすべてのxの配列を`s.x`、すべてのyの配列を`s.y`で得ることができます。
`s.x`を呼んだ場合`opDispatch`はコンパイル時にこんな感じになります。

```d
ref auto opDispatch(){
    import std.meta: staticIndexOf;
    alias index = staticIndexOf!("x", MemberNames);
    static assert(index >= 0);
    return containers[index];
}
```

`MemberNames opDispatch`内が失敗しなかった場合、`opDispatch name`のインデックスを`MemberNames`から取得します。
`MemberNames`内にあればそのインデックスで適切なコンテナにアクセスします。

```d
struct Server{
    struct RemoteClients{
        Address address;
        SysTime lastReceivedPacket;
        //more data
    }
    SOA!RemoteClient remoteClients;

    void poll(){
        //Address address
        //recvfrom(buffer, address);
    }
}
```

### SoAを使うときはいつか

まず第一に`SoA`は銀の弾丸ではなく、あなたのコードベースのすべての`AoS`を`SoA`に置き換えるべきというわけではありません。

`SoA`に意味があるのはこのような時です:

 - データを1つの配列に保持したくなるとわかっているとき
 - 部分的にデータにアクセスしたいとき

しかし時にはデータのすべてのコンポーネントにアクセスしたい時もあるでしょう。
例としてベクトルが挙げられます。

```d
struct Vec3{
    float x;
    float y;
    float z;
}
```

加算、減算、ドット積、距離その他いろいろのほとんどの操作はすべてのコンポーネントを使うでしょう。
たとえ最終的に

```d
struct Vec3{
    float x;
    float y;
    float z;
}

Array!Vec3 positions;

positions[].filter!(v => v.x < 10.0f);
```

`x コンポーネント`が`10.0f`より小さいすべてのベクトルをフィルタしたくなっても、2つのfloatが余分に読み込まれるだけです。
`Vec3`は大きくならず、これ以外の他のデータ構造が成長し、将来のボトルネックになるかもしれません。

### SoAは「時期尚早な最適化」ではないのか?

私の意見は違います。
`AoS`の問題は、それが将来パフォーマンスボトルネックになった場合、多くのコードをリファクタしなければならないというところです。
たとえばあなたはこのように構造体hotとcoldにデータをパックするかもしれません:

```d
struct Bar{
    struct Hot{
        Data1 d1;
        Data2 d2;
        ...
    }
    struct Cold{
        Data3 d3;
        Data4 d4;
        ...
    }

    Hot* hot;
    Cold* cold;
}
```

しかし言語によってはまだまだ多くのコードをリファクタしなければならないかもしれません。
早い段階でデータアクセスについて考えることで手間が省けるかもしれません。

[Jonathan Blow](https://www.youtube.com/watch?v=ZHqFrNyLlpA)には名無し変数とSoAをカバーする言語デモンストレーションがあります。
Quick note:Jonathan BlowのやりかたはDの`alias this`とよく似ています。

使う言語によっては、`SoA`は`AoS`と比べてそんなに悪くはありません。

```d
//AoS
remoteClients[index].address;

//vs 

//SoA
remoteClients.address[index];
```

しかし`SoA`はキャッシュからの関係ない不必要なローディングなしにデータに部分的なアクセスができるため、よりスケールします。