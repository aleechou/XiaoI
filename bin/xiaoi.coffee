#! /usr/bin/env coffee
xiaoi = require '../index.coffee'
termcss = require 'term-css'

fs = require('fs')
style = fs.readFileSync __dirname+'/xiaoi.css', 'utf8'

do console.log
console.log ( termcss.compile('{title}',style) (title:'  这是一个小ｉ机器人的客户端') )
console.log ( termcss.compile('        crack by {author}',style) (author:'alee') )
do console.log


xiaoi.connect (err,client)->

    if err
        console.log "can not connect to i.xiaoi.com, #{ err.toString() }"
        return ;

    process.stdin.on 'data', (data)->

        if not listening then return

        data = data.toString()

        if data
            client.send data, (err,reply)->
                if err
                    console.error err.stack
                else if reply and reply.body
                    console.log 
                    process.stdout.write termcss.compile('小I say {prompt} {sentence}',style) ({
                            prompt:'>'
                            sentence: reply.body.content
                        })

                listen()
        else
            listen()



    listening = false ;
    listen = ->
        listening = true ;
        process.stdout.write termcss.compile('you say {prompt} ',style) (prompt:'>')

    listen()
