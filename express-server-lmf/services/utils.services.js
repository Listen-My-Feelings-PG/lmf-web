module.exports.logger = (level, msg, data) => {
  setImmediate(() => {
    process.nextTick(() => {
      switch (level) {
        case 'info':
          console.info(msg, data || '');
          break;
        case 'error':
          console.error(msg, data || '');
          break;
        case 'warn':
          console.warn(msg, data || '');
          break;
        default:
          console.info(msg, data || '');
      }
    });
  });
}

module.exports.queryExec = (psql, cb, timeout = DB_QUERY_TIMEOUT) => {
  const timeoutPromise = new Promise((_, reject) => {
    setTimeout(() => reject(new Error(`Query timeout after ${timeout}ms`)), timeout);
  });

  Promise.race([psql, timeoutPromise]).then(data => cb(data)).catch(error => {
    if (error.message.includes('timeout'))
      logger('error', 'Query timeout - posible bloqueo de base de datos', {
        timeout,
        error: error.message
      });
    else
      logger('error', 'Error al obtener respuesta de psql', error);
    return cb(500);
  });
}