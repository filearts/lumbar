window.todos =
  version: "0.0.1"


class Task extends lumbar.Model
  @persist "description"
  @persist "done"
  
  defaults:
    done: false
    description: ""
    editing: false
  
  toggle: -> @save done: !@get("done")
  
  
todos.tasks = new class extends lumbar.Collection
  model: Task
  localStorage: new Store("todos")



lumbar.view "todos.item", class extends lumbar.View
  mountPoint: "<li></li>"
  mountOptions: ->
    "class": "todo" + (if @model?.get("done") then " done" else "")
    
  template: ->
    unless @editing 
      div ".display", ->
        if @done then input ".check", type: "checkbox", checked: "checked"
        else input ".check", type: "checkbox"
        div ".todo-text", @description
        span ".todo-destroy", ""
    else
      div ".edit", ->
        input ".todo-input", type="text", value=""
        
  events:
    "click .check"            : (e) -> @model.save done: !@model.get("done")
    "dblclick div.todo-text"  : (e) -> @model.set editing: true
    "click span.todo-destroy" : (e) -> @model.destroy()
    "keypress .todo-input"    : (e) -> @model.save description: $(e.target).val(), editing: false if e.keyCode is 13


todos.view = new class extends lumbar.View
  mountPoint: "body"
  template: ->
    div "#todoapp", ->
      div ".title", ->
        h1 "Todos"
      div ".content", ->
        div "#create-todo", ->
          input "#new-todo", placeholder: "What needs doing?", type: "text"
          span ".ui-tooltip-top", style: "display: none", "Press Enter to save this task"
        div "#todos", ->
          ul "#todo-list", ->
            $c("todos.tasks", "todos.item")
  events:
    "keypress #new-todo"    : (e) ->
      if e.keyCode is 13 and value = $(e.target).val()
        todos.tasks.create description: value
        $(e.target).val("")


todos.tasks.fetch()
todos.view.render()
