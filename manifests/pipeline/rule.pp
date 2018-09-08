define graylog::pipeline::rule(
  String $description = '',
  String $condition   = 'true',
  String $action      = '',
) {
  $rule_body = @("END_OF_RULE")
    rule "${title}"
    when
    ${condition}
    then
    ${action}
    end
    |- END_OF_RULE

  graylog_pipeline_rule { $title:
    description => $description,
    source      => $rule_body,
  }
}