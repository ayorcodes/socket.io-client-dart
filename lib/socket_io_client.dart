///
/// custom_socket.dart
///
/// Purpose:
///
/// Description:
///
/// History:
///   26/04/2017, Created by jumperchen
///
/// Copyright (C) 2017 Potix Corporation. All Rights Reserved.
///

library custom_socket;

import 'package:logging/logging.dart';
import 'package:custom_socket/src/socket.dart';
import 'package:socket_io_common/src/engine/parser/parser.dart' as parser;
import 'package:custom_socket/src/engine/parseqs.dart';
import 'package:custom_socket/src/manager.dart';

export 'package:custom_socket/src/socket.dart';

// Protocol version
final protocol = parser.protocol;

final Map<String, dynamic> cache = {};

final Logger _logger = Logger('custom_socket');

///
/// Looks up an existing `Manager` for multiplexing.
/// If the user summons:
///
///   `io('http://localhost/a');`
///   `io('http://localhost/b');`
///
/// We reuse the existing instance based on same scheme/port/host,
/// and we initialize sockets for each namespace.
///
/// @api public
///
Socket io(uri, uuid, [opts]) => _lookup(uri, uuid, opts);

Socket _lookup(uri, uuid, opts) {
  opts = opts ?? <dynamic, dynamic>{};

  var parsed = Uri.parse(uri);
  var id = '${parsed.scheme}://${parsed.host}:${parsed.port}';
  var path = parsed.path;
  var sameNamespace = cache.containsKey(id) && cache[id].nsps.containsKey(path);
  var newConnection = opts['forceNew'] == true ||
      opts['force new connection'] == true ||
      false == opts['multiplex'] ||
      sameNamespace;

  var io;

  if (newConnection) {
    _logger.fine('ignoring socket cache for $uri');
    io = Manager(uri: uri, options: opts, uuid: uuid);
  } else {
    io = cache[id] ??= Manager(uri: uri, options: opts, uuid: uuid);
  }
  if (parsed.query.isNotEmpty && opts['query'] == null) {
    opts['query'] = parsed.query;
  } else if (opts != null && opts['query'] is Map) {
    opts['query'] = encode(opts['query']);
  }
  return io.socket(parsed.path.isEmpty ? '/' : parsed.path, opts);
}
