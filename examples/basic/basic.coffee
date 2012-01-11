# Define some models

class Clock extends lumbar.Model
  @field "clock"
  
  tick: =>
    @set "clock", new Date()
    setTimeout(@tick, 1000)
  initialize: -> @tick()

class Article extends lumbar.Model
  @field "title"
  @field "description"



# Create a 'collection' (for now just an array)

articles = [
  new Article(title: "The first article", description: "The description of the first article")
  new Article(title: "The second article", description: "The description of the second article")
]


# Define the page's views

class HeaderView extends lumbar.View
  template: ->
    h1 "Header"
    time ".clock", @clock.toString()
    
  initialize: ->
    @model.bind "change:clock", @render

class ArticleView extends lumbar.View
  template: ->
    article ->
      h1 @title
      p @description

class ArticlesView extends lumbar.View
  @attachAll "@", ArticleView
  
  template: ->

class EditorView extends lumbar.View
  template: ->
    div "#editor", ->
    
  initialize: ->
    CoffeeMode = require("ace/mode/coffee").Mode
    @bind "render", ->
      @editor = ace.edit("editor")
      @editor.getSession().setTabSize(2)
      @editor.getSession().setUseSoftTabs(true)
      @editor.getSession().setMode new CoffeeMode




class PageView extends lumbar.View
  @attach ".header", new HeaderView(model: new Clock)
  @attach ".articles", new ArticlesView(collection: articles)
  
  template: ->
    header ".header", ->
    section ".articles", ->
  


# Attach the root page view to the root element

lumbar.root.attach "#pages", new PageView