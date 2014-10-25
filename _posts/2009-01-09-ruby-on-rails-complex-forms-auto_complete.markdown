---
layout: post
title: "Ruby on Rails: Complex forms + auto_complete"
date: 2009-01-09 18:59
categories: web-development
redirect_from: /posts/9-ruby-on-rails-complex-forms-auto_complete/
---

I haven't written here in a long time, so as many of you might not know yet, I've been learning Ruby on Rails the past 4 or 5 months. I'll have to say I've run into some pretty big challenges, but overall Ruby on Rails is one awesome framework. My latest challenge has been getting DHH's auto_complete plugin to work with Ryan Bates' complex forms. It might not be the best way to do it, but the solution was to monkey patch `ActionView::FormHelper` and `FormBuilder` which I put in a seperate file in the `/lib` folder of my project. So without further ado, here's the code:

{% highlight ruby %}
## lib/auto_complete_form_helper.rb
module ActionView
  module Helpers
    module FormHelper
      def text_field_with_auto_complete_mod(object, method, tag_options = {}, completion_options = {})
        sanitized_object = object.gsub(/\]\[|[^-a-zA-Z0-9:.]/, "_").sub(/_$/, "")
        sanitized_method = method.to_s.sub(/\?$/,"")
        (completion_options[:skip_style] ? "" : auto_complete_stylesheet) +
        text_field(object, method, tag_options) +
        content_tag("div", "", :id => "#{sanitized_object}_#{sanitized_method}_auto_complete", :class => "auto_complete") +
        auto_complete_field("#{sanitized_object}_#{sanitized_method}", { :url => { :action => "auto_complete_for_#{sanitized_object}_#{sanitized_method}" } }.update(completion_options))
      end
    end

    class FormBuilder
      def text_field_with_auto_complete(method, tag_options = {}, completion_options = {})
        @template.text_field_with_auto_complete_mod(@object_name, method,
          objectify_options(tag_options), completion_options)
      end
    end
  end
end
{% endhighlight %}

Don't forget to include the file in your `environment.rb`. If you see any bugs or know of a better way (I couldn't find any solutions on the web), please let me know.
