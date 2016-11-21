{ api } = require './es'

template =
  template: 'hotkeys-*'
  mappings:
    hotkey:
      dynamic_templates: [
        default_strings:
          match_mapping_type: 'string'
          mapping:
            type: 'string'
            index: 'not_analyzed'
      ]

api 'PUT', '/_template/hotkeys', JSON.stringify(template)
  .then ->
    console.log 'Template uploaded successfully.'
  .catch (e) ->
    console.log "ERROR: #{e}\n#{e.stack}"
