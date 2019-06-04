
var Action = function() {}

Action.prototype = {
  
  // Used to pass parameters / info to the extension code (ActionViewController:viewDidLoad() method)
  run: function(parameters) {
    parameters.completionFunction({"URL": document.URL, "title": document.title});
  },
  
  // Callback, called when the extension is finished execution
  finalize: function(parameters) {
    var customJavascript = parameters["customJavascript"];
    eval(customJavascript);
  }
  
};

var ExtensionPreprocessingJS = new Action
