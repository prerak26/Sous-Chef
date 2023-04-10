const Pool = require('pg').Pool
require('dotenv').config();
const pool = new Pool({
  user: process.env.user,
  host: process.env.host,
  database: process.env.database,
  password: process.env.password,
  port: process.env.port
});

const beginQuery = () => {
  return new Promise((resolve, reject) => {
    pool.query('begin', (error, results) => {
        if (error)
          reject(error);
        if (results)
          resolve(results);
      })
  })
}

const rollbackQuery = () => {
  return new Promise((resolve, reject) => {
    pool.query('rollback', (error, results) => {
        if (error)
          reject(error);
        if (results)
          resolve(results);
      })
  })
}

const commitQuery = () => {
  return new Promise((resolve, reject) => {
    pool.query('commit', (error, results) => {
        if (error)
          reject(error);
        if (results)
          resolve(results);
      })
  })
}

const getChef = (id) => {
  return new Promise((resolve, reject) => {
    pool.query('SELECT * FROM Chefs WHERE chefId=$1', [id], (error, results) => {
      if (error)
        reject(error);
      if (results)
        resolve(results.rows);
    })
  })
}

const createChef = (id, name, pswd) => {
  return new Promise((resolve, reject) => {
    pool.query('INSERT INTO Chefs (chefId, name, hashedPassword) VALUES ($1, $2, $3)', [id, name, pswd], (error, results) => {
      if (error)
        reject(error);
      if (results)
        resolve(results.rows);
    })
  })
}

const getRecipe = (id) => {
  return new Promise((resolve, reject) => {
    pool.query('SELECT * FROM Recipes where recipeId=$1', [id], (error, results) => {
      if (error)
        reject(error);
      if (results)
        resolve(results.rows);
    })
  })
}

const getRecipeId = () => {
  return new Promise((resolve, reject) => {
    // pool.query('SELECT count(*) FROM Recipes', (error, results) => {
    pool.query('WITH totalRecipeCount AS (SELECT COUNT(*) FROM recipes) SELECT * FROM (SELECT num FROM generate_series(0, (select totalRecipeCount.count from totalrecipecount)) num EXCEPT select recipeid from recipes) AS A ORDER BY A.num LIMIT 1;', (error, results) => {
      if (error)
        reject(error);
      if (results)
        resolve(parseInt(results.rows[0].num));
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

const updateRecipe = (recipeId, title, serves, visibility, authorId) => {
  const LASTMODIFIED = getDateTime();
  return new Promise((resolve, reject) => {
    pool.query('UPDATE Recipes SET "title" = $2, "serves" = $3, "visibility" = $4, "lastmodified" = $5 WHERE "recipeid" = $1',
      [recipeId, title, serves, visibility, LASTMODIFIED], (error, results) => {
        if (error)
          reject(error);
        if (results)
          resolve(results.rows);
      })
  })
}


const deleteRecipe = (recipeId) => {
  return new Promise((resolve, reject) => {
    pool.query('DELETE FROM Recipes WHERE "recipeid"=$1', [recipeId], (error, results) => {
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

const deleteSteps = (recipeId) => {
  return new Promise((resolve, reject) => {
    pool.query('DELETE FROM Steps WHERE recipeid=$1',
      [recipeId], (error, results) => {
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

const getShoppingList = (id) => {
  const ID = id;
  return new Promise((resolve, reject) => {
    pool.query('SELECT * FROM ShoppingList WHERE chefId=$1', [ID], (error, results) => {
      if (error)
        reject(error);
      if (results)
        resolve(results.rows);
    })
  })
}

const createShoppingListIngredient = (ingredientId, chefId, quantity) => {
  const INGREDIENTID = ingredientId;
  const CHEFID = chefId;
  const QUANTITY = quantity;
  return new Promise((resolve, reject) => {
    pool.query('INSERT INTO ShoppingList (chefid, ingredientid, quantity) VALUES ($1, $2, $3)', [CHEFID, INGREDIENTID, QUANTITY], (error, results) => {
      if (error)
        reject(error);
      if (results)
        resolve(results.rows);
    })
  })
}

const deleteShoppingListIngredient = (ingredientId, chefId) => {
  const INGREDIENTID = ingredientId;
  const CHEFID = chefId;
  return new Promise((resolve, reject) => {
    pool.query('DELETE FROM ShoppingList WHERE ingredientid=$1 AND chefid=$2', [INGREDIENTID, CHEFID], (error, results) => {
      if (error)
        reject(error);
      if (results)
        resolve(results.rows);
    })
const getIngredientId = () => {
  return new Promise((resolve, reject) => {
    pool.query('SELECT count(*) FROM Ingredients', (error, results) => {
        if (error)
          reject(error);
        if (results)
          resolve(parseInt(results.rows[0].count));
      })
  })
}

const createIngredient = (ingredientId, name, kind) => {
  return new Promise((resolve, reject) => {
    pool.query('INSERT INTO Ingredients (ingredientId, name, kind) VALUES ($1, $2, $3)',
      [ingredientId, name, kind], (error, results) => {
        if (error)
          reject(error);
        if (results)
          resolve(results.rows);
      })
  })
}

const getTagId = () => {
  return new Promise((resolve, reject) => {
    pool.query('SELECT count(*) FROM Tags', (error, results) => {
        if (error)
          reject(error);
        if (results)
          resolve(parseInt(results.rows[0].count));
      })
  })
}

const createTag = (tagId, name) => {
  return new Promise((resolve, reject) => {
    pool.query('INSERT INTO Tags (ingredientId, name) VALUES ($1, $2)',
      [tagId, name], (error, results) => {
        if (error)
          reject(error);
        if (results)
          resolve(results.rows);
      })
  })
}

module.exports = {
  beginQuery,
  rollbackQuery,
  commitQuery,
  getChef,
  createChef,
  getRecipe,
  getRecipeId,
  createRecipe,
  updateRecipe,
  deleteRecipe,
  createStep,
  deleteSteps,
  createRequirement,
  getDateTime,
<<<<<<< HEAD
  getShoppingList,
  createShoppingListIngredient,
  deleteShoppingListIngredient
=======
  getIngredientId,
  createIngredient,
  getTagId,
  createTag
>>>>>>> 5542bfe (Tags and ingredients creation added)
}