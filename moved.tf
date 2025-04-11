moved {
  from = aws_config_configuration_recorder.default
  to   = module.aws_config_recorder.aws_config_configuration_recorder.default
}

moved {
  from = aws_config_delivery_channel.default
  to   = module.aws_config_recorder.aws_config_delivery_channel.default
}

moved {
  from = aws_config_configuration_recorder_status.default
  to   = module.aws_config_recorder.aws_config_configuration_recorder_status.default
}
