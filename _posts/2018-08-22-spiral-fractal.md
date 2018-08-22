---
layout: post
title: spiral_fractal
date: 2018-08-22 03:18 -0500
---
This is the beginning of a short series of articles on fractals.  A fractal is a simple pattern, when applied to itself over and over again generates a fun kind of complexity.  To begin, let's start with the simplest fractal.

## Draw a spiral
Draw an ascii spiral inside of an (n x n) square starting at the top left and going clock-wise, such that given an integer n it produces the following stdout for `n = 12`

```
************
           *
 ********* *
 *       * *
 * ***** * *
 * *   * * *
 * * * * * *
 * * *** * *
 * *     * *
 * ******* *
 *         *
 ***********
```

## Analysis
The first step to any problem is to analyze it, see if you could find some pattern and it turns out that with the spiral there is quite a few neat properties that should,  make the experience of actually drawing the spiral straight forward.

### Segments
The first clue i was given (if drawing the spiral by hand) is to think about the length of each segment and how it keeps changing.
![](/content/images/2016/06/SegmentSize-1.png)

As you can see due to the overlap of the previous segment with the next segment at the corner of the spirals turn each next segment is actually 1 less, but the turn.  The segments repeat beginning with the first segment after the green which makes a whole new spiral starting off with `N - 4` stars.

### Base Case
The immediate extension from this, becomes, what is the smallest spiral that you can draw?   Eg for what size `N` is the smallest **complete** spiral that you can make.  Which brings another question along, what is the _shortest segment_ that you can make?

Considering we are drawing an ascii art, the shortest segment is a single character `*` or _shortest segment = 1_  which means _smallest comlete spiral_ = _shortest segment_ + 3.

But is the _smallest complete spiral_ the smallest spiral?  The answer is no, what makes the spiral complete is the presence of all 4 segments.  So the smallest spiral (yet incomplete) is `*` which gives us the following in terms of 4 possible spirals.

```scala
    if(size == 4) return Seq(
      Seq(`*`, `*`, `*`, `*`),
      Seq(`_`, `_`, `_`, `*`),
      Seq(`_`, `*`, `_`, `*`),
      Seq(`_`, `*`, `*`, `*`)
    )
    else if(size == 3) return Seq(
      Seq( `*`, `*`, `*`),
      Seq( `_`, `_`, `*`),
      Seq( `_`, `*`, `*`)
    )
    else if(size == 2) return Seq(
      Seq( `*`, `*`),
      Seq( `_`, `*`)
    )
    else if(size == 1) return Seq(
      Seq( `*`)
    )
```

## Recursion
At this point you may already have an approach in mind that you would like to implement, or maybe you have though of an iterative or recursive approach to actually tackle this problem head on.  Here is my approach to this problem using recursion.

One way to look at this problem is that a `spiral(n)` is composed of a `spiral(n-4)` in this manner

![](/content/images/2016/06/SpiralRecursion.png)

### Out to In Solution
By dropping down to the base cases I have discussed in the analysis and building `spiral(n)` from `spiral(n - 1)`.  That means all of the actual building happens on the way back up the stack after reaching the final depth (base case).

```scala
/**
  * Draws a size x size spiral using recursion
  */
object Spiral extends App{
  val `_` = ' '
  val `*` = '*'
  def spiral (size: Int): Seq[Seq[Char]] = {
    if(size == 4) return Seq(
      Seq(`*`, `*`, `*`, `*`),
      Seq(`_`, `_`, `_`, `*`),
      Seq(`_`, `*`, `_`, `*`),
      Seq(`_`, `*`, `*`, `*`)
    )
    else if(size == 3) return Seq(
      Seq( `*`, `*`, `*`),
      Seq( `_`, `_`, `*`),
      Seq( `_`, `*`, `*`)
    )
    else if(size == 2) return Seq(
      Seq( `*`, `*`),
      Seq( `_`, `*`)
    )
    else if(size == 1) return Seq(
      Seq( `*`)
    )
    val r = (spiral(size-4) :+ Seq.fill(size-4)(`_`)).map(x=> Seq(`_`,`*`) ++ x ++ Seq(`_`,`*`))
    Seq.fill(size)(`*`) +: (Seq.fill(size - 1)(`_`) :+ `*`) +: r :+ (`_` +: Seq.fill(size - 1)(`*`))
  }

  spiral(12).foreach(x => println(x.mkString))
}
```

### In to Out Solution
One of the downsides of recursion in such a manner is that you rely on the stack to keep track of the state, which is of fixed size.  An optimization can be made by placing this state instead into the heap.  An approach like that takes advantage of a concept called memoization(in this case streams), meaning that instead of every time computing the same (0...N - 1) sequence every time, we save the results in some data structure, so then the query for the next element that is `[0..n-1]` range, will execute in _O(1)_ time.

In this example, you should note, that  `val sp = getSpiral(size)` is only an un materialized infinite sequence of spirals going from _0_ to _Infinity_.  I then materialize every single spiral up to `n`, and draw the last one found `drawSpiral(sp(size / 4))`.  The complexity to get a spiral between 0 and n -1 is _O(1)_.

```scala
object StreamingSpiral extends App {
  val `_` = ' '
  val `*` = '*'
  type Spiral = Seq[Seq[Char]]

  def spirals(seed: Spiral): Stream[Spiral] = {
    def nextSpiral (s: Spiral): Spiral = {
      val size = s.length + 4
      val r = (s :+ Seq.fill(size-4)(`_`)).map(x=> Seq(`_`,`*`) ++ x ++ Seq(`_`,`*`))
      Seq.fill(size)(`*`) +: (Seq.fill(size - 1)(`_`) :+ `*`) +: r :+ (`_` +: Seq.fill(size - 1)(`*`))
    }

    Stream.cons(seed, spirals(nextSpiral(seed)))
  }

  val minSpiral: PartialFunction [Int, Spiral] = {
    case 4 => Seq(
      Seq(`*`, `*`, `*`, `*`),
      Seq(`_`, `_`, `_`, `*`),
      Seq(`_`, `*`, `_`, `*`),
      Seq(`_`, `*`, `*`, `*`)
    )
    case 3 => Seq(
      Seq( `*`, `*`, `*`),
      Seq( `_`, `_`, `*`),
      Seq( `_`, `*`, `*`)
    )
    case 2 => Seq(
      Seq( `*`, `*`),
      Seq( `_`, `*`)
    )
    case 1 => Seq(
      Seq( `*`)
    )
  }

  val getSpiral: PartialFunction[Int, Stream[Spiral]] = {
    case size if (size % 4) == 0 =>
      Seq(Seq[Char]()) #:: spirals(minSpiral(4))
    case size =>
      val min = size % 4
      spirals(minSpiral(min))
  }

  def drawSpiral(s: Spiral) = s.foreach(x => println(x.mkString))

  val size = 12
  val sp = getSpiral(size)

  drawSpiral(sp(size / 4))

    sp.take(size/4 + 1).reverse.tail.foreach(drawSpiral)
}
```

```
************
           *
 ********* *
 *       * *
 * ***** * *
 * *   * * *
 * * * * * *
 * * *** * *
 * *     * *
 * ******* *
 *         *
 ***********
********
       *
 ***** *
 *   * *
 * * * *
 * *** *
 *     *
 *******
****
   *
 * *
 ***
```

## Imperative
Recursive approaches, are neat.  Especially if you are planning to generate and use a sequence of spirals for a  certain range of size.   However, if all you really want to do is print the darn spiral in _O(1)_ space complexity as opposed to _O(n)_ then imperative solution that mutates state seems appropriate.  But just because its imperative does not mean it cant be functional.   So here i move the state manipulation and the state to a single function, and try to keep referential transparency everywhere else.

One important thing to note, is that i am not changing my approach.  I build then apply a list of segments, however whats built is saved to show a cool side effect (eg a list of coordinates for the spiral), but the solution still can be considered as _O(1)_ space complexity.

```scala
object ImperativeSpiral extends App {
  val `_` = ' '
  val `*` = '*'

  type Spiral = mutable.ArraySeq[mutable.ArraySeq[Char]]

  case class Position(r: Int, c: Int) {
    def up(n: Int) = copy(r = r - n)
    def down(n: Int) = copy(r = r + n)
    def left(n: Int) = copy(c = c - n)
    def right(n: Int) = copy(c = c + n)
  }

  def spiral(size: Int): (Seq[Position], Spiral) = {
    val spiral = mutable.ArraySeq.fill(size, size)(`_`)

    def draw(position: Position): Unit = spiral(position.r).update(position.c, `*`)

    def loop(n: Int, s: Position): Seq[Position] = {
      def segment(n: Int, t: (Int) => Position): Option[(Seq[Position], Position)]= {
        val o = (0 until n).map(t(_))
        o.lastOption.map((o, _))
      }

      val a = segment(n, s.right)
      val b = a.flatMap(x => segment(n - 1 , x._2.down(1).down))
      val c = b.flatMap(x => segment(n - 2, x._2.left(1).left))
      val d = c.flatMap(x => segment(n - 3, x._2.up(1).up))

      Seq(a, b, c, d).filter(_.nonEmpty).flatMap(_.get._1)
    }

    val (segs, _) = (size % 4).to(size, 4).foldRight((Seq[Position](), Position(0, 0)))((n, r) => {
      val (o, pos) = r
      val a = loop(n, pos)
      a.foreach(draw)

      (o ++ a, a.lastOption.
        map(_.right(1)).
        getOrElse(pos))
    })

    segs -> spiral
  }

  val (s, sp) = spiral(12)
  println(s.map(Position.unapply(_).get).mkString(", "))
  sp.foreach(x => println(x.mkString))
}
```

```
(0,0), (0,1), (0,2), (0,3), (0,4), (0,5), (0,6), (0,7), (0,8), (0,9), (0,10), (0,11), (1,11), (2,11), (3,11), (4,11), (5,11), (6,11), (7,11), (8,11), (9,11), (10,11), (11,11), (11,10), (11,9), (11,8), (11,7), (11,6), (11,5), (11,4), (11,3), (11,2), (11,1), (10,1), (9,1), (8,1), (7,1), (6,1), (5,1), (4,1), (3,1), (2,1), (2,2), (2,3), (2,4), (2,5), (2,6), (2,7), (2,8), (2,9), (3,9), (4,9), (5,9), (6,9), (7,9), (8,9), (9,9), (9,8), (9,7), (9,6), (9,5), (9,4), (9,3), (8,3), (7,3), (6,3), (5,3), (4,3), (4,4), (4,5), (4,6), (4,7), (5,7), (6,7), (7,7), (7,6), (7,5), (6,5)
************
           *
 ********* *
 *       * *
 * ***** * *
 * *   * * *
 * * * * * *
 * * *** * *
 * *     * *
 * ******* *
 *         *
 ***********
```
