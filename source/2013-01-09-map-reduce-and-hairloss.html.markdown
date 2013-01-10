---
title: map-reduce-and-hairloss
date: 2013-01-09 12:35 +10:00
tags:
---

# Mongoid, TDD, map/reduce, and hairloss.

**tl;dr**

rake db:mongoid:create_indexes will create your mongo collections to avoid intermittent CI failure hell.

## The problem
Mongoid doesn't create collections in an eager fashion.

This wouldn't be a problem, except we're good little ruby citizens performing TDD, with a random test order, and a request spec happens to attempt a map/reduce on an empty collection.

Except that it's not an empty collection yet. It's a collection that will be created lazily, later in the suite (so I've learned).

Some stackoverflow-ing later, and it's clear that the following unhelpful and sporadic error

> Moped::Errors::OperationFailure:  
> The operation: #<Moped::Protocol::Command failed with error "ns doesn't exist"  

is trying to tell me my map/reduce function is pointed at some collection that doesn't exist. This would be extremely unlikely to show up on a development environment of course -- but on our CI server (we use [CircleCI](https://circleci.com/), and I'm loving it) the test DB is created every run, and so we enjoy intermittent failures, dependent on test order.

## The solution

I added some indices to the Mongoid::Document that was giving me the hairloss, then ran..

```shell
RAILS_ENV=test rake db:drop db:mongoid:create_indexes
```

> MONGO LOG - [initandlisten] connection accepted from 127.0.0.1:60401 #13 (1 connection now open)  
> MONGO LOG - [conn13] build index project_test.my_collection { _id: 1 }  
> MONGO LOG - [conn13] build index done.  scanned 0 total records. 0 secs  
> MONGO LOG - [conn13] info: creating collection project_test.my_collection on add index  
> MONGO LOG - [conn13] build index project_test.my_collection { device_id: 1 } background  
> MONGO LOG - [conn13] build index done.  scanned 0 total records. 0 secs  
> MONGO LOG - [conn13] end connection 127.0.0.1:60401 (0 connections now open)  

When I run an offending test again, all is right in the world. I hope this helps someone - this was one hell of a frustrating problem. There's not much joy in a failing build after having worked so hard on a test driven workflow locally.
