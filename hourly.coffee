Base = require './base'

HOUR = 60 * 60 * 1000

class HourlyScheduler extends Base
 @extend()

 _key: -> @min

 _parseOptions: ->
  @min = parseInt @opt.minute
  if not @min? or isNaN @min
   throw new Error "Scheduler missing/invalid minute value in scheduler #{@id}"
  @min = @min % 60

 _nextTime: (Time) ->
  d = new Date Time
  m = d.getMinutes()
  h = d.getHours()
  dd = new Date d.getFullYear(), d.getMonth(), d.getDate(), h, @min
  time = dd.getTime()
  if @min <= m
   time += HOUR
  return time

 _lastTime: (Time) -> (@_nextTime Time) - HOUR

module.exports = (Types) ->
 Types.hourly = HourlyScheduler
