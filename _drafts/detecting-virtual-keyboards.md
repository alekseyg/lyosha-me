---
layout: post
title: Detecting virtual keyboards (when typing in an input field)
categories: web-development
---

Sometimes, it is useful to differentiate between physical and virtual keyboards in a web application. In my case, I had built a new messaging system for [Yanteres](https://yanteres.com) with a responsive design which could be used on any device. While responsive design is a given on today's web, the behavior of certain actions – which can't be controlled via CSS – is different on mobile vs desktop. In the case of the aforementioned messaging system, hitting <kbd>Return</kbd> on physical keyboards is expected to send a message, while hitting <kbd>Return</kbd> on a phone's or tablet's virtual keyboard is expected to insert a newline.

## Screen width media queries won't cut it

On first thought, one may be tempted to use a media query in Javascript to change the behavior for mobile vs desktop. However, let's not forget that the screen size isn't what changes the behavior here. A mobile phone or tablet can be hooked up to a physical keyboard and a desktop computer can also have a touch screen. Also, in landscape mode, a tablet resolution is esentially that of a small desktop in most responsive designs.

We need to differentiate between a physical and a virtual keyboard rather than screen size, and browsers currently have no API to do so that I am aware of. Searching high and low, I've found [many](http://stackoverflow.com/questions/2593139/ipad-web-app-detect-virtual-keyboard-using-javascript-in-safari) [people](http://stackoverflow.com/questions/13270659/detect-virtual-keyboard-vs-hardware-keyboard) [asking](http://stackoverflow.com/questions/8556933/screen-styling-when-virtual-keyboard-is-active) [for](http://stackoverflow.com/questions/11600040/jquery-js-html5-change-page-content-when-keyboard-is-visible-on-mobile-devices) a way to change the layout in response to the presence of a virtual keyboard, or lack thereof, but [only one discussion](http://stackoverflow.com/questions/18880236/how-do-i-detect-hardware-keyboard-presence-with-javascript) on the actual behavior of the keyboard, which had no solution. Then I had a thought – does a virtual keyboard care about when you press and release keys the way a physical keyboard, or does it fire `keydown` and `keyup` events instantaneously?

## Counting key press and release time

I got the hunch that perhaps virtual keyboards fire the events in rapid succession in a way that was impossible for humans, and immediately went on to test my hunch on iOS and Android devices and desktop browsers by binding the `keydown` and `keyup` events that would log the time difference between key press and release.

*Note: I use jQuery and Coffeescript in my examples, but the concepts can be applied in vanilla JS easily.*

{% highlight coffeescript %}
interceptEnterKey = ($message) ->
  start = 0                           # initialize var start

  $message.keydown ->
    start = new Date().getTime()      # set start to current time

  $message.keyup ->
    console.log(new Date().getTime() - start) # log the difference

initTextArea = ->
  $message = $('#message_body')
  interceptEnterKey($message)

$ initTextArea
{% endhighlight %}

The results were pretty much as I had expected. Virtual keyboards on mobile devices fire the events at physically impossible speeds.

<img class="img-responsive thumbnail"
  alt="Keyboard Speed Test Results"
  src="{{ site.baseurl }}/images/virtual-keyboard.png">

When it came to Windows and Linux, I got pretty much the same results as with Mac, Android was slightly slower, and I didn't get to test it on Windows touch devices (if anyone wants to help with that, please do). In summary, physical keyboards almost always returned over 30ms – even with quickly jabbing the keys, iOS virtual keyboards always took less than 10ms, and Android virtual keyboards were around 12ms.

### Key press and release times are not 100% consistent

So, the answer is to count the milliseconds between `keyup` and `keydown` and you shall know whether or not you have a virtual or physical keyboard, right? Unfortunately, one key press and release won't always give you the right answer. In some cases, a physical keyboard will have an odd key press that lasts less than 10ms (pictured above) and Android will have an odd one that lasts up to 25ms. The solution I came up with was to keep count of each key press time and then to find the average when I needed it. In my application, that would be when the user presses the <kbd>Return</kbd> key. If the average time is over 25ms, chances are good that it's a physical keyboard.

{% highlight coffeescript %}
interceptEnterKey = ($message) ->
  start = 0                           # initialize var start
  keyTimes = []                       # array to store times

  $message.keydown (e) ->             # we will be using the event now
    start = new Date().getTime()      # set start to current time

    if e.keyCode == 13                # if return was pressed
      # Note: Array.reduce is an ES5 function.
      # Use a polyfill if you need IE8 support.
      sumKeyTime = keyTimes.reduce (x, y) -> x + y # sum up the times
      avgKeyTime = sumKeyTime / keyTimes.length    # find the average time

      if avgKeyTime > 25              # match physical keyboards
        e.preventDefault()            # cancel newline insertion
        keyTimes = []                 # reset the key press times
        $(this.form).submit()         # send the message

  $message.keyup ->
    keyTimes.push(new Date().getTime() - start) # store the difference

# ...
{% endhighlight %}

## Newlines with physical keyboards

The last step for a proper messaging system is to allow users of physical keyboards to enter newlines using <kbd>Shift</kbd>/<kbd>Option</kbd>/<kbd>Meta</kbd>/Etc + <kbd>Return</kbd>. All that needs to be done here is to check whether those keys are pressed on the `keydown` event, and we're done! I didn't want a very large `if` statement, so I put it in its own function.

{% highlight coffeescript %}
isKeyRawEnter = (e) ->
  !e.ctrlKey && !e.altKey && !e.shiftKey && !e.metaKey && e.keyCode == 13

# ...
{% endhighlight %}

{% highlight diff %}
-    if (e.keyCode == 13)              # if return was pressed
+    if (isKeyRawEnter(e))             # if return was pressed
{% endhighlight %}

## TL;DR

The average time difference between `keydown` and `keyup` can be a good indicator of whether a user is typing on a physical or virtual keyboard. Here is the full code to an example that sends the message when <kbd>Return</kbd> is pressed on a physical keyboard and adds a newline when pressed on a virtual keyboard.

{% highlight coffeescript %}
isKeyRawEnter = (e) ->
  !e.ctrlKey && !e.altKey && !e.shiftKey && !e.metaKey && e.keyCode == 13

interceptEnterKey = ($message) ->
  start = 0                           # initialize var start
  keyTimes = []                       # array to store times

  $message.keydown (e) ->             # event to determine key(s)
    start = new Date().getTime()      # set start to current time

    if isKeyRawEnter(e)               # if return was pressed
      # Note: Array.reduce is an ES5 function.
      # Use a polyfill if you need IE8 support.
      sumKeyTime = keyTimes.reduce (x, y) -> x + y # sum up the times
      avgKeyTime = sumKeyTime / keyTimes.length    # find the average time

      if avgKeyTime > 25              # match physical keyboards
        e.preventDefault()            # cancel newline insertion
        keyTimes = []                 # reset the key press times
        $(this.form).submit()         # send the message

  $message.keyup ->
    keyTimes.push(new Date().getTime() - start) # store the difference

initTextArea = ->
  $message = $('#message_body')
  interceptEnterKey($message)

$ initTextArea

{% endhighlight %}

{% highlight html %}
<form id="message-form" method="post" action="/messages">
  <div>
    <textarea id="message_body" name="message[body]"></textarea>
  </div>
  <div>
    <button type="submit">Send</button>
  </div>
</form>
{% endhighlight %}

[Demo]({{ site.baseurl }}/virtual-keyboards-demo/)
