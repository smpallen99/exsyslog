# Exsyslog

ExSysylog is an Elixir port of the erlang [Twig](https://github.com/cloudant/twig) logger.

ExSyslog is an Elixir/OTP logger. It installs a gen_event handler in the error_logger event manager,
where it consumes standards OTP reports and messages as well as events generated by the ExSyslog.Logger.log. 
Log messages are written to a syslog server over UDP using the format specified in RFC 5424.

## Configuration

ExSyslog's behavior is controlled using the application configuration environment:

* __host__ (undefined): the hostname of the syslog server
* __port__ (514): the port of the syslog server
* __facility__ (local2): syslog facility to be used
* __level__ (info): logging threshold. Messages "above" this threshold (in syslog parlance) will be discarded. Acceptable values are debug, info, notice, warn, err, crit, alert, and emerg.
* __appid__ ("exsyslog"): inserted as the APPID in the syslog message
* __max_term_size__ (8192): raw data size below which we format normally
* __max_message_size__ (16000): approx. max size of truncated string

## License

exrm_rpm is copyright (c) 2014 E-MetroTel. 

The source code is released under the MIT License.

Check [LICENSE](LICENSE) for more information.
