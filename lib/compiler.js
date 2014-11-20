var Parser = require('../lib/parser');
var Generator = require('../lib/generator');

module.exports = {
  compile: function(haml){
    var ast = Parser.parse(haml);
    return Generator.generate(ast);
  }
}