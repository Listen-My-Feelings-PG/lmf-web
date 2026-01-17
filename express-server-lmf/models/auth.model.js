const { psql } = require("../main");
const { queryExec } = require("../resources/utils");

module.exports.getUser = (username, cb) => {
  queryExec(
    psql``,
    cb
  );
};