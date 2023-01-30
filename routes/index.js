const express = require('express');
const router = express.Router();
const bcrypt = require('bcrypt')
const mysql = require('mysql2');
if (typeof localStorage === "undefined" || localStorage === null) {
    const LocalStorage = require('node-localstorage').LocalStorage;
    localStorage = new LocalStorage('./info');
}
const appPool = require('../connection').appPool

function isLoggedIn(req, res, next) {
    if (localStorage.getItem("isLoggedIn")) {
        next();
    } else {
        res.redirect('/login');
    }
}

/* GET home page. */
router.get('/', isLoggedIn, function (req, res, next) {
    let type = localStorage.getItem("type")
    if (type === "worker") {
        res.redirect('/worker');
    }
    else {
        console.log(type);
        res.render('index', {type})
    }
});

router.get('/login', ((req, res) => {
    localStorage.clear();
    res.render('login')
}))

router.post('/login', (req, res) => {
    let {login, password} = req.body;
    appPool.query(
        'SELECT password,type FROM `Users` WHERE `login` = ?',
        [login],
        function (err, results, fields) {
            if (results[0] && bcrypt.compare(password, results[0].password)) {
                localStorage.setItem("isLoggedIn", "true");
                localStorage.setItem("type", results[0].type)
                res.redirect('/');
            }
            else {
                res.redirect('/login')
            }
        }
    );
})
module.exports = router;
