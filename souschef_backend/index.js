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
      console.log(response);
      if ( (response.length !== 0 && bcrypt.compareSync(req.body.pswd, response[0].hashedpassword)) 
        || (req.body.id === process.env.user && req.body.pswd === process.env.password) ) {
        session = req.session;
        session.userid = req.body.id;
        res.status(200).send(`Hey there, welcome <a href=\'/logout'>click to logout</a>`);
      }
      else {
        res.status(403).send('Invalid username or password');
      }
    })
    .catch(error => {
      res.status(500).send(error);
    });
})

app.post('/signup', (req, res) => {
  model.getChef(req.body.id)
  .then(
    chefList => {
      if(chefList.length !== 0) {
        res.status(403).send('Username already exists');
      }else{
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
    }
  );
})

app.get('/chef/:id', (req, res) => {
  session = req.session;
  console.log(session.userid);
  if (session.userid) {
    model.getChef(req.params.id)
    .then(response => {
      if ( (response.length !== 0) ) {
        let filteredResponse = {
          chefId: response[0].chefid,
          name: response[0].name
        };
        res.status(200).send(filteredResponse);
      }
      else {
        res.status(404).send('Chef not found');
      }
    })
    .catch(error => {
      res.status(500).send(error);
    });
  }else{
    res.status(401).send('Please <a href=\'/\'>login</a> first');
  }
})

app.get('/auth', (req, res) => {
  session = req.session;
  if (session.userid) {
    res.status(200).send(session.userid);
  } else
    res.status(401).send('Please <a href=\'/index\'>login</a> first');
})

app.get('/logout', (req, res) => {
  req.session.destroy();
  res.redirect('/');
});

app.listen(port, () => {
    console.log(`App running on port ${port}.`)
  });
