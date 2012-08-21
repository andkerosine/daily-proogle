$ ->
  showdown = (new Showdown.converter).makeHtml

  aliases = {bash: 'shell', cpp: 'c', cs: 'c#', vbscript: 'visualbasic'}
  $.each aliases, (a, b) -> hljs.LANGUAGES[b] = hljs.LANGUAGES[a]

  $('#query').submit ->
    $('#results').empty()

    $.getJSON '/search?' + $(this).serialize(), (results) ->
      if results['error']
        alert results['error']
        return
      $.each results, (i, res) ->
        lang = res['language'].toLowerCase().replace /[^a-z#]+/, ''
        result = $ '<div />', class: 'result'
        result.append "<b>#{res['author']} | #{res['language']} | </b>"
        result.append "<b>#{res['length']} characters</b><br />"
        dp = 'http://reddit.com/r/dailyprogrammer/comments'
        result.append "<a href='#{dp}/#{res['ref']}/_/#{res['id']}'>#{res['title']}</a>"
        result .append showdown res['code']
        
        $('pre code', result).each (i, elem) ->
          if hljs.LANGUAGES[lang]
            elem.className = lang
          hljs.highlightBlock elem
        
        $('#results').append result

    false
