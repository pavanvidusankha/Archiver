Scheduler = require './scheduler'
debugger
Scheduler = new Scheduler +5.5, './', 5000
Scheduler.addEvent 'event1',
 {
  type: 'interval'
  options:
   interval: 5000
   runOnStart: on
 }
 (done) ->
  console.log 'called interval'
  setTimeout done, 60000
 on

Scheduler.addEvent 'event2',
 {
  type: 'hourly'
  options:
   minute: 24
 }
 ->
  console.log 'called hourly'


Scheduler.addEvent 'event_daily',
 {
  type: 'daily'
  options:
   hour: 15
   minute: 37
 }
 ->
  console.log 'called daily'

Scheduler.addEvent 'event_weekly',
 {
  type: 'weekly'
  options:
   day: 'sun'
   hour: 15
   minute: 39
 }
 ->
  console.log 'called weekly'

Scheduler.addEvent 'event_monthly',
 {
  type: 'monthly'
  options:
   date: 17
   hour: 15
   minute: 41
 }
 ->
  console.log 'called monthly'

Scheduler.start()
