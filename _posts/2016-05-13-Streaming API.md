---
title: Rbbt as a Streaming API
layout: default
tagline: Stream API
---

# Introduction

It was a lot of work but very satisfactory to make Rbbt workflow tasks stream
their results across, but what was missing up to now is that they did that
across remote workflows as well. It was an ever mightier lot of work to get
this done, but it is finally ready.

# What needs to happen

There are two parts to streaming workflow tasks: (IN) that the input is taken
as a stream and (OUT) that the result is returned as a stream. This means that
you cannot just save the input stream to disk, send it to the job, save the
result to disk and when done send it to the remote client; this was already
available and it is trivial. The easiest part was (OUT), this just needed 
