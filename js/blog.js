;(function () {
  var filterBlogPosts = function filterBlogPosts () {
    var category = location.href.split('#')[1]

    if (category) {
      $('.post').each(function () {
        var $post = $(this)
        var catTest = new RegExp('(^| )' + category + '( |$)')

        if (catTest.test($post.data('categories'))) {
          $post.show()
        } else {
          $post.hide()
        }
      })
    } else {
      $('.post').show()
    }
  }

  $(function () {
    $(window).on('hashchange', filterBlogPosts)
    filterBlogPosts()
  })
})();
