Base = require './base'

DAY = 24 * 60 * 60 * 1000

class DailyScheduler extends Base
 @extend()

 _key: -> "#{@hour}:#{@min}"

 _parseOptions: ->
  @hour = parseInt @opt.hour
  @min = parseInt @opt.minute
  if not @hour? or isNaN @hour
   throw new Error "Scheduler missing/invalid hour value in scheduler #{@id}"
  if not @min? or isNaN @min
   throw new Error "Scheduler missing/invalid minute value in scheduler #{@id}"
  @hour = @hour % 24
  @min = @min % 60

 _nextTime: (Time) ->
  cur = new Date Time
  next = new Date cur.getFullYear(), cur.getMonth(), cur.getDate(), @hour, @min
  time = next.getTime()
  if time <= cur.getTime()
   time += DAY
  return time

 _lastTime: (Time) -> (@_nextTime Time) - DAY

module.exports = (Types) ->
 Types.daily = DailyScheduler

