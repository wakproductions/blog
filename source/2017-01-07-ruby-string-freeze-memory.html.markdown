---
title: Ruby - Don't Freeze User-Defined Strings!
date: 2017-01-07 01:30 EST
tags:
---

This week I was working on a Rails project that involved keeping a large hash of dynamic data in memory. On first 
thought, I was going to build the hash keys based on several data points which will be combined into a hash key. It
would have looked something like this:

```ruby
element_name = 'NETINC'
period = '20160930'
span = 'span_trailing_twelve_months'

"#{element_name}_#{period}_#{span}"
#=> "NETINC_20160930_span_trailing_twelve_months"


# ---------------------------------
# Then I would be able to reference
# the hash like this:

hash['NETINC_20160930_span_trailing_twelve_months']
 ```
 
However, if once I build the hash keys I freeze them using `String.freeze`, do they get garbage collected when I'm no 
longer processing that key? So let's say I'm making thousands of these hash keys, process the hash and then move on
to a new data set. Would Ruby keep the defunct hash key strings in memory for the remainder of the program?

**The answer is YES!** Freezing the keys could possibly cause a memory leak because the program will be maintaining
each string object in an in-memory table even after I'm done using it. The memory pile of string objects could
grow indefinitely. This is why freezing strings of user-defined input could be very dangerous - a malicious user
could crash your server by causing it to run out of memory this way.

I verified this in a discussion with the Chicago Ruby Slack group:

> `"foo".freeze.object_id == "foo".freeze.object_id" # => true`, but without the freeze it's `false`. And if 
> `def a; "foo".freeze.object_id; end; a; a` gives the same id twice.

> Oh yeah, good point... it does allow some memory optimizations if you freeze it, like two strings being the same 
> string in memory if they're frozen and identical

> Wrapped up work and dug a minute: in `string.c`, the retaining is happening in `str_new_frozen`. The vm calls 
> `str_replace_shared_without_enc` to eval the string literal, that calls `rb_fstring`, that calls 
> `str_replace_shared_without_enc`, that calls `str_new_frozen`.

> They're marked as SHARED. Then `gc.c`, `gc_mark_children` does `gc_mark(objspace, any->as.string.as.heap.aux.shared);`
> on all the shared strings so unless there's something I'm not spotting that sneaks around to unset SHARED those 
> strings are retained for the life of the process.

The approach I took to get around this problem was to build my hash to be dimensions deep. So to access the value,
I would instead use a chain of keys:

```ruby
hash['NETINC']['20160930']['span_trailing_twelve_months']
```

All it took was a small modification of the fetch methods wrapping my Hash to implement this. `element_name` and `span` 
are fine to freeze because there is a finite number of them in my program.