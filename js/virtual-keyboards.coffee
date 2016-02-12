---
---

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


# A few extra tricks for static sites
$ ->
  $('#message-form').submit (e) ->
    e.preventDefault()
    $message = $('#message_body')

    if $message.val()
      $('.messages').append(
        $('<div class="message"></div>').append(
          $message.val()))
      $message.val('')
