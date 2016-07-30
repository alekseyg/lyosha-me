;(function () {
  var isKeyRawEnter = function isKeyRawEnter (e) {
    return !e.ctrlKey && !e.altKey && !e.shiftKey && !e.metaKey && e.keyCode === 13
  }

  var interceptEnterKey = function interceptEnterKey ($message) {
    var start = 0                       // initialize var start
    var keyTimes = []                   // array to store times

    $message.keydown(function (e) {     // event to determine key(s)
      var start = new Date().getTime()  // set start to current time

      if (isKeyRawEnter(e)) {           // if return was pressed
        if (!keyTimes.length) {         // if it was the first key pressed
          e.preventDefault()            // cancel newline insertion and
          return                        // exit function immediately
        }

        // Note: Array.reduce is an ES5 function.
        // Use a polyfill if you need IE8 support.
                                                        // sum up the times
        var sumKeyTime = keyTimes.reduce(function (x, y) { return x + y })
        var avgKeyTime = sumKeyTime / keyTimes.length   // find the average time

        if (avgKeyTime > 25) {          // match physical keyboards
          e.preventDefault()            // cancel newline insertion
          keyTimes = []                 // reset the key press times
          $(this.form).submit()         // send the message
        }
      }
    })

    $message.keyup(function () {
      keyTimes.push(new Date().getTime() - start) // store the difference
    })
  }

  var initTextArea = function initTextArea () {
    $message = $('#message_body')
    interceptEnterKey($message)
  }

  $(initTextArea)


  // A few extra tricks for static sites
  $(function () {
    $('#message-form').submit(function (e) {
      e.preventDefault()
      var $messageBody = $('#message_body')

      if ($messageBody.val()) {
        var $message = $('<div class="message"></div>')
        .append($messageBody.val().replace(/\n/g, '<br>'))
        $('.messages').append($message)
        $messageBody.val('')
      }
    })
  })
})();
