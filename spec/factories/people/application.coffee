Factory     = require 'factory-lady'
Application = require '../../../app/models/people/application'

Factory.define 'application', Application,
  secret: '821902af3111cd8732991af017109000bd000019287300478dc0912381384aa89472389312'
