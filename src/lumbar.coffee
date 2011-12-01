window.lumbar =
  version: "0.0.1"
  start: (mountPoint) ->
    console.log "lumbar.start", arguments...
          
    lumbar.root.render()
    lumbar.root.render() #test

_.mixin obj: (key, value) ->
  hash = {}
  hash[key] = value
  hash

class lumbar.Emitter
  bind: (event, listener) =>
    @listeners ?= {}
    (@listeners[event] ?= []).push(listener)
    @
  emit: (event, args...) =>
    #console.log "limber.Emitter::emit", arguments...
    @listeners ?= {}
    listener(args...) for listener in @listeners[event] if @listeners[event]
    @
  
class lumbar.View extends lumbar.Emitter
  @attach: (mountPoint, childView) ->
    @attachedViews ?= []
    @attachedViews.push
      mountPoint: mountPoint
      childView: childView
  
  @attachAll: (mountPoint, childViewClass) ->
    @attachedAllViews ?= []
    @attachedAllViews.push
      mountPoint: mountPoint
      childViewClass: childViewClass
  
  newElementMountPoint: "<div>" # Anonymous, unattached div
  mountMethod: "html"
  
  createElement: ->
    @$ = $(@newElementMountPoint)
    @emit "created"
  setMountPoint: (@$) -> @emit "mounted"
  setMountMethod: (@mountMethod) ->
  getViewModel: -> _.extend {}, @model?.toJSON()
  
  render: =>
    @createElement() unless @$
    @$[@mountMethod] $(CoffeeKup.render @template, @getViewModel())
    @emit "render"
    @renderAttachedViews()
    @
  
  renderAttachedViews: ->
    if @attachedViews
      for {mountPoint, childView} in @attachedViews
        childView.setMountPoint if mountPoint is "@" then @$ else @$.find(mountPoint)
        childView.render()
    if @attachedAllViews and @collection
      for model in @collection
        for {mountPoint, childViewClass} in @attachedAllViews
          childView = new childViewClass(model: model)
          childView.setMountPoint if mountPoint is "@" then @$ else @$.find(mountPoint)
          childView.setMountMethod "append"
          childView.render()    
    @
    
  initialize: ->
  
  constructor: (options = {}) ->
    @collection = options.collection
    @model = options.model
    
    @attach = @constructor.attach
    @attach(mountPoint, childView) for {mountPoint, childView} in @constructor.attachedViews if @constructor.attachedViews
    
    @attachAll = @constructor.attachAll
    @attachAll(mountPoint, childViewClass) for {mountPoint, childViewClass} in @constructor.attachedAllViews if @constructor.attachedAllViews
    
    @initialize(arguments...)
  
  

class lumbar.Model extends lumbar.Emitter
  @field: (name, options) ->
    @fields ?= {}
    @fields[name] = options || {}
    
  toJSON: ->
    json = {}
    json[name] = @get(name) for name, getter of @getters
    json
    
  field: (name, options) ->
    self = @
    @attributes[name] = null
    @getters[name] = ->
      self.attributes[name]
    @setters[name] = (value) ->
      unless value == self.attributes[name]
        self.attributes[name] = value
        self.emit "change:#{name}", self
    @
  
  initialize: ->
    
  constructor: (attributes = {}) ->
    @attributes = {}
    @getters = {}
    @setters = {}
    
    self = @
    
    @field(name, options) for name, options of @constructor.fields
    @set(attributes)
    
    @initialize(arguments...)

    
  viewModel: -> _.extend {}, @attributes
  
  get: (name) -> @getters[name]?()
  set: (nameOrHash, valueOrNull) ->
    hash = 
      if _.isObject(nameOrHash) then nameOrHash
      else _.obj(nameOrHash, valueOrNull)
    for name, value of hash
      @setters[name]?(value)
    @


lumbar.root = new class extends lumbar.View
  newElementMountPoint: "body"
  template: ->
    div "#wrapper", ->
      div "#pages", ->
