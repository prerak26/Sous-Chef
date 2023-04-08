require('dotenv').config();
const express = require('express');
const sessions = require('express-session');
const bcrypt = require('bcrypt');
const saltRounds = 10;
const app = express();
const port = 3001;

const model = require('./model');

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

app.get('/', (req, res) => {
  session = req.session;
  if (session.userid) {
    res.send("Welcome User <a href=\'/logout'>click to logout</a>");
  } else
    res.sendFile('views/index.html', { root: __dirname });
});

app.post('/login', (req, res) => {
  model.getChef(req.body.id)
    .then(response => {
      if ((response.length !== 0 && bcrypt.compareSync(req.body.pswd, response[0].hashedpassword))
        || (req.body.id === process.env.user && req.body.pswd === process.env.password)) {
        session = req.session;
        session.userid = req.body.id;
        res.status(200).send({ message: "Logged in successfully" });
      }
      else {
        res.status(404).send({ message: "Invalid username or password" });
      }
    })
    .catch(error => {
      res.status(500).send(error);
    });
});

app.post('/signup', (req, res) => {
  model.getChef(req.body.id)
    .then(chefList => {
      if (chefList.length !== 0) {
        res.status(403).send({ message: "Username already exists" });
      } else {
        model.createChef(req.body.id, req.body.name, bcrypt.hashSync(req.body.pswd, saltRounds))
          .then(response => {
            session = req.session;
            session.userid = req.body.id;
            res.status(200).send(req.body.id);
          })
          .catch(error => {
            res.status(500).send(error);
          });
      }
    })
    .catch(error => {
      res.status(500).send(error);
    });
});

app.get('/auth', (req, res) => {
  session = req.session;
  if (session.userid)
    res.status(200).send(session.userid);
  else
    res.status(401).send({ message: "Please login first" });
})

app.get('/logout', (req, res) => {
  req.session.destroy();
  res.redirect('/');
});

app.get('/chef/:id', (req, res) => {
  model.getChef(req.params.id)
    .then(response => {
      if ((response.length !== 0)) {
        let filteredResponse = {
          chefId: response[0].chefid,
          name: response[0].name
        };
        res.status(200).send(filteredResponse);
      }
      else {
        res.status(404).send({ message: "Chef not found" });
      }
    })
    .catch(error => {
      res.status(500).send(error);
    });
});

app.get('/recipe/:id', (req, res) => {
  session = req.session;
  model.getRecipe(parseInt(req.params.id))
    .then(response => {
      if ((response.length !== 0)) {
        reqRecipe = response[0];
        if (reqRecipe.visibility === 'private' && session.userid !== reqRecipe.authorid)
          res.status(403).send({ message: "Unauthorized access" });
        else
          res.status(200).send(reqRecipe);
      }
      else
        res.send(404).send({ message: "Recipe not found" });
    })
    .catch(error => {
      res.status(500).send(error);
    });
});

app.post('/recipe', (req, res) => {
  session = req.session;
  if (session.userid)
    model.getRecipeId()
      .then(recipeId => {
        model.createRecipe(recipeId, req.body.title, parseInt(req.body.serves),
          (req.body.isPublic ? 'public' : 'private'), session.userid)
          .then(recipeResponse => {
            for (let i = 0; i < req.body.steps.length; i++)
              model.createStep(recipeId, i + 1, req.body.steps[i].desc, req.body.steps[i].duration)
                .then(stepResponse => {
                  for (let j = 0; j < req.body.steps[i].ingredients.length; j++)
                    model.createRequirement(recipeId, i + 1, j + 1,
                      req.body.steps[i].ingredients[j].id,
                      req.body.steps[i].ingredients[j].quantity)
                      .then(requirementResponse => {})
                      .catch(error => {
                        res.status(500).send(error);
                      });
                })
                .catch(error => {
                  res.status(500).send(error);
                });
            res.status(200).send({ message: "New recipe added" });
          })
          .catch(error => {
            res.status(500).send(error);
          });
      })
      .catch(error => {
        console.log(session);
        res.status(500).send(error);
      });
  else
    res.status(401).send({ message: "Login first" });
});

app.listen(port, () => {
  console.log(`App running on port ${port}.`)
});
