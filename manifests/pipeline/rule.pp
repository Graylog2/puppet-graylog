define graylog::pipeline::rule(
  String $description = '',
  String $condition   = 'true', # lint:ignore:quoted_booleans This is a Graylog string, not a Puppet boolean.
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
