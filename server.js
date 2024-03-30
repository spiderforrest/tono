
require('dotenv').config();
const express = require('express');
const session = require('express-session');

const api_routes = require('./routes');

const app = express();

app.use(session({
  secret: process.env.SECRET,
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


app.use(api_routes);

app.listen(3000);