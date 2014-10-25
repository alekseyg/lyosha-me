---
layout: post
title: A little PHP CRUD
date: 2009-04-28 15:09
categories: web-development
redirect_from: /posts/10-a-little-php-crud/
---

I had to return to PHP for a small application I had to write for which Rails would have been too big. Being used to Rails RESTful methods and MVC, I didn't want to make another messy 200 line PHP app that I would not be able to read later, so I coded a very small and simple CRUD "router" (as in Rails' routes) and I decided to share it with the world. So far it only works with a "controller" that manages plural resources. The CRUD pattern here is modeled after the way Rails controllers work. It's really simple, but it sure makes coding tiny apps a lot cleaner. (Helpers, clean URLs, MVC, etc. are up to the reader to implement)

crud.php:

{% highlight php %}
<?php
switch($_SERVER['REQUEST_METHOD']) {
  case 'GET':
    switch($_GET['action']) {
      case 'new':
        cnew();
        break;
      case 'edit':
        edit();
        break;
      default:
        if (preg_match('/^[0-9]+$/', $_GET['id']))
          show();
        else
          index();
        break;
    }
    break;
  case 'POST':
    switch($_POST['_method']) {
      case 'put':
        update();
        break;
      case 'delete':
        destroy();
        break;
      default:
        create();
    }
    break;
  case 'PUT':
    update();
    break;
  case 'DELETE':
    destroy();
    break;
}
?>
{% endhighlight %}

index.php (an example "controller"):

{% highlight php %}
<?php
require 'crud.php';

function index() {
  // grab some data
  require 'views/index.php';
}

function cnew() {
  // new resource
}

function show() {
  // get the resource by id
  echo "You requested resource number " . $_REQUEST['id'];
}

function edit() {
  // edit resource
}

function create() {
  // create something
  header('Location: ./');
}

function destroy() {
  //delete something
  header('Location: ./');
}
?>
{% endhighlight %}
