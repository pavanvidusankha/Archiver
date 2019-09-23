Base = require './base'

class IntervalScheduler extends Base
 @extend()

 @initialize (@id, @options, @handler, @timezone, @writer, @isDone) ->
  @interval = @opt?.interval
  if not @interval?
   throw new Error "Scheduler missing interval in scheduler #{@id}"
  @runOnStart = @opt.runOnStart
  @runOnStart ?= off
  if @runOnStart is on
   setTimeout @on.run, 0
  @iid = setInterval @on.run, @interval

 @listen 'run', ->
  return if @running is on
  @running = on
  done = =>
   @running = off
  if @isDone is on
   @handler done
  else
   @handler()
   done()

 _nextTime: -> null
 _lastTime: -> null

 @listen 'check', ->

module.exports = (Types) ->
 Types.interval = IntervalScheduler
