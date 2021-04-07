const moment = require("moment");

module.exports = {
  formatDate: (date, format) => moment(date).format(format)
};
