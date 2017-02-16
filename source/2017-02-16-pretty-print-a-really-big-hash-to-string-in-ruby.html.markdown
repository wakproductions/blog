---
title: Pretty Print a Really Big Hash in Ruby
date: 2017-02-16 01:30 EST
tags:
---

## Problem: Copy and paste a really big Ruby object so that it's human readable

Today I was building a fixture in one of my RSpec tests which consisted of a really big hash. It looked something like this:

```ruby
really_big_hash =     {:Profile=>
                         {:CharterNumber=>"68448",
                          :CreditUnionId=>"14241",
                          :CreditUnionName=>"CITIZENS EQUITY FIRST",
                          :CycleDate=>"12/31/2015",
                          :CreditUnionTypeID=>"FISCU",
                          :Region=>"4",
                          :CreditUnionStatus=>"Active",
                          :DateChartered=>"2000",
                          :DateInsured=>"1/2/1975",
                          :CharterStateCode=>"Illinois",
                          :TOM_CODE=>"99",
                          :State=>"IL",
                          :Acct_896=>"1",
                          :PeerGroup=>"6 - $500,000,000 and greater",
                          :Assets=>"5174819725",
                          :NumberOfMembers=>"312929",
                          :IsLowIncome=>"No",
                          :CertificationDate=>"1/22/2016 10:46:28 AM",
                          :HasWebSite=>"Yes",
                           ...
```

When I tried to copy this fixture into my test file, I initially did this in console:

```ruby
require 'clipboard' # use the Clipboard gem
Clipboard.copy(really_big_hash)
```

The problem was that when I pasted the text it all ended up on one line like this:

```ruby
{:Profile=>{:CharterNumber=>"68448", :CreditUnionId=>"14241", :CreditUnionName=>"CITIZENS EQUITY FIRST", :CycleDate=>...
```

## Solution: Ruby's 'pp' module

I discovered that the Ruby 'pp' module could be used to format a Hash as a multiline output and I could capture the
output. Here's what I did:

```ruby
require 'pp'
cap = StringIO.new
$stdout = cap
pp(r)
$stdout = STDOUT

Clipboard.copy(cap.string)
```

I was then able to paste my Hash as a more human-readable multi-line string. Note that because `pp` prints to screen
by default, I had to reroute `$stdout` temporarily to capture the output via a `StringIO` object.