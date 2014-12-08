/*
 * hbars Grammar
 * ==========================
 *
 * Accepts a Haml template and produces an AST to create a Handlebars/HTMLBars template
 */

{
  function array(input){
    if(typeof(input) !== 'array'){
      input = [input];
    }
    return input;
  }

  function compact(input){
    if(typeof(input) === 'array'){
      if(input.length === 0){
        return;
      }
    }else if(typeof(input) === 'object'){
      if(Object.keys(input).length === 0){
        return;
      }
    }
    return input;
  }

  function isArray(thing) {
    if( Object.prototype.toString.call(thing) === '[object Array]' ) {
      return true;
    }
    return false;
  }

  function condense(objects) {
    var target = {}, sources;
    if(isArray(objects)){
      sources = objects;
    }else{
      sources = [].slice.call(arguments, 0);
    }
    sources.forEach(function (source) {
      for (var prop in source) {
        if(target[prop]){
          target[prop] = array(target[prop]);
          target[prop].push(source[prop]);
        }else{
          target[prop] = source[prop];
        }
      }
    });
    return target;
  }

  function addProperty(target, key, value) {
    if(Object.keys(value).length > 0){
      target[key] = value;
    }
  }
}

elements
  = (blockElement / mustache)*

mustacheContent
  = c:[a-zA-Z ]+
  { return c.join(''); }

mustache
  = blockChainExpression / blockExpression / mustacheExpression

blockChainExpression
  = b:blockExpression+
  &{
    var top = b[0];
    var mid = b[1];
    if(b.length == 2){
      return top.name === "if" && mid.name === "else";
    }
    return false;
  }
  {
    var top = b[0];
    var mid = b[1];
    var newMid = { type: "mid_block_expression", name: mid.name };
    if(mid.content){
      newMid.content = mid.content;
    }
    top.nodes.push(newMid);
    top.nodes.push.apply(top.nodes, mid.nodes);
    return top;
  }

blockExpression
  = _ dash _ name:ident _ m:mustacheContent? _ TERM b:(INDENT elements DEDENT)?
  {
    var e = { type: 'block_expression', name:name };
    if(m) {
      e.content = m;
    }
    if(b && b.length > 0){
      e.nodes = b[1];
    }
    return e;
  }

mustacheExpression
  = _ equal _ m:mustacheContent _ TERM
  {
    return { type: 'expression', content:m };
  }

dash
  = '-'

equal
  = '='

element
  = t:(tag)? idClass:(id / class)* _ attrs:(
      a:attributes { return { attributes: a }; } / 
      b:attributeBindings { return { attributeBindings: b }; } 
    )* _ TERM 
  {
    var element = {
      type: 'element',
      tag: t || 'div'
    };
    var attributes = idClass;
    var addAtributes = condense(attrs);
    addProperty(element, 'attributes', condense(attributes.concat(addAtributes.attributes)));
    addProperty(element, 'attributeBindings', condense(addAtributes.attributeBindings));
    return element;
  }

attributes
  = '(' a:attributeList ')'
  {
    return a;
  }

attributeBindings
  = '{' a:attributeList '}'
  {
    return a;
  }

attributeList 'Attribute List'
  = a:attribute*
  {
    return condense(a);
  }

attribute
  = _ k:ident '=' v:(ident / quoted) _
  {
    var attr = {};
    attr[k] = v;
    return attr;
  }

blockElement
  = e:element b:(INDENT elements DEDENT)?
  {
    if(b && b.length > 0){
      e.nodes = b[1];
    }
    return e;
  }

id
  = '#' i:ident { return { id: i } }

tag
  = '%' t:ident { return t; }

class
  = '.' c:ident { return { class: c } }

quoted
  = chars:(("'" ident "'") / ('"' ident '"') ) { return chars.join('') }

ident
  = name

name
  = chars:nameChar+ { return chars.join('') }

nameChar
  = [_a-z0-9-]i

INDENT "INDENT" = "\uEFEF" { return ''; }
DEDENT "DEDENT" = "\uEFFE" { return ''; }
TERM  "TERM" = "\uEFFF" { return ''; }

__ "required whitespace"
  = whitespace+

_ "whitespace"
  = whitespace*

whitespace
  = [ \t\n\r]