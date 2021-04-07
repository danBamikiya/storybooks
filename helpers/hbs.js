const moment = require("moment");

module.exports = {
  formatDate: (date, format) => moment(date).format(format),
  truncate: (str, len) => {
    if (str.length > len && str.length > 0) {
      let new_str = str + " ";
      new_str = str.substr(0, len);
      new_str = str.substr(0, new_str.lastIndexOf(""));
      new_str = new_str.length > 0 ? new_str : str.substr(0, len);
    }
    return str;
  }
};
