const express = require('express');
const router = express.Router();
if (typeof localStorage === "undefined" || localStorage === null) {
    const LocalStorage = require('node-localstorage').LocalStorage;
    localStorage = new LocalStorage('./info');
}
/* GET users listing. */
router.get('/', function(req, res, next) {
    let userType = localStorage.getItem('userType');
    res.render('add',{userType})
});

module.exports = router;
