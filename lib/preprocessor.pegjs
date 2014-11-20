/*
 * hbars Preprocessor
 * ==========================
 *
 * Replaces occurances of:
 *  - indentation increases with INDENT
 *  - indentation decreases with DEDENT
 *  - line endings with TERM
 *
 * Also:
 *  - removes empty lines
 */

{
  var indentStack = [],
      indent = "",
      INDENT_CHAR = options.INDENT_CHAR || '\uEFEF',
      DEDENT_CHAR = options.DEDENT_CHAR || '\uEFFE',
      TERM_CHAR = options.TERM_CHAR || '\uEFFF';

  function isArray(obj) {
    return Object.prototype.toString.call(obj) === '[object Array]';
  }

  function compact(arr) {
   if (!isArray(arr)) {
      return arr;
   } else {
       return arr.filter( function(elem) {
          return typeof(elem) !== 'undefined'
       } ).map(compact)
   }
  }

  function lastChar(str){
    return str.slice(-1);
  }

}

start
  = INDENT? l:line*
    {
      var lines = compact(l).map(function(line){
        if(lastChar(line) !== '<'){
          line = line + TERM_CHAR
        }
        return line;
      });
      return lines.join('');
    }

line
  = EOL { return } /
    SAMEDENT line:(
      (!EOL c:.
        {
          return c;
        }
      )
    )+ e:EOL?
    children:( i:INDENT c:line* d:DEDENT
    {
      var out = '';
      if(i){
        out = out + i;
      }
      out = out + c.join('');
      if(d){
        out = out + d;
      }
      return out;
    })?
    {
      var out = line.join('');
      if(children){
        out = out + children;
      }
      return out;
    }

EOL
  = "\r\n" / "\n" / "\r"

SAMEDENT
  = i:[ \t]* &{ return i.join("") === indent; }

INDENT "INDENT"
  = &(i:[ \t]+ &{ return i.length > indent.length; }
    {
      indentStack.push(indent);
      indent = i.join('');
      pos = offset;
    })
    {
      return TERM_CHAR + INDENT_CHAR;
    }

DEDENT "DEDENT"
  = {
      indent = indentStack.pop();
      return TERM_CHAR + DEDENT_CHAR;
    }