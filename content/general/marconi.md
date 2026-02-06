---
title: "Marconi"
draft: true
---



I was at Marconi for about four years. I was actually sponsored by them, so I spent nine months before my final year working for them over in Frimley.
During that time I was working on a new CMOS 8086 interrupt controller. There were only five of these in the whole of Europe, so I was told to try and not blow it up!
One of the senior engineers (Dr someone or other...) had written a program to test this chip. It failed the test but they didn't know why. So that was my task. The NMOS version worked, so I had something to compare it against. Anyway, long story short, it turned out that there was a masking error, and if you configured the chip in a certain way the interrupts wouldn't get processed correctly because two tracks were effectively too close together. In later years I would come across similar problems in memory chips - where they worked with certain data patterns but not others. That lead to a me writing a memory test that I believe is still is still used in Phoenix BIOSes - but thats another story.

When I started having graduated I quickly started working on test software and firmware using Pascal and 8086 assembler on IBM PCs.
But I enjoyed working on all sorts of computers - one of the tasks I took on was hacking into a CPM system where everyone had forgotten their password. There was still a way to get in (I think via an admin account) which allowed me to view the password "database". That gave me hashed passwords. Rather naively (with hindsight) I thought if I could work out the hashing algorithm I could work out the passwords. So I tried creating accounts with passwords "a", "b", "c" etc., and then "aa", "ab" etc. It didn't take me long to reverse engineer their hacking algorithm (it was a good job they didn't have a non-reversible algorithm). I'm still interested in security and reading about security failures and how to avoid them; I'm not a security expert, but I know enough to know that you don't try and invent your own security algorithms and systems!

After about a year I moved over to the application software group writing the real code in Coral66. I was made team leader of the "Intelligence and Meteorology" team. Looking back, the architecture was quite advanced for it's time.


