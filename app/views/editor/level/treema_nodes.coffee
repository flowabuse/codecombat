WorldSelectModal = require './modals/WorldSelectModal'
ThangType = require '/models/ThangType'
LevelComponent = require 'models/LevelComponent'
CocoCollection = require 'collections/CocoCollection'

makeButton = -> $('<a class="btn btn-primary btn-xs treema-map-button"><span class="glyphicon glyphicon-screenshot"></span></a>')
shorten = (f) -> parseFloat(f.toFixed(1))
WIDTH = 924

module.exports.WorldPointNode = class WorldPointNode extends TreemaNode.nodeMap.point2d
  constructor: (args...) ->
    super(args...)
    console.error 'Point Treema node needs a World included in the settings.' unless @settings.world?
    console.error 'Point Treema node needs a RootView included in the settings.' unless @settings.view?

  buildValueForDisplay: (valEl, data) ->
    super(valEl, data)
    valEl.find('.treema-shortened').prepend(makeButton())

  buildValueForEditing: (valEl, data) ->
    super(valEl, data)
    valEl.find('.treema-shortened').prepend(makeButton())

  onClick: (e) ->
    btn = $(e.target).closest('.treema-map-button')
    if btn.length then @openMap() else super(arguments...)

  openMap: ->
    modal = new WorldSelectModal(world: @settings.world, dataType: 'point', default: @getData(), supermodel: @settings.supermodel)
    modal.callback = @callback
    @settings.view.openModalView modal

  callback: (e) =>
    return unless e?.point?
    @data.x = shorten(e.point.x)
    @data.y = shorten(e.point.y)
    @refreshDisplay()

class WorldRegionNode extends TreemaNode.nodeMap.object
  # this class is not yet used, later will be used to configure the Physical component

  constructor: (args...) ->
    super(args...)
    console.error 'Region Treema node needs a World included in the settings.' unless @settings.world?
    console.error 'Region Treema node needs a RootView included in the settings.' unless @settings.view?

  buildValueForDisplay: (valEl, data) ->
    super(valEl, data)
    valEl.find('.treema-shortened').prepend(makeButton())

  buildValueForEditing: (valEl, data) ->
    super(valEl, data)
    valEl.find('.treema-shortened').prepend(makeButton())

  onClick: (e) ->
    btn = $(e.target).closest('.treema-map-button')
    if btn.length then @openMap() else super(arguments...)

  openMap: ->
    modal = new WorldSelectModal(world: @settings.world, dataType: 'region', default: @createWorldBounds(), supermodel: @settings.supermodel)
    modal.callback = @callback
    @settings.view.openModalView modal

  callback: (e) =>
    x = Math.min e.points[0].x, e.points[1].x
    y = Math.min e.points[0].y, e.points[1].y
    @data.pos = {x: x, y: y, z: 0}
    @data.width = Math.abs e.points[0].x - e.points[1].x
    @data.height = Math.min e.points[0].y - e.points[1].y
    @refreshDisplay()

  createWorldBounds: ->
    # not yet written

module.exports.WorldViewportNode = class WorldViewportNode extends TreemaNode.nodeMap.object
  # selecting ratio'd dimensions in the world, ie the camera in level scripts
  constructor: (args...) ->
    super(args...)
    console.error 'Viewport Treema node needs a World included in the settings.' unless @settings.world?
    console.error 'Viewport Treema node needs a RootView included in the settings.' unless @settings.view?

  buildValueForDisplay: (valEl, data) ->
    super(valEl, data)
    valEl.find('.treema-shortened').prepend(makeButton())

  buildValueForEditing: (valEl, data) ->
    super(valEl, data)
    valEl.find('.treema-shortened').prepend(makeButton())

  onClick: (e) ->
    btn = $(e.target).closest('.treema-map-button')
    if btn.length then @openMap() else super(arguments...)

  openMap: ->
    # can't really get the bounds from this data, so will have to hack this solution
    options = world: @settings.world, dataType: 'ratio-region'
    data = @getData()
    options.defaultFromZoom = data if data?.target?.x?
    options.supermodel = @settings.supermodel
    modal = new WorldSelectModal(options)
    modal.callback = @callback
    @settings.view.openModalView modal

  callback: (e) =>
    return unless e
    target = {
      x: shorten((e.points[0].x + e.points[1].x) / 2)
      y: shorten((e.points[0].y + e.points[1].y) / 2)
    }
    @set('target', target)
    bounds = e.camera.normalizeBounds(e.points)
    @set('zoom', shorten(WIDTH / bounds.width))
    @refreshDisplay()

module.exports.WorldBoundsNode = class WorldBoundsNode extends TreemaNode.nodeMap.array
  # selecting camera boundaries for a world
  dataType: 'region'

  constructor: (args...) ->
    super(args...)
    console.error 'Bounds Treema node needs a World included in the settings.' unless @settings.world?
    console.error 'Bounds Treema node needs a RootView included in the settings.' unless @settings.view?

  buildValueForDisplay: (valEl, data) ->
    super(valEl, data)
    valEl.find('.treema-shortened').prepend(makeButton())

  buildValueForEditing: (valEl, data) ->
    super(valEl, data)
    valEl.find('.treema-shortened').prepend(makeButton())

  onClick: (e) ->
    btn = $(e.target).closest('.treema-map-button')
    if btn.length then @openMap() else super(arguments...)

  openMap: ->
    bounds = @getData() or [{x: 0, y: 0}, {x: 100, y: 80}]
    modal = new WorldSelectModal(world: @settings.world, dataType: 'region', default: bounds, supermodel: @settings.supermodel)
    modal.callback = @callback
    @settings.view.openModalView modal

  callback: (e) =>
    return unless e
    @set '/0', {x: shorten(e.points[0].x), y: shorten(e.points[0].y)}
    @set '/1', {x: shorten(e.points[1].x), y: shorten(e.points[1].y)}

module.exports.ThangNode = class ThangNode extends TreemaNode.nodeMap.string
  buildValueForDisplay: (valEl, data) ->
    super(valEl, data)
    valEl.find('input').autocomplete(source: @settings.thangIDs, minLength: 0, delay: 0, autoFocus: true)
    valEl

module.exports.TeamNode = class TeamNode extends TreemaNode.nodeMap.string
  buildValueForDisplay: (valEl, data) ->
    super(valEl, data)
    valEl.find('input').autocomplete(source: @settings.teams, minLength: 0, delay: 0, autoFocus: true)
    valEl

module.exports.SuperteamNode = class SuperteamNode extends TreemaNode.nodeMap.string
  buildValueForEditing: (valEl, data) ->
    super(valEl, data)
    valEl.find('input').autocomplete(source: @settings.superteams, minLength: 0, delay: 0, autoFocus: true)
    valEl

module.exports.RadiansNode = class RadiansNode extends TreemaNode.nodeMap.number
  buildValueForDisplay: (valEl, data) ->
    super(valEl, data)
    deg = data / Math.PI * 180
    valEl.text valEl.text() + "rad (#{deg.toFixed(0)}˚)"

module.exports.MetersNode = class MetersNode extends TreemaNode.nodeMap.number
  buildValueForDisplay: (valEl, data) ->
    super(valEl, data)
    valEl.text valEl.text() + 'm'

module.exports.KilogramsNode = class KilogramsNode extends TreemaNode.nodeMap.number
  buildValueForDisplay: (valEl, data) ->
    super(valEl, data)
    valEl.text valEl.text() + 'kg'

module.exports.SecondsNode = class SecondsNode extends TreemaNode.nodeMap.number
  buildValueForDisplay: (valEl, data) ->
    super(valEl, data)
    valEl.text valEl.text() + 's'

module.exports.MillisecondsNode = class MillisecondsNode extends TreemaNode.nodeMap.number
  buildValueForDisplay: (valEl, data) ->
    super(valEl, data)
    valEl.text valEl.text() + 'ms'

module.exports.SpeedNode = class SpeedNode extends TreemaNode.nodeMap.number
  buildValueForDisplay: (valEl, data) ->
    super(valEl, data)
    valEl.text valEl.text() + 'm/s'

module.exports.AccelerationNode = class AccelerationNode extends TreemaNode.nodeMap.number
  buildValueForDisplay: (valEl, data) ->
    super(valEl, data)
    valEl.text valEl.text() + 'm/s^2'

module.exports.ThangTypeNode = class ThangTypeNode extends TreemaNode.nodeMap.string
  valueClass: 'treema-thang-type'
  constructor: (args...) ->
    super args...
    data = @getData()
    @thangType = _.find @settings.supermodel.getModels(ThangType), (m) => m.get('original') is data if data

  buildValueForDisplay: (valEl) ->
    @buildValueForDisplaySimply(valEl, @thangType?.get('name') or 'None')

  buildValueForEditing: (valEl, data) ->
    super(valEl, data)
    thangTypeNames = (m.get('name') for m in @settings.supermodel.getModels ThangType)
    input = valEl.find('input').autocomplete(source: thangTypeNames, minLength: 0, delay: 0, autoFocus: true)
    input.val(@thangType?.get('name') or 'None')
    valEl

  saveChanges: ->
    thangTypeName = @$el.find('input').val()
    @thangType = _.find @settings.supermodel.getModels(ThangType), (m) -> m.get('name') is thangTypeName
    if @thangType
      @data = @thangType.get('original')
    else
      @data = null

module.exports.ItemThangTypeNode = ItemThangTypeNode = class ItemThangTypeNode extends TreemaNode.nodeMap.string
  valueClass: 'treema-item-thang-type'
  @items: null
  @itemsCollection: null

  constructor: ->
    super(arguments...)
    @getItems() 
    unless ItemThangTypeNode.itemsCollection.loaded
      ItemThangTypeNode.itemsCollection.once('sync', @refreshDisplay, @)
     
  buildValueForDisplay: (valEl, data) ->
    @buildValueForDisplaySimply(valEl, @getCurrentItem() or '')
    valEl
    
  buildValueForEditing: (valEl, data) ->
    super(valEl, data)
    if ItemThangTypeNode.items
      source = (item.name for item in ItemThangTypeNode.items when @keyForParent in item.slots)
      input = valEl.find('input').autocomplete(source: source, minLength: 0, delay: 0, autoFocus: true)
    input.val(@getCurrentItem() or '')
    valEl
    
  getCurrentItem: ->
    window.itemData = @getData()
    window.items = ItemThangTypeNode.items
    return null unless ItemThangTypeNode.items
    original = @getData()
    return null unless original
    item = _.find ItemThangTypeNode.items, { original: original }
    item?.name or '...'
    
  getItems: ->
    return if ItemThangTypeNode.itemsCollection
    ItemThangTypeNode.itemsCollection = new CocoCollection([], {
      url: '/db/thang.type'
      project:['name', 'components', 'original']
      model: ThangType
    })
    res = ItemThangTypeNode.itemsCollection.fetch()
    ItemThangTypeNode.itemsCollection.once 'sync', => @processItems(ItemThangTypeNode.itemsCollection)
    
  processItems: (itemCollection) ->
    ItemThangTypeNode.items = []
    for itemThang in itemCollection.models
      itemComponent = _.find itemThang.get('components'), {original: LevelComponent.ItemID}
      continue unless itemComponent
      slots = itemComponent.config?.slots
      continue unless slots?.length
      ItemThangTypeNode.items.push {
        name: itemThang.get('name')
        original: itemThang.get('original')
        slots: slots
      }

  saveChanges: ->
    thangTypeName = @$el.find('input').val()
    item = _.find(ItemThangTypeNode.items, {name: thangTypeName})
    return @remove() unless item
    @data = item.original