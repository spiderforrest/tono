
const express = require('express');
const session = require('express-session');

const api_routes = require('./routes');
const auth_middleware = require('./lib/auth')

const app = express();

app.use(session({
  secret: 'yipee',
  cookie: {
    maxAge: 300000,
    sameSite: 'strict',
  },
  resave: true,
  saveUninitialized: true,
}));


app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(express.static('public'));


app.use(api_routes)

app.listen(3000);
