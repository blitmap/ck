ck = require './lib/ck'
coffeekup = require 'coffeekup'

template = ->
  doctype 5
  html ->
    head ->
      title @title
    body ->
      div id: 'content', ->
        if @posts?
          for p in @posts
            div class: 'post', ->
              p p.name
              div p.comment
      form method: 'post', ->
        ul ->
          li -> input name: 'name'
          li -> textarea name: 'comment'
          li -> input type: 'submit'

ck_template = ck.compile template
coffeekup_template = coffeekup.compile template

benchmark = (name, fn) ->
  start = new Date
  fn() for i in [ 0 ... 10000 ]
  end = new Date

  console.log "#{name}: #{end - start}ms"

title = 'my first website!'
posts = []

module.exports = ->
  benchmark 'ck',                 -> ck_template        context: { title, posts }
  benchmark 'ck (format)',        -> ck_template        context: { title, posts }, format: true
  benchmark 'coffeekup',          -> coffeekup_template { title, posts }
  benchmark 'coffeekup (format)', -> coffeekup_template { title, posts, format: true }

module.exports() if require.main is module
