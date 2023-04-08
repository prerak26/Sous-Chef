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
  const ID = id;
  return new Promise((resolve, reject) => {
    pool.query('SELECT * FROM Chefs WHERE chefId=$1', [ID], (error, results) => {
      if (error)
        reject(error);
      if (results)
        resolve(results.rows);
    })
  })
}

const createChef = (id, name, pswd) => {
  const ID = id;
  const NAME = name;
  const PSWD = pswd;
  return new Promise((resolve, reject) => {
    pool.query('INSERT INTO Chefs (chefId, name, hashedPassword) VALUES ($1, $2, $3)', [ID, NAME, PSWD], (error, results) => {
      if (error)
        reject(error);
      if (results)
        resolve(results.rows);
    })
  })
}

const getRecipe = (id) => {
  const ID = id;
  return new Promise((resolve, reject) => {
    pool.query('SELECT * FROM Recipes where recipeId=$1', [ID], (error, results) => {
      if (error)
        reject(error);
      if (results)
        resolve(results.rows);
    })
  })
}

const getRecipeId = () => {
  return new Promise((resolve, reject) => {
    pool.query('SELECT count(*) FROM Recipes', (error, results) => {
      if (error)
        reject(error);
      if (results)
        resolve(parseInt(results.rows[0].count));
    })
  })
}

const getDateTime = () => {
  const now = new Date();
  return now.getFullYear() + "-" + now.getMonth() + "-" + now.getDate() + " " +
    now.getHours() + ":" + now.getMinutes() + ":" + now.getSeconds() + "." +
    now.getMilliseconds();
}

const createRecipe = (recipeId, title, serves, visibility, authorId) => {
  const LASTMODIFIED = getDateTime();
  return new Promise((resolve, reject) => {
    pool.query('INSERT INTO Recipes (recipeId, title, serves, visibility, authorId, lastModified) VALUES ($1, $2, $3, $4, $5, $6)',
      [recipeId, title, serves, visibility, authorId, LASTMODIFIED], (error, results) => {
        if (error)
          reject(error);
        if (results)
          resolve(results.rows);
      })
  })
}

const createStep = (recipeId, stepNumber, desc, duration) => {
  return new Promise((resolve, reject) => {
    pool.query('INSERT INTO Steps (recipeId, stepNumber, description, duration) VALUES ($1, $2, $3, $4)',
      [recipeId, stepNumber, desc, duration], (error, results) => {
        if (error)
          reject(error);
        if (results)
          resolve(results.rows);
      })
  })
}

const createRequirement = (recipeId, stepNumber, serialNumber, ingredientId, quantity) => {
  return new Promise((resolve, reject) => {
    pool.query('INSERT INTO Requirements (recipeId, stepNumber, serialNumber, ingredientId, quantity) VALUES ($1, $2, $3, $4, $5)',
      [recipeId, stepNumber, serialNumber, ingredientId, quantity], (error, results) => {
        if (error)
          reject(error);
        if (results)
          resolve(results.rows);
      })
  })
}

module.exports = {
  getChef,
  createChef,
  getRecipe,
  getRecipeId,
  createRecipe,
  createStep,
  createRequirement
}