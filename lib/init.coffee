{ CompositeDisposable } = require 'atom'
path = null
helpers = null

# This is inspired by the linter clang package
getVerilogRange = (lineNumber, filePath) ->
  `const allEditors = atom.workspace.getTextEditors();`
  `const matchingEditor = allEditors.find(textEditor =>
    textEditor.getPath() === filePath);`
  if (matchingEditor)
    return helpers.rangeFromLineNumber(matchingEditor,lineNumber,0)
  else
    return [[lineNumber,0],[lineNumber,1]]

lint = (editor) ->
  path ?= require 'path'
  helpers ?= require('atom-linter')
  regex = /((?:[A-Z]:)?[^:]+):(\d+): ([^:]+)(?:: ([^:]+))?/
  file = editor.getPath()
  dirname = path.dirname(file)

  args = ("#{arg}" for arg in atom.config.get('linter-verilog.extraOptions'))
  args = args.concat ['-t'+'null', '-I' + dirname,  file]
  # console.debug("args to iverilog:",args)

  helpers.exec('iverilog', args, {stream: 'both'}).then (output) ->
    lines = output.stderr.split("\n")
    messages = []
    for line in lines
      if line.length == 0
        continue

      parts = line.match(regex)
      # console.debug("Parts",parts)
      if !parts
        console.debug("Dropping line:", line)
      else if parts[4]
        message =
         filePath: path.normalize(parts[1].trim())
         #range: helpers.rangeFromLineNumber(editor,
         #  Math.min(editor.getLineCount(),parseInt(parts[2]))-1, 0)
         range: getVerilogRange(parseInt(parts[2])-1,
          path.normalize(parts[1].trim()))
         type: parts[3].trim()
         text: parts[4].trim()

        messages.push(message)
      else if parts[3]
        message =
          filePath: path.normalize(parts[1].trim())
          #range: helpers.rangeFromLineNumber(editor,
          # Math.min(editor.getLineCount(),parseInt(parts[2]))-1, 0)
          range: getVerilogRange(parseInt(parts[2])-1,
            path.normalize(parts[1].trim()))
          type: 'Error'
          text: parts[3].trim()

        messages.push(message)
      else
        message =
          filePath: path.normalize(file)
          range: 1
          type: 'Error'
          text:line

        messages.push(message)

    if (output == null)
      return null
    else
      return messages

module.exports =
  config:
    extraOptions:
      type: 'array'
      default: ['-g2001, -Wall']
      description: 'Comma separated list of iverilog options'
  activate: ->
    require('atom-package-deps').install('linter-verilog')

  provideLinter: ->
    provider =
      grammarScopes: ['source.verilog']
      scope: 'project'
      lintsOnChange: false
      name: 'Verilog'
      lint: (editor) -> lint(editor)
