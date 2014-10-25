---
layout: post
title: Emulating HTML 5 support in current browsers
date: 2009-08-18 01:13
categories: web-development
redirect_from: /posts/3-emulating-html-5-support-in-current-browsers/
---

For about a year, I've slowly been migrating to <abbr title="Hypertext Markup Language">HTML</abbr> 5. First of course was the DOCTYPE. Next I started using new structure elements such as `<section>`, `<article>`, `<header>`, etc. and in some applications - Web Forms 2.0 input types.

To use these elements in Internet Explorer (all currently used versions) and Firefox 2.0 (though I believe this one isn't as important anymore), I wrote a script that looks like a hybrid of [John Resig](http://ejohn.org/)'s [<abbr title="Hypertext Markup Language">HTML</abbr> 5 Shiv](http://ejohn.org/blog/html5-shiv/) and Simon Pieters' [Firefox 2 <abbr>HTML</abbr> 5 enabling script](http://blog.whatwg.org/supporting-new-elements-in-firefox-2).

I was happy with that solution and other than using the new structuring elements and a little Web Forms 2, I used <abbr>HTML</abbr> 4. One of the applications I was working on needed to use an expanding area for more details. So instead of just making a pure Javascript and <abbr>HTML</abbr> 4 solution, I decided to use (and implement for current browsers) the <abbr>HTML</abbr> 5 `<details>` element.

Boy was that fun! I ran into a lot of bugs, and in the end increased my script from about 20 lines to almost 200. Opera was the most tolerant of the new functionality. Firefox had major issues with the DOM, the WebKit browsers had rendering issues, and don't even ask about Internet Explorer. With a few semi-ugly hacks though, I believe I have come up with a forwards compatible solution which I call [Fiks.<abbr>html</abbr>5](http://code.google.com/p/fiks-html5/).

I plan on adding more <abbr>HTML</abbr> 5 functionality as I go. One thing I won't add is support for Web Forms 2 because it has already been done and I believe it belongs in a seperate module.
