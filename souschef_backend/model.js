const Pool = require('pg').Pool
require('dotenv').config();
const pool = new Pool({
  user: process.env.user,
  host: process.env.host,
  database: process.env.database,
  password: process.env.password,
  port: process.env.port
});

const getChef = (id) => {
  const ID = parseInt(id);
  return new Promise((resolve, reject) => {
    pool.query('SELECT * FROM Chefs WHERE chefId=$1', [ID], (error, results) => {
      if (error) {
        reject(error);
      }
      resolve(results.rows);
    })
  })
}

module.exports = {
  getChef
}