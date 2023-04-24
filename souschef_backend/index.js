require('dotenv').config();
const express = require('express');
const sessions = require('express-session');
const bcrypt = require('bcrypt');
const saltRounds = 10;
const app = express();
const port = 3001;

const model = require('./model');
const { response } = require('express');

app.use(express.json());
app.use(function (req, res, next) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET,POST,PUT,DELETE,OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Access-Control-Allow-Headers');
  res.setHeader('Access-Control-Allow-Credentials', 'true');
  next();
});

const onehr = 1000 * 60 * 60;
app.use(sessions({
  secret: process.env.secret,
  saveUninitialized: true,
  cookie: { maxAge: onehr },
  resave: false
}));
app.use(express.urlencoded({ extended: true }));
app.use(express.static(__dirname));

var session;

// Backend index page [auth]
app.get('/', (req, res) => {
  session = req.session;
  if (session.userid) {
    res.send("Welcome User <a href=\'/logout'>click to logout</a>");
    console.log(model.getDateTime(), 'GET: /', 200);
  } else {
    res.sendFile('views/login.html', { root: __dirname });
    console.log(model.getDateTime(), 'GET: /', 401);
  }
});

// Login user [Login View]
app.post('/login', (req, res) => {
  model.getChef(req.body.id)
    .then(response => {
      if ((response.length !== 0 && bcrypt.compareSync(req.body.pswd, response[0].hashedpassword))
        || (req.body.id === process.env.user && req.body.pswd === process.env.password)) {
        session = req.session;
        session.userid = req.body.id;
        res.status(200).send({ message: "Logged in successfully" });
        console.log(model.getDateTime(), 'POST: /login', 200);
      }
      else {
        res.status(404).send({ message: "Invalid username or password" });
        console.log(model.getDateTime(), 'POST: /login', 404);
      }
    })
    .catch(error => {
      res.status(500).send(error);
      console.log(model.getDateTime(), 'POST: /login', 500);
    });
});

// Create user [Signup View]
app.post('/signup', (req, res) => {
  model.getChef(req.body.id)
    .then(chefList => {
      if (chefList.length !== 0) {
        res.status(403).send({ message: "Username already exists" });
        console.log(model.getDateTime(), 'POST: /signup', 403);
      } else {
        model.createChef(req.body.id, req.body.name, bcrypt.hashSync(req.body.pswd, saltRounds))
          .then(response => {
            session = req.session;
            session.userid = req.body.id;
            res.status(200).send(req.body.id);
            console.log(model.getDateTime(), 'POST: /signup', 200);
          })
          .catch(error => {
            res.status(500).send(error);
            console.log(model.getDateTime(), 'POST: /signup', 500);
          });
      }
    })
    .catch(error => {
      res.status(500).send(error);
      console.log(model.getDateTime(), 'POST: /signup', 500);
    });
});

// Check authorisation [auth]
app.get('/auth', (req, res) => {
  session = req.session;
  if (session.userid) {
    res.status(200).send({ chefid: session.userid });
    console.log(model.getDateTime(), 'GET: /auth', 200);
  } else {
    res.status(401).send({ message: "Please login first" });
    console.log(model.getDateTime(), 'GET: /auth', 401);
  }
});

// Logout user [auth] [Logout button]
app.get('/logout', (req, res) => {
  session = req.session;
  if (session) {
    req.session.destroy();
    res.redirect('/');
    console.log(model.getDateTime(), 'GET: /logout', 200);
  } else {
    res.status(401).send({ message: "Please login first" });
    console.log(model.getDateTime(), 'GET: /logout', 401);
  }
});

// Get chef by id [Chef View]
app.get('/chef/:id', (req, res) => {
  let filteredResponse = null;
  let errorCaught = null;
  model.getChef(req.params.id)
    .then(async response => {
      if ((response.length !== 0)) {
        filteredResponse = {
          chefId: response[0].chefid,
          name: response[0].name,
          bookmarks: null,
          recipes: null
        };
        let bookmark_query = 'WITH all_recipes AS (SELECT recipeid, title, serves, authorid, lastmodified, duration FROM Recipes WHERE visibility = \'public\')';
        bookmark_query = bookmark_query.concat(', ', 'bookmarked_recipes AS (SELECT all_recipes.recipeId, title, serves, authorid, lastmodified, duration FROM all_recipes JOIN (SELECT recipeId from Bookmarks WHERE chefId = \'', filteredResponse.chefId, '\') AS A ON all_recipes.recipeId = A.recipeId)');
        bookmark_query = bookmark_query.concat(model.recipeListQueries('bookmarked_recipes', 'filtered_recipes'));
        bookmark_query = bookmark_query.concat(', ', 'sorted_recipes AS (SELECT * FROM filtered_recipes ORDER BY lastmodified DESC)');
        bookmark_query = bookmark_query.concat(' ', 'SELECT * FROM sorted_recipes');
        await model.getRecipes(bookmark_query)
          .then(response => {
            filteredResponse.bookmarks = response;
          })
          .catch(error => {
            errorCaught = error;
          });

        let recipes_query = 'WITH all_recipes AS (SELECT recipeid, title, serves, authorid, lastmodified, duration FROM Recipes WHERE authorId = \'' + filteredResponse.chefId + '\')';
        recipes_query = recipes_query.concat(model.recipeListQueries('all_recipes', 'filtered_recipes'));
        recipes_query = recipes_query.concat(', ', 'sorted_recipes AS (SELECT * FROM filtered_recipes ORDER BY lastmodified DESC)');
        recipes_query = recipes_query.concat(' ', 'SELECT * FROM sorted_recipes');
        await model.getRecipes(recipes_query)
          .then(response => {
            filteredResponse.recipes = response;
          })
          .catch(error => {
            errorCaught = error;
          });
      }
    })
    .catch(error => {
      errorCaught = error;
    })
    .finally(() => {
      if (errorCaught !== null) {
        res.status(500).send(errorCaught);
        console.log(model.getDateTime(), 'GET: /chef/:id', 500);
      } else if (filteredResponse !== null) {
        res.status(200).send(filteredResponse);
        console.log(model.getDateTime(), 'GET: /chef/:id', 200);
      } else {
        res.status(404).send({ message: "Chef not found" });
        console.log(model.getDateTime(), 'GET: /chef/:id', 404);
      }
    });
});

// Get Chefs list by query [Query chefs view]
app.get('/chef', (req, res) => {
  if (req.query.key === undefined)
    req.query.key = "";
  if (req.query.lim === undefined)
    req.query.lim = '10';
  if (parseInt(req.query.lim).toString() !== 'NaN') {
    model.getChefByKey(req.query.key, parseInt(req.query.lim))
      .then(response => {
        res.status(200).send(response);
        console.log(model.getDateTime(), 'GET: /chef', 200);
      })
      .catch(error => {
        res.status(500).send(error);
        console.log(model.getDateTime(), 'GET: /chef', 500);
      });
  } else {
    res.status(400).send({ message: "Limit is NaN" });
    console.log(model.getDateTime(), 'GET: /chef', 400);
  }
});

// Create recipe [auth] [Add recipe view]
app.post('/recipe', (req, res) => {
  session = req.session;
  let errorCaught = null;
  let recipeId = null;
  if (session.userid)
    model.getRecipeId()
      .then(async response => {
        recipeId = response;
        await model.createRecipe(recipeId, req.body.title, parseInt(req.body.serves),
          (req.body.isPublic ? 'public' : 'private'), session.userid, parseInt(req.body.duration))
          .then(async response => {
            await Promise.all([
              await Promise.all(req.body.steps.map((step, i) =>
                model.createStep(recipeId, i + 1, step.desc)
                  .catch(error => {
                    errorCaught = error;
                  }))),
              await Promise.all(req.body.ingredients.map((ingredient, j) =>
                model.createRequirement(recipeId, ingredient.id, ingredient.quantity)
                  .catch(error => {
                    errorCaught = error;
                  })))
            ]);
          })
          .catch(error => {
            errorCaught = error;
          });
      })
      .catch(error => {
        errorCaught = error;
      })
      .finally(() => {
        if (errorCaught !== null) {
          res.status(500).send(errorCaught);
          console.log(model.getDateTime(), 'POST: /recipe', 500);
        } else {
          res.status(200).send({ message: "New recipe added" });
          console.log(model.getDateTime(), 'POST: /recipe', 200);
        }
      });
  else {
    res.status(401).send({ message: "Login first" });
    console.log(model.getDateTime(), 'POST: /recipe', 401);
  }
});

// Get recipe by id [Recipe View]
app.get('/recipe/:id', (req, res) => {
  session = req.session;
  let reqRecipe = null;
  model.getRecipe(parseInt(req.params.id))
    .then(response => {
      if ((response.length !== 0)) {
        reqRecipe = response[0];
        if (reqRecipe.visibility === 'private' && session.userid !== reqRecipe.authorid) {
          res.status(403).send({ message: "Unauthorized access" });
          console.log(model.getDateTime(), 'GET: /recipe/:id', 403);
        } else {
          res.status(200).send(reqRecipe);
          console.log(model.getDateTime(), 'GET: /recipe/:id', 200);
        }
      } else {
        res.status(404).send({ message: "Recipe not found" });
        console.log(model.getDateTime(), 'GET: /recipe/:id', 404);
      }
    })
    .catch(error => {
      res.status(500).send(error);
      console.log(model.getDateTime(), 'GET: /recipe/:id', 500);
    });
});

// Update recipe by id [auth] [Edit recipe View]
app.post('/recipe/:id', (req, res) => {
  session = req.session;
  let errorCaught = null;
  let reqRecipe = null;
  if (session.userid)
    model.getRecipe(parseInt(req.params.id))
      .then(async response => {
        if ((response.length !== 0)) {
          reqRecipe = response[0];
          if (reqRecipe.authorid !== session.userid) {
            res.status(403).send({ message: "Unauthorized access" });
            console.log(model.getDateTime(), 'POST: /recipe/:id', 403);
          } else {
            await model.updateRecipe(parseInt(reqRecipe.recipeid), req.body.title, parseInt(req.body.serves),
              (req.body.isPublic ? 'public' : 'private'), session.userid, parseInt(req.body.duration))
              .then(async response => {
                await model.deleteSteps(parseInt(reqRecipe.recipeid))
                  .then(async response => {
                    await model.deleteRequirements(parseInt(reqRecipe.recipeid))
                      .then(async response => {
                        await Promise.all([
                          await Promise.all(req.body.steps.map((step, i) =>
                            model.createStep(parseInt(reqRecipe.recipeid), i + 1, step.desc)
                              .catch(error => {
                                errorCaught = error;
                              }))),
                          await Promise.all(req.body.ingredients.map((ingredient, j) =>
                            model.createRequirement(parseInt(reqRecipe.recipeid), ingredient.id, ingredient.quantity)
                              .catch(error => {
                                errorCaught = error;
                              })))
                        ]);
                      })
                      .catch(error => {
                        errorCaught = error;
                      })
                  })
                  .catch(error => {
                    errorCaught = error;
                  }
                  );
              })
              .catch(error => {
                errorCaught = error;
              });
          }
        }
      })
      .catch(error => {
        errorCaught = error;
      })
      .finally(() => {
        if (errorCaught !== null) {
          res.status(500).send(errorCaught);
          console.log(model.getDateTime(), 'POST: /recipe/:id', 500);
        } else if (reqRecipe === null) {
          res.status(404).send({ message: "Recipe not found" });
          console.log(model.getDateTime(), 'GET: /recipe/:id', 404);
        } else if (reqRecipe.authorid === session.userid) {
          res.status(200).send({ message: "Recipe Updated" });
          console.log(model.getDateTime(), 'POST: /recipe/:id', 200);
        }
      });
  else {
    res.status(401).send({ message: "Please login first" });
    console.log(model.getDateTime(), 'POST: /recipe/:id', 401);
  }
});

// Delete recipe by id [auth] [Delete recipe button]
app.delete('/recipe/:id', (req, res) => {
  session = req.session;
  let errorCaught = null;
  let reqRecipe = null;
  if (session.userid)
    model.getRecipe(parseInt(req.params.id))
      .then(async response => {
        if ((response.length !== 0)) {
          reqRecipe = response[0];
          if (reqRecipe.authorid !== session.userid) {
            res.status(403).send({ message: "Unauthorized access" });
            console.log(model.getDateTime(), 'DELETE: /recipe/:id', 403);
          } else {
            await model.deleteRecipe(reqRecipe.recipeid)
              .catch(error => {
                errorCaught = error;
              });
          }
        } else {
          res.status(404).send({ message: "Recipe not found" });
          console.log(model.getDateTime(), 'DELETE: /recipe/:id', 404);
        }
      })
      .catch(error => {
        errorCaught = error;
      })
      .finally(() => {
        if (errorCaught !== null) {
          res.status(500).send(errorCaught);
          console.log(model.getDateTime(), 'DELETE: /recipe/:id', 500);
        } else if (reqRecipe.authorid === session.userid) {
          res.status(200).send({ message: "Recipe deleted successfully" });
          console.log(model.getDateTime(), 'DELETE: /recipe/:id', 200);
        }
      });
  else {
    res.status(401).send({ message: "Please login first" });
    console.log(model.getDateTime(), 'DELETE: /recipe/:id', 401);
  }
});

// Add all ingredients of recipe to shopping list by id [auth] [Add recipe to shopping list button]
app.post('/recipe/shop/:id', (req, res) => {
  session = req.session;
  if (session.userid)
    model.getRequirementsByRecipe(parseInt(req.params.id))
      .then(async response =>
        await Promise.all(response.map(async (ingredient) => {
          await model.updateShoppingListIngredient(session.userid, parseInt(ingredient.ingredientid), parseFloat(Number(ingredient.sum)))
            .catch(error => {
              errorCaught = error;
            })
        }
        ))
      )
      .finally(() => {
        res.status(200).send({ message: "Recipe added to shopping list" });
        console.log(model.getDateTime(), 'POST: /recipe/shop/:id', 200);
      });
  else {
    res.status(401).send({ message: "Please login first" });
    console.log(model.getDateTime(), 'POST: /recipe/shop/:id', 401);
  }
});

// Get recipes list [Discover View]
app.get('/recipe', (req, res) => {
  session = req.session;
  // console.log(req.query);
  let query_str = 'WITH all_recipes AS (SELECT recipeid, title, serves, authorid, lastmodified, duration FROM Recipes WHERE visibility = \'public\')';
  // Applying Author filter
  if (req.query.author !== undefined) {
    let filter_author = req.query.author;
    query_str = query_str.concat(', ', "authored_recipes AS (SELECT * FROM all_recipes WHERE authorid = '", filter_author, "')");
  } else {
    query_str = query_str.concat(', ', 'authored_recipes AS (SELECT * FROM all_recipes)');
  }
  // Applying Key filter
  if (req.query.key !== undefined) {
    let filter_key = req.query.key;
    query_str = query_str.concat(', ', "queried_recipes AS (SELECT * FROM authored_recipes WHERE title = '", filter_key, "')");
  } else {
    query_str = query_str.concat(", ", "queried_recipes AS (SELECT * FROM authored_recipes)");
  }
  // Applying Tags filter
  if (req.query.tags !== undefined) {
    // let tag_list = req.query.tags.replaceall(' ', ',');
    let tag_list = req.query.tags.split(" ").join(", ");
    console.log(tag_list);
    // let tag_list = req.query.tags.replaceAll(" ", ",");
    query_str = query_str.concat(', ', 'given_tags AS (SELECT * FROM Tags WHERE tagid IN (', tag_list, '))');
    query_str = query_str.concat(', ', 'tag_count AS (SELECT COUNT(*) AS count FROM given_tags)',);
    query_str = query_str.concat(', ', 'recipes_with_tags AS (SELECT COUNT(tagged.recipeid) as count, tagged.recipeid AS recipeid FROM tagged JOIN given_tags ON tagged.tagid = given_tags.tagid GROUP BY tagged.recipeid)');
    query_str = query_str.concat(', ', 'tagged_recipes AS (SELECT A.recipeid,A.title,A.serves,A.authorid,A.lastmodified from queried_recipes AS A JOIN recipes_with_tags AS B ON A.recipeid = B.recipeid WHERE B.count = (SELECT count FROM tag_count))');
  } else {
    query_str = query_str.concat(', ', 'tagged_recipes AS (SELECT * FROM queried_recipes)');
  }
  // Adding all attributes
  query_str = query_str.concat(model.recipeListQueries('tagged_recipes', 'filtered_recipes'));

  // Applying sort
  if (req.query.sort === undefined) {
    query_str = query_str.concat(', ', 'sorted_recipes AS (SELECT * FROM filtered_recipes ORDER BY RANDOM())');
  }
  else if (req.query.sort === 'top') {
    query_str = query_str.concat(', ', 'sorted_recipes AS (SELECT * FROM filtered_recipes ORDER BY averagerating DESC)');
  } else if (req.query.sort === 'hot') {
    query_str = query_str.concat(', ', 'sorted_recipes AS (SELECT * FROM filtered_recipes ORDER BY hotRating DESC)');
  } else if (req.query.sort === 'new') {
    query_str = query_str.concat(', ', 'sorted_recipes AS (SELECT * FROM filtered_recipes ORDER BY lastmodified DESC)');
  } else if (req.query.sort === 'controversial') {
    query_str = query_str.concat(', ', 'sorted_recipes AS (SELECT * FROM filtered_recipes ORDER BY stddev DESC)');
  } else if (req.query.sort === 'fast') {
    query_str = query_str.concat(', ', 'sorted_recipes AS (SELECT * FROM filtered_recipes ORDER BY totalTime ASC)');
  } else {
    query_str = query_str.concat(', ', 'sorted_recipes AS (SELECT * FROM filtered_recipes ORDER BY totalrating DESC)');
  }
  query_str = query_str.concat(' ', 'SELECT * FROM sorted_recipes LIMIT 50');
  model.getRecipes(query_str)
    .then(async response => {
      await response.filter(async (recipe) => {
        return (recipe.visibility === 'public' || (recipe.visibility === 'private' && session.userid === recipe.authorid));
      });
      res.status(200).send(response);
      console.log(model.getDateTime(), 'GET: /recipe', 200);
    })
    .catch(error => {
      res.status(500).send(error);
      console.log(model.getDateTime(), 'GET: /recipe', 500);
    });
});

// Create ingredient [auth] [Create ingredient view]
app.post('/ingredient', (req, res) => {
  session = req.session;
  let errorCaught = null;
  let ingredientId = null;
  if (session.userid) {
    model.getIngredientId()
      .then(async response => {
        ingredientId = response;
        await model.createIngredient(ingredientId, req.body.name, req.body.kind)
          .catch(error => {
            errorCaught = error;
          })
      })
      .catch(error => {
        errorCaught = error;
      })
      .finally(() => {
        if (errorCaught !== null) {
          res.status(500).send(errorCaught);
          console.log(model.getDateTime(), 'POST: /ingredient', 500);
        } else {
          res.status(200).send({ message: "New ingredient created" });
          console.log(model.getDateTime(), 'POST: /ingredient', 200);
        }
      });
  } else {
    res.status(401).send({ message: "Please login first" });
    console.log(model.getDateTime(), 'POST: /ingredient', 401);
  }
});

// Get ingredients list by query [Query ingredients view]
app.get('/ingredient', (req, res) => {
  if (req.query.key === undefined)
    req.query.key = "";
  if (req.query.lim === undefined)
    req.query.lim = '10';
  if (parseInt(req.query.lim).toString() !== 'NaN') {
    model.getIngredientByKey(req.query.key, parseInt(req.query.lim))
      .then(response => {
        res.status(200).send(response);
        console.log(model.getDateTime(), 'GET: /ingredient', 200);
      })
      .catch(error => {
        res.status(500).send(error);
        console.log(model.getDateTime(), 'GET: /ingredient', 500);
      });
  } else {
    res.status(400).send({ message: "Limit is NaN" });
    console.log(model.getDateTime(), 'GET: /ingredient', 400);
  }
});

// Create Tag [auth] [Create tag view]
app.post('/tag', (req, res) => {
  session = req.session;
  let errorCaught = null;
  let tagId = null;
  if (session.userid) {
    model.getTagId()
      .then(async response => {
        tagId = response;
        await model.createTag(tagId, req.body.name)
          .catch(error => {
            errorCaught = error;
          })
      })
      .catch(error => {
        errorCaught = error;
      })
      .finally(() => {
        if (errorCaught !== null) {
          res.status(500).send(errorCaught);
          console.log(model.getDateTime(), 'POST: /tag', 500);
        } else {
          res.status(200).send({ message: "New tag created" });
          console.log(model.getDateTime(), 'POST: /tag', 200);
        }
      });
  } else {
    res.status(401).send({ message: "Please login first" });
    console.log(model.getDateTime(), 'POST: /tag', 401);
  }
});

// Get tags list by query [Query tags view]
app.get('/tag', (req, res) => {
  if (req.query.key === undefined)
    req.query.key = "";
  if (req.query.lim === undefined)
    req.query.lim = '10';
  if (parseInt(req.query.lim).toString() !== 'NaN') {
    model.getTagByKey(req.query.key, parseInt(req.query.lim))
      .then(response => {
        res.status(200).send(response);
        console.log(model.getDateTime(), 'GET: /tag', 200);
      })
      .catch(error => {
        res.status(500).send(error);
        console.log(model.getDateTime(), 'GET: /tag', 500);
      });
  } else {
    res.status(400).send({ message: "Limit is NaN" });
    console.log(model.getDateTime(), 'GET: /tag', 400);
  }
});

// Create a bookmark [auth] [Bookmark button]
app.post('/bookmark/:id', (req, res) => {
  session = req.session;
  if (session.userid) {
    model.createBookmark(session.userid, parseInt(req.params.id))
      .then(response => {
        res.status(200).send({ message: "Recipe bookmarked" });
        console.log(model.getDateTime(), 'POST: /bookmark/:id', 200);
      })
      .catch(error => {
        res.status(500).send(error);
        console.log(model.getDateTime(), 'POST: /bookmark/:id', 500);
      })
  } else {
    res.status(401).send({ message: "Please login first" });
    console.log(model.getDateTime(), 'GET: /bookmark/:id', 401);
  }
});

// Remove bookmark [auth] [Remove Bookmark button]
app.delete('/bookmark/:id', (req, res) => {
  session = req.session;
  if (session.userid) {
    model.removeBookmark(session.userid, parseInt(req.params.id))
      .then(response => {
        res.status(200).send({ message: "Recipe removed from Bookmarks" });
        console.log(model.getDateTime(), 'POST: /bookmark/:id', 200);
      })
      .catch(error => {
        res.status(500).send(error);
        console.log(model.getDateTime(), 'POST: /bookmark/:id', 500);
      })
  } else {
    res.status(401).send({ message: "Please login first" });
    console.log(model.getDateTime(), 'GET: /bookmark/:id', 401);
  }
});

// Rate a recipe (New or Update) [auth] [Rate recipe button]
app.post('/rating/:id', (req, res) => {
  session = req.session;
  if (session.userid) {
    model.rateRecipe(session.userid, parseInt(req.params.id), req.body.rating)
      .then(response => {
        res.status(200).send({ message: "Recipe rated" });
        console.log(model.getDateTime(), 'POST: /rating/:id', 200);
      })
      .catch(error => {
        res.status(500).send(error);
        console.log(model.getDateTime(), 'POST: /rating/:id', 500);
      })
  } else {
    res.status(401).send({ message: "Please login first" });
    console.log(model.getDateTime(), 'GET: /rating/:id', 401);
  }
});

// Unrate a recipe [auth] [Unrate recipe button]
app.delete('/rating/:id', (req, res) => {
  session = req.session;
  if (session.userid) {
    model.unrateRecipe(session.userid, parseInt(req.params.id))
      .then(response => {
        res.status(200).send({ message: "Recipe unrated" });
        console.log(model.getDateTime(), 'POST: /rating/:id', 200);
      })
      .catch(error => {
        res.status(500).send(error);
        console.log(model.getDateTime(), 'POST: /rating/:id', 500);
      })
  } else {
    res.status(401).send({ message: "Please login first" });
    console.log(model.getDateTime(), 'GET: /rating/:id', 401);
  }
});

// Get user shopping list by id [auth] [Shopping List View]
app.get('/shoppinglist', (req, res) => {
  session = req.session;
  if (session.userid)
    model.getShoppingList(session.userid)
      .then(response => {
        res.status(200).send(response);
        console.log(model.getDateTime(), 'GET: /shoppinglist', 200);
      })
      .catch(error => {
        res.status(500).send(error);
        console.log(model.getDateTime(), 'GET: /shoppinglist', 500);
      });
  else {
    res.status(403).send({ message: "Unauthorized access" });
    console.log(model.getDateTime(), 'GET: /shoppinglist', 403);
  }
});

// Create ingredient in shopping list by id [auth] [Add ingredient to shopping list view]
app.post('/shoppinglist/:id', (req, res) => {
  session = req.session;
  let errorCaught = null;
  if (session.userid)
    model.deleteShoppingListIngredient(parseInt(req.params.id), session.userid)
      .then(async deleteResponse => {
        await model.createShoppingListIngredient(parseInt(req.params.id), session.userid, parseFloat(req.body.quantity))
          .then(async createResponse => {
            res.status(200).send({ message: "New ingredient added in shopping list" });
            console.log(model.getDateTime(), 'POST: /shoppinglist/:id', 200);
          })
          .catch(error => {
            errorCaught = error;
          });
      })
      .catch(error => {
        errorCaught = error;
      })
      .finally(() => {
        if (errorCaught !== null) {
          res.status(500).send(errorCaught);
          console.log(model.getDateTime(), 'POST: /shoppinglist/:id', 500);
        }
      });
  else {
    res.status(403).send({ message: "Unauthorized access" });
    console.log(model.getDateTime(), 'POST: /shoppinglist/:id', 403);
  }
});

// Delete ingredient in shopping list by id [auth] [Delete ingredient from shopping list view]
app.delete('/shoppinglist/:id', (req, res) => {
  session = req.session;
  if (session.userid)
    model.deleteShoppingListIngredient(parseInt(req.params.id), session.userid)
      .then(response => {
        res.status(200).send({ message: "Ingredient deleted" });
        console.log(model.getDateTime(), 'DELETE: /shoppinglist/:id', 200);
      })
      .catch(error => {
        res.status(500).send(error);
        console.log(model.getDateTime(), 'DELETE: /shoppinglist/:id', 500);
      });
  else {
    res.status(403).send({ message: "Unauthorized access" });
    console.log(model.getDateTime(), 'DELETE: /shoppinglist/:id', 403);
  }
});

app.listen(port, () => {
  console.log(`App running on port ${port}.`)
});