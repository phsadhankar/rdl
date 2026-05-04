if defined? BigDecimal
  QDL.type_alias '%real', 'Integer or Float or Rational or BigDecimal'
  QDL.type_alias '%numeric', 'Integer or Float or Rational or BigDecimal or Complex'
else
  QDL.type_alias '%real', 'Integer or Float or Rational'
  QDL.type_alias '%numeric', 'Integer or Float or Rational'
end
QDL.type_alias '%string', '[to_str: () -> String]'
if defined? Pathname
  QDL.type_alias '%path', '%string or Pathname'
else
  QDL.type_alias '%path', '%string'
end
QDL.type_alias '%open_args', '{external_encoding: ?(String or Encoding), internal_encoding: ?(String or Encoding), encoding: ?(String or Encoding), textmode: ?%any, binmode: ?%any, autoclose: ?%any, mode: ?String}'
