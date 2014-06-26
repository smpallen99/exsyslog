# This file is responsible for configuring your application and
# its dependencies. It must return a keyword list containing the
# application name and have as value another keyword list with
# the application key-value pairs.

# Note this configuration is loaded before any dependency and is
# restricted to this project. If another project depends on this
# project, this file won't be loaded nor affect the parent project.

# You can customize the configuration path by setting :config_path
# in your mix.exs file. For example, you can emulate configuration
# per environment by setting:
#
#     config_path: "config/#{Mix.env}.exs"
#
# Changing any file inside the config directory causes the whole
# project to be recompiled.

# Sample configuration:
#
# [dep1: [key: :value],
#  dep2: [key: :value]]


# [exsyslog: [
#   level: :info, 
#   host: '127.0.0.1', 
#   facility: :local2,
#   appid: "exsyslog",
#   max_term_size: 8192,
#   max_message_size: 16000
# ]]
[exsyslog: [level: :info, host: '127.0.0.1', facility: :local1]]
