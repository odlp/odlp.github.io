---
title: Your Tests are Armour
date: 2016-05-28
tags: tdd
---

Recently I was updating a feature which provides a whitelist of postcodes. The
list is used to limit who can use a service and the change request was to add
further postcodes. Diving in I was surprised to discover a test with an
expectation mirroring the exact list:

```go
It("returns a list of postcodes", func() {
    expectedPostcodes := []string{
        "AB1 1",
        "AB1 2",
        "AB1 3",
        "AB1 4",
        "you get the idea... + 20 more postcodes",
    }

    allowedPostcodes := postcodeProvider.LoadList("production")
    Expect(allowedPostcodes).To(Equal(expectedPostcodes))
})
```

*This snippet is a just a [tribute](https://www.youtube.com/watch?v=_lK4cX5xGiQ) — the original is not mine to share.*

This test will fail if the list is updated with any new postcodes or old ones
are removed. It’s just mirroring the values in the source file. The path of
least resistance is to simply update the test with the new anticipated values,
see it fail, and update the implementation.

If that thought made you feel uneasy then you’re not alone. The postcodes in the
list are direct values loaded from a file, part of the configuration of the
application. Ideally the implicit virtues of the existing test can be teased out
whilst rewriting it to be less brittle. Ultimately a change to the postcode list
should not automatically necessitate a change to a test.

In my opinion the replacement tests would seek to verify:

- The overall mechanism of loading the list works
- The list contains a few of the expected values, and not gibberish
- Which list is returned can be driven by an external factor (environment variable)

If, for argument’s sake the values returned were more complex — say a computed
property, based on a catchment area derived from a sales index — then more
exhaustive assertions than a spot check may be in order. But this is just a
slice of strings, loaded from a file.

Later on whilst reflecting about this little discovery and subsequently
rewritten test I wondered if it was time well spent. To update both the test and
postcode list in their original forms would have taken moments. To rewrite the
test, check its validity by breaking the original implementation, then see it
pass took a quarter of an hour, which has an opportunity cost.

I felt it was reasonable to take that extra time for a couple of reasons.
Firstly bad practices can proliferate — acting as an inadvertent ‘example’ for
less TDD-experienced contributors to copy & paste for a similar feature. Or
perhaps the next developer who comes along observes the test in question,
acknowledges it to be less than ideal, but writes tests in a similar vein
because… well, broken windows.

Perhaps more importantly, in striving for the codebase to remain maintainable,
it’s a small effort towards keeping the cost of change low. A test suite
littered with over-specification and tests mirroring the implementation makes
change harder, without giving you extra security that the application behaves as
expected. This approach feels like encasing everything in concrete.

One way to think about your tests is as a suit of armour for your subject; you
want your application to be protected but vitally still want your dear
application to be able to move its arms and change direction. Encasing it in
concrete means you do indeed know exactly where each skin fold is, but it’s lost
the ability to move.

I have to stop writing this now, because the time spent rewriting the test and
making this post is bordering on outrageous for such a simple feature. It wasn’t
the burden which this one test weighed which made me pause, rather the thought
behind it. If that thought spreads throughout your test suite, conspiring with
other code gremlins along the way, it’s going make change hard and painful.
Change should rarely be painful.
