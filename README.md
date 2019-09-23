# scheduler

Schedule an event based on the scheduling configs (e.g. hourly, daily, weekly, monthly)

Following is an example how Scheduler can be used to fire events on given times. First a Scheduler instance need to be created specifying
timezone where the configs are given, the working directory to save times where latest events have been fired.

```coffeescript

  Scheduler = require './scheduler'
  debugger
  Scheduler = new Scheduler +5.5, './', 5000
  Scheduler.addEvent 'event_min',
   {
    type: 'interval'
    options:
     interval: 60000
   }
   ->
    console.log 'called 1 min interval'
  
  Scheduler.addEvent 'event_hourly',
   {
    type: 'hourly'
    options:
     minute: 38
   }
   ->
    console.log 'called hourly'
  
  Scheduler.addEvent 'event_daily',
   {
    type: 'daily'
    options:
     hour: 22
     minute: 42
   }
   ->
    console.log 'called daily'
  
  Scheduler.addEvent 'event_weekly',
   {
    type: 'weekly'
    options:
     day: 'wed'
     hour: 23
     minute: 0
   }
   ->
    console.log 'called weekly'
  
  Scheduler.start()

```
