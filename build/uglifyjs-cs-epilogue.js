require('./process').ast_squeeze_more = require('./squeeze-more').ast_squeeze_more;

function uglify(orig_code, options){
  options || (options = {});
  var jsp = require('./parse-js');
  var pro = require('./process');

  var ast = jsp.parse(orig_code, options.strict_semicolons); // parse code and get the initial AST
  ast = pro.ast_mangle(ast, options.mangle_options); // get a new AST with mangled names
  ast = pro.ast_squeeze(ast, options.squeeze_options); // get an AST with compression optimizations
  var final_code = pro.gen_code(ast, options.gen_options); // compressed code here
  return final_code;
};

window.uglify = uglify;

})();