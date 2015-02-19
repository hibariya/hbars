import Compiler from '../compiler';

describe('compiler', function () {

  it('tags with classes and ids', function () {
    var template = Compiler.compile('%p#paragraph.foo.bar\n%a#link.baz.qux');
    expect(template).to.equal('<p id="paragraph" class="foo bar"></p>\n<a id="link" class="baz qux"></a>');
  });

  it('nested tags', function () {
    var template = Compiler.compile('%p\n  %a');
    expect(template).to.equal('<p>\n  <a></a>\n</p>');
  });

  it('nested block expression', function () {
    var template = Compiler.compile('%p\n\t- each things\n\t\t%p');
    expect(template).to.equal('<p>\n  {{#each things}}\n    <p></p>\n  {{/each}}\n</p>');
  });

  it('nested expression', function () {
    var template = Compiler.compile('%p\n\t= name');
    expect(template).to.equal('<p>\n  {{name}}\n</p>');
  });

  it('if/else', function () {
    var template = Compiler.compile('-if foo\n  %p\n-else\n  %a');
    expect(template).to.equal('{{#if foo}}\n  <p></p>\n{{else}}\n  <a></a>\n{{/if}}');
  });

  it('unless', function () {
    var template = Compiler.compile('-unless foo\n  %p\n');
    expect(template).to.equal('{{#unless foo}}\n  <p></p>\n{{/unless}}');
  });

  it('handles single and double quoted attributes', function () {
    var template = Compiler.compile('%p( name=\'foo\' style="bar" )');
    expect(template).to.equal('<p name="foo" style="bar"></p>');
  });

  it('bind-attr', function () {
    var template = Compiler.compile('%p{ name=foo style="bar" }');
    expect(template).to.equal('<p {{bind-attr name=foo style="bar"}}></p>');
  });

  it('bind-attr special chars', function () {
    var template = Compiler.compile('%p{ class="bar:bar:foo" }');
    expect(template).to.equal('<p {{bind-attr class="bar:bar:foo"}}></p>');
  });

  it('attribute helper', function () {
    var template = Compiler.compile('%button{ name=name style="bar" }{action "submit"}Submit');
    expect(template).to.equal('<button {{bind-attr name=name style="bar"}} {{action "submit"}}>Submit</button>');
  });

  it('attribute helper nested content', function () {
    var template = Compiler.compile('%button{action "submit"}\n Submit');
    expect(template).to.equal('<button {{action "submit"}}>\n  Submit\n</button>');
  });

  describe('plain text', function(){

    it('nested', function() {
      var template = Compiler.compile("%p\n  some plain text 1234567890 !@#$*()_+-=");
      expect(template).to.equal('<p>\n  some plain text 1234567890 !@#$*()_+-=\n</p>');
    });

    it('inline', function() {
      var template = Compiler.compile("%p some plain text 1234567890 !@#$*()_+-=");
      expect(template).to.equal('<p>some plain text 1234567890 !@#$*()_+-=</p>');
    });

  });

  describe('interpolation', function() {

    it('inline beginning', function() {
      var template = Compiler.compile("%p #{foo} bar #{baz}");
      expect(template).to.equal('<p>{{foo}} bar {{baz}}</p>');
    });

    it('inline with spaces', function() {
      var template = Compiler.compile("%p #{if foo bar} bar");
      expect(template).to.equal('<p>{{if foo bar}} bar</p>');
    });

    it('special characters', function() {
      var template = Compiler.compile("%p #{12 !@#$%^&*()_+=-\"': /><,.|\\} bar");
      expect(template).to.equal("<p>{{12 !@#$%^&*()_+=-\"': /><,.|\\}} bar</p>");
    });

  });

  describe('newlines', function() {
    it('between nested plain elements', function() {
      var template = Compiler.compile(".foo\n %p\n %p\n%p");
      expect(template).to.equal('<div class="foo">\n  <p></p>\n  <p></p>\n</div>\n<p></p>');
    });
  });

  describe('blank lines', function() {

    it('between inline plain elements', function() {
      var template = Compiler.compile("%p\n\n%p");
      expect(template).to.equal('<p></p>\n<p></p>');
    });

    it('between nested plain elements', function() {
      var template = Compiler.compile(".foo\n %p\n\n%p");
      expect(template).to.equal('<div class="foo">\n  <p></p>\n</div>\n<p></p>');
    });

  });

});
