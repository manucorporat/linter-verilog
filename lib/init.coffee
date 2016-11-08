{ CompositeDisposable } = require 'atom'
path = require 'path'

lint = (editor) ->
  helpers = require('atom-linter')
  file = editor.getPath()
  dirname = path.dirname(file)
  simulator = atom.config.get('linter-verilog.simulator')
  extra_args = atom.config.get('linter-verilog.extraOptions')
  args = ("#{arg}" for arg in extra_args)
  messages = []

  if simulator == 'verilator'
     regex = /%([^:]+):([^:]+):([^:]+):(.+)/
     args = args.concat ['-Wall', '--lint-only', '-I'+dirname, file]

     helpers.exec('verilator', args, {stream: 'both'}).then (output) ->
       lines = output.stderr.split("\n")
       
       for line in lines
         if line.length == 0
           continue;

         console.log(line)
         parts = line.match(regex)

         if !parts || parts.length != 5
           console.debug("Droping line:", line)
         else
           message_type = ''
           if (/error/i.test(parts[1]))
              message_type = 'Error'
           else if (/warning/i.test(parts[1]))
              message_type = 'Warning'
           else
              message_type = parts[1]

           message =
             filePath: parts[2].trim()
             range: helpers.rangeFromLineNumber(editor, parseInt(parts[3])-1, 0)
             type : message_type
             text: parts[4].trim()

           messages.push(message)
           console.debug(simulator, " message:", message)

       return messages
  else
     regex = /((?:[A-Z]:)?[^:]+):([^:]+):(.+)/
     args = args.concat ['-t', 'null', '-I', dirname,  file]

     helpers.exec('iverilog', args, {stream: 'both'}).then (output) ->
       lines = output.stderr.split("\n")

       for line in lines
         if line.length == 0
           continue;

         console.log(line)
         parts = line.match(regex)

         if !parts || parts.length != 4
           console.debug("Droping line:", line)
         else
           message =
             filePath: parts[1].trim()
             range: helpers.rangeFromLineNumber(editor, parseInt(parts[2])-1, 0)
             type: 'Error'
             text: parts[3].trim()

           messages.push(message)
           console.debug(simulator, " message:", message)

       return messages

module.exports =
  config:
    simulator:
      type: 'string'
      default:'verilator'
      enum: ['verilator', 'iverilog']
    extraOptions:
      type: 'array'
      default: ['--default-language','1800-2012']
      description: 'Comma separated list of iverilog options'
  activate: ->
    require('atom-package-deps').install('linter-verilog')

  provideLinter: ->
    provider =
      grammarScopes: ['source.verilog']
      scope: 'project'
      lintOnFly: false
      name: 'Verilog'
      lint: (editor) => lint(editor)
