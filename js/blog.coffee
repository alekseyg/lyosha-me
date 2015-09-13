---
---

filterBlogPosts = ->
  category = location.href.split('#')[1]

  if category
    $('.post').each ->
      $post = $(this)
      categories = $post.data('categories')
      if categories
        categories = categories.split(' ')
        if categories.indexOf(category) > -1
          $post.show()
        else
          $post.hide()
  else
    $('.post').show()


$ ->
  $(window).on 'hashchange', filterBlogPosts
  filterBlogPosts()
