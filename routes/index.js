
const router = require('express').Router();

const api = require('./api');
const root = require('./root');

router.use('/', root);
router.use('/api', api);

module.exports = router;
