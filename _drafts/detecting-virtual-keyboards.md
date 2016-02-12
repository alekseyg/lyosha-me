---
layout: post
title: Detecting virtual keyboards (when typing in an input field)
categories: web-development
---

Sometimes, it is useful to differentiate between physical and virtual keyboards in a web application. In my case, I had built a new messaging system for [Yanteres](https://yanteres.com) with a responsive design which could be used on mobile as well as desktops. While responsive design is a given on today's web, the behavior of certain actions – which can't be controlled via CSS – is different on mobile vs desktop. In the case of the aforementioned messaging system, hitting <kbd>Return</kbd> on physical keyboards is expected to send a message, while hitting <kbd>Return</kbd> on a phone's or tablet's virtual keyboard is expected to insert a newline.

## Screen width media queries won't cut it

On first thought, one may be tempted to use a media query in Javascript to change the behavior for mobile vs desktop. However, let's not forget that the screen size isn't what changes the behavior here. A mobile phone or tablet can be hooked up to a physical keyboard and a desktop computer can also have a touch screen. Also, in landscape mode, a tablet resolution will usually be large enough to display the desktop styling.

We need to differentiate between a physical and a virtual keyboard, and browsers currently have no API to do so that I am aware of. Searching high and low, I've found [many](http://stackoverflow.com/questions/2593139/ipad-web-app-detect-virtual-keyboard-using-javascript-in-safari) [people](http://stackoverflow.com/questions/13270659/detect-virtual-keyboard-vs-hardware-keyboard) [asking](http://stackoverflow.com/questions/8556933/screen-styling-when-virtual-keyboard-is-active) [for](http://stackoverflow.com/questions/11600040/jquery-js-html5-change-page-content-when-keyboard-is-visible-on-mobile-devices) a way to change the layout in response to the presence of a virtual keyboard, or lack thereof, but [only one conversation](http://stackoverflow.com/questions/18880236/how-do-i-detect-hardware-keyboard-presence-with-javascript) about the actual behavior of the keyboard, which had no clear answer. Then I had a hunch. Does a virtual keyboard care about when you press and release keys the way a physical keyboard, or does it fire `keydown` and `keyup` events instantaneously?

## Counting key press and release time

I went out to test my hunch in iOS and Android simulators and desktop browsers by binding the `keydown` and `keyup` events that would log the time difference between key press and release.

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

The results were pretty much as I expected for Apple devices (I don't have screenshots from the other devices I tested, unfortunately).

<img class="img-responsive thumbnail"
  alt="Keyboard Speed Test Results"
  src="{{ site.baseurl }}/images/virtual-keyboard.png">

When it came to Windows and Linux, I got pretty much the same results as with Mac, Android was a little different, and I didn't get to test it on Windows touch devices (if anyone wants to help with that, please do). In summary, physical keyboards almost always returned over 30ms – even with quickly jabbing the keys, iOS virtual keyboards always took less than 10ms, and Android virtual keyboards were around 12ms.

### Key press and release times are not 100% consistent

So, the answer is to count the milliseconds between `keyup` and `keydown` and you shall know whether or not you have a virtual or physical keyboard, right? Unfortunately, one key press and release won't always give you the right answer. In some cases, a physical keyboard will have an odd key press that lasts less than 10ms (pictured above) and Android will have an odd one that lasts up to 25ms. The solution I came up with was to keep count of each key press time and then to find the average when I needed it. In my application, that would be when the user presses the <kbd>Return</kbd> key. If the average time is over 25ms, chances are good that it's a physical keyboard.

{% highlight coffeescript %}
interceptEnterKey = ($message) ->
  start = 0                           # initialize var start
  keyTimes = []                       # array to store times

  $message.keydown ->
    start = new Date().getTime()      # set start to current time

  $message.keyup (e) ->               # we will be using the event now
    keyTimes.push(new Date().getTime() - start) # store the difference

    if e.keyCode == 13                # if return was pressed
      # Note: Array.reduce is an ES5 function.
      # Use a polyfill if you need IE8 support.
      sumKeyTime = keyTimes.reduce (x, y) -> x + y # sum up the times
      avgKeyTime = sumKeyTime / keyTimes.length    # find the average time
      keyTimes = []                   # reset the key press times

      if avgKeyTime > 25              # match physical keyboards
        $(this.form).submit()         # send the message

# ...
{% endhighlight %}

## Let's get fancy

At this point, you can do whatever you like with the code. It's a generally good way to tell what kind of keyboard the user is using. There are a few more gotchas that I came across when implementing the rest of the messaging system, so here is the rest of the journey my code took.

### Allowing users to add newlines with physical keyboards

Like most messaging systems, <kbd>Shift</kbd>/<kbd>Option</kbd>/<kbd>Meta</kbd>/Etc + <kbd>Return</kbd> should allow the user to add a newline without sending the message, as a plain <kbd>Return</kbd> should. For this, I created a function which checks more than the key code and replaced the check with a call to said function.

{% highlight coffeescript %}
isKeyRawEnter = (e) ->
  !e.ctrlKey && !e.altKey && !e.shiftKey && !e.metaKey && e.keyCode == 13

# ...
{% endhighlight %}

{% highlight diff %}
-    if (e.keyCode == 13)              # if return was pressed
+    if (isKeyRawEnter(e))             # if return was pressed
{% endhighlight %}

### Ignoring newlines when we need to submit

When a user hits `Return` on a physical keyboard, we want to prevent the insertion of a newline, and submit the form instead. Since characters are typed on `keydown`, we need to cancel the event at this time and then see how to deal with it on `keyup`.

{% highlight coffeescript %}
# ...

interceptEnterKey = ($message) ->
  start = 0                           # initialize var start
  keyTimes = []                       # array to store times

  $message.keydown (e) ->             # get the event here too
    start = new Date().getTime()      # set start to current time

    if isKeyRawEnter(e)               # if return was pressed
      e.preventDefault()              # cancel newline insertion

  $message.keyup (e) ->               # we will be using the event now
    keyTimes.push(new Date().getTime() - start) # store the difference

    if isKeyRawEnter(e)               # if return was pressed
      sumKeyTime = keyTimes.reduce (x, y) -> x + y # sum up the times
      avgKeyTime = sumKeyTime / keyTimes.length    # find the average time
      keyTimes = []                   # reset the key press times

      if avgKeyTime > 25              # match physical keyboards
        $(this.form).submit()         # send the message
      else                            # match virtual keyboards
        $message.val($message.val()+"\n") # add the newline back

# ...
{% endhighlight %}

### iOS wasn't completely working all along

At this point, I ran into a bug. When using the virtual keyboard on iOS, <kbd>Return</kbd> wasn't sending the message (which is correct), but it wasn't adding the newline either. Apparently, the virtual keyboard on iOS doesn't give the key code on `keyup`, but only on `keydown`. To counter this, I had to add another variable to keep track of <kbd>Return</kbd> on `keydown` to use later on `keyup`. Android doesn't have this problem.

{% highlight coffeescript %}
# ...

interceptEnterKey = ($message) ->
  start = 0                           # initialize var start
  keyTimes = []                       # array to store times
  isEnter = false                     # keep track of return key

  $message.keydown (e) ->             # get the event here too
    start = new Date().getTime()      # set start to current time

    if isKeyRawEnter(e)               # if return was pressed
      e.preventDefault()              # cancel newline insertion
      isEnter = true
    else
      isEnter = false
    return                            # ensure we don't return false

  $message.keyup (e) ->               # we will be using the event now
    keyTimes.push(new Date().getTime() - start) # store the difference

    if isEnter                        # if return was detected on keydown
      sumKeyTime = keyTimes.reduce (x, y) -> x + y # sum up the times
      avgKeyTime = sumKeyTime / keyTimes.length    # find the average time
      keyTimes = []                   # reset the key press times

      if avgKeyTime > 25              # match physical keyboards
        $(this.form).submit()         # send the message
      else                            # match virtual keyboards
        $message.val($message.val()+"\n") # add the newline back

# ...
{% endhighlight %}

### Internet Explorer, of course

No surprise here, but all versions of Internet Explorer (and I believe Edge as well) like to put the caret at the top when a newline is inserted programatically. At least I think it was IE. I can't remember exactly, but IE is definitely the browser to blame for all our troubles. So, to complete this solution, we need to ensure that the caret gets moved to the end of the input field after we insert a newline.

{% highlight coffeescript %}
moveCaretToEnd = (el) ->
  if typeof el.selectionStart == "number"
    el.selectionStart = el.selectionEnd = el.value.length
  else if typeof el.createTextRange != "undefined"
    el.focus()
    range = el.createTextRange()
    range.collapse(false)
    range.select()

# ...
{% endhighlight %}

{% highlight diff %}
      else                            # match virtual keyboards
        $message.val($message.val()+"\n") # add the newline back
+        moveCaretToEnd($message[0])   # move caret to end
{% endhighlight %}

## TL;DR

The average time difference between `keydown` and `keyup` can be a good indicator of whether a user is typing on a physical or virtual keyboard. Here is the full code to an example that sends the message when <kbd>Return</kbd> is pressed on a physical keyboard and adds a newline when pressed on a virtual keyboard.

{% highlight coffeescript %}
moveCaretToEnd = (el) ->
  if typeof el.selectionStart == "number"
    el.selectionStart = el.selectionEnd = el.value.length
  else if typeof el.createTextRange != "undefined"
    el.focus()
    range = el.createTextRange()
    range.collapse(false)
    range.select()

isKeyRawEnter = (e) ->
  !e.ctrlKey && !e.altKey && !e.shiftKey && !e.metaKey && e.keyCode == 13

interceptEnterKey = ($message) ->
  start = 0                           # initialize var start
  keyTimes = []                       # array to store times
  isEnter = false                     # keep track of return key

  $message.keydown (e) ->             # get the event here too
    start = new Date().getTime()      # set start to current time

    if isKeyRawEnter(e)               # if return was pressed
      e.preventDefault()              # cancel newline insertion
      isEnter = true
    else
      isEnter = false
    return                            # ensure we don't return false

  $message.keyup (e) ->               # we will be using the event now
    keyTimes.push(new Date().getTime() - start) # store the difference

    if isEnter                        # if return was detected on keydown
      # Note: Array.reduce is an ES5 function.
      # Use a polyfill if you need IE8 support.
      sumKeyTime = keyTimes.reduce (x, y) -> x + y # sum up the times
      avgKeyTime = sumKeyTime / keyTimes.length    # find the average time
      keyTimes = []                   # reset the key press times

      if avgKeyTime > 25              # match physical keyboards
        $(this.form).submit()         # send the message
      else                            # match virtual keyboards
        $message.val($message.val()+"\n") # add the newline back
        moveCaretToEnd($message[0])   # move caret to end

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

## TODO

There may be a way to simplify this whole thing by doing most of the work straight in the `keydown` handler. I recently checked out how Facebook's messenger works, and it indeed handles everything on `keydown` rather than `keyup`. This would fix the IE and iOS issues, theoretically.
