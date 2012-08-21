// Generated by CoffeeScript 1.3.3
(function() {

  $(function() {
    var aliases, showdown;
    showdown = (new Showdown.converter).makeHtml;
    aliases = {
      bash: 'shell',
      cpp: 'c',
      cs: 'c#',
      vbscript: 'visualbasic'
    };
    $.each(aliases, function(a, b) {
      return hljs.LANGUAGES[b] = hljs.LANGUAGES[a];
    });
    return $('#query').submit(function() {
      $('#results').empty();
      $.getJSON('/search?' + $(this).serialize(), function(results) {
        if (results['error']) {
          alert(results['error']);
          return;
        }
        return $.each(results, function(i, res) {
          var dp, lang, result;
          lang = res['language'].toLowerCase().replace(/[^a-z#]+/, '');
          result = $('<div />', {
            "class": 'result'
          });
          result.append("<b>" + res['author'] + " | " + res['language'] + " | </b>");
          result.append("<b>" + res['length'] + " characters</b><br />");
          dp = 'http://reddit.com/r/dailyprogrammer/comments';
          result.append("<a href='" + dp + "/" + res['ref'] + "/_/" + res['id'] + "'>" + res['title'] + "</a>");
          result.append(showdown(res['code']));
          $('pre code', result).each(function(i, elem) {
            if (hljs.LANGUAGES[lang]) {
              elem.className = lang;
            }
            return hljs.highlightBlock(elem);
          });
          return $('#results').append(result);
        });
      });
      return false;
    });
  });

}).call(this);