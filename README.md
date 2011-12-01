# Lumbar

Lumbar is a Backbone.js-like system for organizing your client-side Coffee-Script code.

## Why Lumbar?

Advantages:

* Lumbar makes setting up a hierarchy of views much easier than Backbone.js
* Your view code, logic and templates are all written in Coffee-Script thanks to
  CoffeeKup.

## Example

```coffeescript
# Define the view for each article
class ArticleView extends lumbar.View
  # Define the template of each article
  template: ->
    article ->
      h1 @title
      p @description

# Define the container view for the collection of articles
class ArticlesView extends lumbar.View
  # Create an ArticleView with each model in this view's collection
  @attachAll "#articles", ArticleView
  
  template: ->
    section "#articles", ->
```

## Credits

* [Coffee-Script](http://jashkenas.github.com/coffee-script/) by Jeremy Ashkenas
* [Underscore.js](http://documentcloud.github.com/underscore/) by DocumentCloud
* [CoffeeKup](https://github.com/mauricemach/coffeekup) by Maurice Machado