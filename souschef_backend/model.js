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

const getRecipe = (recipeid, userid) => {
  let query_str = 'WITH one_recipe AS (SELECT * FROM Recipes WHERE recipeId='+recipeid+')';
  query_str = query_str.concat(recipeListQueries('one_recipe', 'rating_recipe'));
  query_str = query_str.concat(', ', 'stepcount_recipe AS (SELECT * FROM rating_recipe NATURAL JOIN (SELECT recipeId, count(stepNumber) as stepcount FROM Steps GROUP BY (recipeId)) AS A)');
  query_str = query_str.concat(', ', 'bookmarked_recipe AS (SELECT *, (CASE WHEN EXISTS (SELECT * FROM Bookmarks WHERE recipeid='+recipeid+' AND chefid=\''+userid+'\') THEN \'true\' ELSE \'false\' END) AS isbookmarked FROM stepcount_recipe )');
  query_str = query_str.concat(' ', 'SELECT * FROM bookmarked_recipe');
  return new Promise((resolve, reject) => {
    pool.query(query_str, [], (error, results) => {
      if (error)
        reject(error);
      if (results)
        resolve(results.rows);
    })
  })
}

const getRecipeTags = (id) => {
  return new Promise((resolve, reject) => {
    pool.query('SELECT * FROM Tagged NATURAL JOIN Tags WHERE recipeId=$1', [id], (error, results) => {
      if (error)
        reject(error);
      if (results)
        resolve(results.rows);
    })
  })
}

const getRecipeRequirements = (id) => {
  return new Promise((resolve, reject) => {
    pool.query('SELECT * FROM Requirements NATURAL JOIN Ingredients WHERE recipeId=$1', [id], (error, results) => {
      if (error)
        reject(error);
      if (results)
        resolve(results.rows);
    })
  })
}

const getRecipeStep = (id, step) => {
  return new Promise((resolve, reject) => {
    pool.query('SELECT * FROM Steps WHERE recipeId=$1 AND stepNumber=$2', [id, step], (error, results) => {
      if (error)
        reject(error);
      if (results)
        resolve(results.rows);
    })
  })
}

const getRecipes = (query_str) => {
  const QUERYSTR = query_str;
  // console.log(QUERYSTR);
  return new Promise((resolve, reject) => {
    pool.query(QUERYSTR, [], (error, results) => {
      if (error)
        reject(error);
      if (results)
        resolve(results.rows);
    })
  })
}

const recipeListQueries = (in_table, out_table) => {
  query_str = '';
  query_str = query_str.concat(', ', 'rating_recipes AS (SELECT ', in_table, '.recipeId AS recipeid, title, serves, authorid, lastmodified, duration, averagerating, ratingsum, ratingtotal, stddev FROM ', in_table, ' LEFT JOIN (SELECT recipeId, AVG(rating) AS averageRating, SUM(rating) AS ratingSum, COUNT(chefId) AS ratingTotal, STDDEV(rating) FROM Ratings GROUP BY recipeId) AS A ON ', in_table, '.recipeId = A.recipeId)');
  query_str = query_str.concat(', ', out_table, ' AS (SELECT rating_recipes.recipeId AS recipeid, title, serves, authorid, lastmodified, duration, averagerating, ratingsum, ratingtotal, stddev, hotRating, hotTotal FROM rating_recipes LEFT JOIN (SELECT recipeId, avg(rating) AS hotRating, count(chefId) AS hotTotal FROM Ratings WHERE now() - lastModified  < interval \'1 day\' GROUP BY recipeId) AS A ON rating_recipes.recipeId = A.recipeId)');
  return query_str;
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

const createRecipe = (recipeId, title, serves, visibility, authorId, duration) => {
  const LASTMODIFIED = getDateTime();
  return new Promise((resolve, reject) => {
    pool.query('INSERT INTO Recipes (recipeId, title, serves, visibility, authorId, lastModified, duration) VALUES ($1, $2, $3, $4, $5, $6, $7)',
      [recipeId, title, serves, visibility, authorId, LASTMODIFIED, duration], (error, results) => {
        if (error)
          reject(error);
        if (results)
          resolve(results.rows);
      })
  })
}

const updateRecipe = (recipeId, title, serves, visibility, authorId, duration) => {
  const LASTMODIFIED = getDateTime();
  return new Promise((resolve, reject) => {
    pool.query('UPDATE Recipes SET "title" = $2, "serves" = $3, "visibility" = $4, "lastmodified" = $5, "duration" = $6 WHERE "recipeid" = $1',
      [recipeId, title, serves, visibility, LASTMODIFIED, duration], (error, results) => {
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

const createStep = (recipeId, stepNumber, desc) => {
  return new Promise((resolve, reject) => {
    pool.query('INSERT INTO Steps (recipeId, stepNumber, description) VALUES ($1, $2, $3)',
      [recipeId, stepNumber, desc], (error, results) => {
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

const createRequirement = (recipeId, ingredientId, quantity) => {
  return new Promise((resolve, reject) => {
    pool.query('INSERT INTO Requirements (recipeId, ingredientId, quantity) VALUES ($1, $2, $3)',
      [recipeId, ingredientId, quantity], (error, results) => {
        if (error)
          reject(error);
        if (results)
          resolve(results.rows);
      })
  })
}

const deleteRequirements = (recipeId) => {
  return new Promise((resolve, reject) => {
    pool.query('DELETE FROM Requirements WHERE recipeid=$1',
      [recipeId], (error, results) => {
        if (error)
          reject(error);
        if (results)
          resolve(results.rows);
      })
  })
}

const createBookmark = (chefid, recipeId) => {
  const CHEFID = chefid;
  const RECIPEID = recipeId;
  return new Promise((resolve, reject) => {
    pool.query('INSERT INTO Bookmarks (chefid, recipeid) VALUES ($1, $2)',
      [CHEFID, RECIPEID], (error, results) => {
        if (error)
          reject(error);
        if (results)
          resolve(results.rows);
      })
  })
}

const removeBookmark = (chefid, recipeId) => {
  const CHEFID = chefid;
  const RECIPEID = recipeId;
  return new Promise((resolve, reject) => {
    pool.query('DELETE FROM Bookmarks WHERE chefid = $1 AND recipeid = $2',
      [CHEFID, RECIPEID], (error, results) => {
        if (error)
          reject(error);
        if (results)
          resolve(results.rows);
      })
  })
}

const rateRecipe = (chefid, recipeId, rating) => {
  const CHEFID = chefid;
  const RECIPEID = recipeId;
  const RATING = rating;
  const LASTMODIFIED = getDateTime();
  return new Promise((resolve, reject) => {
    pool.query('INSERT INTO Ratings (chefid, recipeid, rating, lastmodified) VALUES ($1, $2, $3, $4) ON CONFLICT (chefid, recipeid) DO UPDATE SET rating = $3, lastmodified = $4',
      [CHEFID, RECIPEID, RATING, LASTMODIFIED], (error, results) => {
        if (error)
          reject(error);
        if (results)
          resolve(results.rows);
      })
  })
}

const unrateRecipe = (chefid, recipeId) => {
  const CHEFID = chefid;
  const RECIPEID = recipeId;
  return new Promise((resolve, reject) => {
    pool.query('DELETE FROM Ratings WHERE chefid = $1 AND recipeid = $2',
      [CHEFID, RECIPEID], (error, results) => {
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
    pool.query('SELECT ingredientid, name, kind, quantity FROM ShoppingList NATURAL JOIN Ingredients WHERE chefId=$1', [ID], (error, results) => {
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

const updateShoppingListIngredient = (chefId, ingredientId, quantity) => {
  const INGREDIENTID = ingredientId;
  const CHEFID = chefId;
  const QUANTITY = quantity;
  return new Promise((resolve, reject) => {
    pool.query('INSERT INTO ShoppingList (chefid, ingredientid, quantity) VALUES ($1, $2, $3) ON CONFLICT(chefid, ingredientid) DO UPDATE SET quantity = (SELECT quantity FROM ShoppingList AS A WHERE A.chefid = $1 AND A.ingredientid = $2 LIMIT 1) + $3;', [CHEFID, INGREDIENTID, QUANTITY], (error, results) => {
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
  })
}

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
    pool.query('INSERT INTO Tags (tagId, name) VALUES ($1, $2)',
      [tagId, name], (error, results) => {
        if (error)
          reject(error);
        if (results)
          resolve(results.rows);
      })
  })
}

const applyTags = (recipeId, tagId) => {
  return new Promise((resolve, reject) => {
    pool.query('INSERT INTO Tagged (recipeId, tagId) VALUES ($1, $2)',
      [recipeId, tagId], (error, results) => {
        if (error)
          reject(error);
        if (results)
          resolve(results.rows);
      })
  })
}

const deleteTags = (recipeId) => {
  return new Promise((resolve, reject) => { 
    pool.query('DELETE FROM Tagged WHERE recipeId = $1', [recipeId], (error, results) => {
      if (error)
        reject(error);
      if (results)
        resolve(results.rows);
    })
  })
}


const getRequirementsByRecipe = (recipeId) => {
  return new Promise((resolve, reject) => {
    pool.query('SELECT SUM(quantity), ingredientid FROM requirements WHERE recipeid = $1 GROUP BY ingredientid;',
      [recipeId], (error, results) => {
        if (error)
          reject(error);
        if (results)
          resolve(results.rows);
      })
  })
}

const getIngredientByKey = (key, lim) => {
  const searchKey = key + '%';
  return new Promise((resolve, reject) => {
    pool.query('SELECT * FROM Ingredients WHERE name like $1 limit $2',
      [searchKey, lim], (error, results) => {
        if (error)
          reject(error);
        if (results)
          resolve(results.rows);
      })
  })
}

const getTagByKey = (key, lim) => {
  const searchKey = key + '%';
  return new Promise((resolve, reject) => {
    pool.query('SELECT * FROM Tags WHERE name like $1 order by (name) limit $2',
      [searchKey, lim], (error, results) => {
        if (error)
          reject(error);
        if (results)
          resolve(results.rows);
      })
  })
}

const getChefByKey = (key, lim) => {
  const searchKey = key + '%';
  return new Promise((resolve, reject) => {
    pool.query('SELECT * FROM Chefs WHERE chefId like $1 OR name like $1 limit $2',
      [searchKey, lim], (error, results) => {
        if (error)
          reject(error);
        if (results)
          resolve(results.rows);
      })
  })
}

const getRecipeByKey = (key, lim) => {
  const searchKey = key + '%';
  return new Promise((resolve, reject) => {
    pool.query('SELECT DISTINCT title FROM Recipes WHERE title like $1 limit $2',
      [searchKey, lim], (error, results) => {
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
  getRecipes,
  getRecipeId,
  createRecipe,
  updateRecipe,
  deleteRecipe,
  createStep,
  deleteSteps,
  createRequirement,
  deleteRequirements,
  getDateTime,
  getShoppingList,
  createBookmark,
  removeBookmark,
  rateRecipe,
  unrateRecipe,
  createShoppingListIngredient,
  updateShoppingListIngredient,
  deleteShoppingListIngredient,
  getIngredientId,
  createIngredient,
  getTagId,
  createTag,
  applyTags,
  deleteTags,
  getRequirementsByRecipe,
  getIngredientByKey,
  getTagByKey,
  getChefByKey,
  recipeListQueries,
  getRecipeTags,
  getRecipeRequirements,
  getRecipeStep,
  getRecipeByKey
}