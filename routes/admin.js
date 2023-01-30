const express = require('express');
const {LocalStorage} = require("node-localstorage");
const router = express.Router();
const {adminPool, managerPool} = require('../connection')
const bcrypt = require("bcrypt");
if (typeof localStorage === "undefined" || localStorage === null) {
    const LocalStorage = require('node-localstorage').LocalStorage;
    localStorage = new LocalStorage('./info');
}


function isLoggedInAdmin(req, res, next) {
    if (localStorage.getItem("isLoggedIn")
        && localStorage.getItem("type") === "admin") {
        next();
    } else {
        res.redirect('/login');
    }
}

/* GET users listing. */
router.get('/', isLoggedInAdmin, function (req, res, next) {
    res.render('admin');
});


router.post('/stores', isLoggedInAdmin, ((req, res) => {
    const {city, street, buildingNumber, zip_code, phone_number} = req.body;
    adminPool.query(
        'CALL add_store(?, ?, ?, ?, ?, @a)', [city, street, buildingNumber, zip_code, phone_number]
        ,
        function (err, results, fields) {
            console.log(err)
            res.redirect('/worker/stores/all')
        }
    );
}))
router.get('/stores/new', isLoggedInAdmin, (((req, res) => {
    res.render('store');
})))

router.get('/users/new',isLoggedInAdmin, (((req, res) => {
    res.render('user');
})))

router.post('/users',isLoggedInAdmin, (async (req, res) => {
    let {login, password, type, name, lastname, gender} = req.body;
    password = await bcrypt.hash(password, 10)
    adminPool.query(
        'CALL add_user(?, ?, ?, ?, ?, ?, @a );',
        [login, password, type, name, lastname, gender],
        function (err, results, fields) {
            console.log(err)
            res.redirect('users');
        }
    );
}))

router.get('/users',isLoggedInAdmin, (req, res, next) => {
    adminPool.query('SELECT ID, type, name, lastname, gender FROM Users', function (err, results) {
        res.render('list', {results});
    })
})

module.exports = router;