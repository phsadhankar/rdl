QDL.nowrap :'ActionController::Instrumentation'
QDL.type :'ActionController::Instrumentation', :render, '(String or Symbol) -> Array<String>'
QDL.type :'ActionController::Instrumentation', :render, '(?String or Symbol, {content_type: ?String, json: ?String, layout: ?%bool or String, action: ?String or Symbol, location: ?String, nothing: ?%bool, file: ?String, text: ?[to_s: () -> String], status: ?Symbol, content_type: ?String, formats: ?Symbol or Array<Symbol>, locals: ?Hash<Symbol, x>}) -> Array<String>'
QDL.type :'ActionController::Instrumentation', :redirect_to, '(?(String or Symbol or ActiveRecord::Base), {controller: ?String, action: ?String, notice: ?String, alert: ?String}) -> String'

#QDL.type :'ActionController::Instrumentation', :redirect_to, '({controller: ?String, action: String, notice: ?String, alert: ?String}) -> String' ## When no first argument is provided, `action` must be present in options.
#QDL.type :'ActionController::Instrumentation', :redirect_to, '(String or Symbol or ActiveRecord::Base, ?{controller: ?String, action: ?String, notice: ?String, alert: ?String}) -> String'
