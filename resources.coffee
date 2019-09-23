'use strict'
#intializing the node dependencies
fs = require('fs')
path = require('path')
dateFormat = require('dateformat')
exec = require('child_process').execSync
fs1 = require('fs-extra')
date = new Date
module.exports =
  checkname: (fname) ->
    pfname = parseFloat(fname.substring(fname.lastIndexOf('-') + 1, fname.indexOf('.')))
    pfname
  setDtToEpoch: (xc) ->
    st = xc.substr(xc.indexOf('-') + 1, 19)
    re = /_/gi
    news = st.replace(re, '-')
    d = news.split('-')
    epoch = new Date(d[0], d[1] - 1, d[2], d[3], d[4], d[5]).valueOf()
    epoch
  dateconvert: (file) ->
    fDate = file.substr(0, 10)
    pdate = new Date(fDate)
    pdate
  compress: (archiveDir, tempDir, oId, format) ->
    odirectory = path.resolve(archiveDir + oId + '/' + @GetFormattedDate())
    #ensure the directory is exists,otherwise create the directory

    shell_compress = (dest, source) ->
      exec 'tar -cvzf ' + dest + ' -C ' + source, (err, stdout, stderr) ->
        console.log 'Compressed '
        return
      return

    fs1.ensureDirSync odirectory
    source = undefined
    dest = undefined
    if format == 'epoch'
      fs.readdirSync(tempDir).forEach (file) ->
        fullPath = path.join(tempDir, file + '/')
        if fs.lstatSync(fullPath).isDirectory()
          dest = path.resolve(odirectory + '/' + file + '-' + date.getTime() + '.tar.gz')
          source = path.resolve(fullPath + ' .')
          shell_compress dest, source
        return
    else if format == 'date' or format == 'datetime'
      dest = path.resolve(odirectory + '/' + oId + '-' + date.getTime() + '.tar.gz')
      source = path.resolve(tempDir + ' .')
      shell_compress dest, source
    return
  epochval: (keep) ->
    date1 = new Date
    date1.setDate date1.getDate() - keep
    preEP = date1.getTime()
    preEP
  GetFormattedDate: ->
    todayTime = new Date
    dateFormat todayTime, 'yyyy-mm-dd'
  validate: (file, format, kdays) ->
    kDate = undefined
    fileDate = undefined
    if format == 'epoch'
      kDate = @epochval(kdays)
      fileDate = @checkname(file)
    if format == 'datetime'
      kDate = @epochval(kdays)
      fileDate = @setDtToEpoch(file)
    if format == 'date'
      fileDate = @dateconvert(file)
      tDate = new Date
      #Change it so that it is the days in the past.
      pastDate = tDate.getDate() - kdays
      kDate = tDate.setDate(pastDate)
    if fileDate < kDate
      true
    else
      false
  executeFile: (source, dest, status) ->
    if status == 'c'
      fs1.copySync source, dest
      console.log 'copying file ' + dest
    else if status == 'm'
      fs1.moveSync source, dest, overwrite: true
      console.log 'moving file ' + dest
    else if status == 'd'
      fs1.removeSync source
      console.log 'deleting file ' + source
    return

# ---
# generated by js2coffee 2.2.0