---
---

isKeyRawEnter = (e) ->
  !e.ctrlKey && !e.altKey && !e.shiftKey && !e.metaKey && e.keyCode == 13


interceptEnterKey = ($message) ->
  start = 0                           # initialize var start
  keyTimes = []                       # array to store times

  $message.keydown (e) ->             # event to determine key(s)
    start = new Date().getTime()      # set start to current time

    if isKeyRawEnter(e)               # if return was pressed
      if !keyTimes.length             # if it was the first key pressed
        e.preventDefault()            # cancel newline insertion and
        return                        # exit function immediately

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


# A few extra tricks for static sites
$ ->
  $('#message-form').submit (e) ->
    e.preventDefault()
    $message = $('#message_body')

    if $message.val()
      $('.messages').append(
        $('<div class="message"></div>').append(
          $message.val().replace(/\n/g, '<br>')))
      $message.val('')
