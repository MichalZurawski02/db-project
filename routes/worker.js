const express = require('express');
const {LocalStorage} = require("node-localstorage");
const router = express.Router();
const {workerPool, appPool} = require('../connection')
const bcrypt = require("bcrypt");
if (typeof localStorage === "undefined" || localStorage === null) {
    const LocalStorage = require('node-localstorage').LocalStorage;
    localStorage = new LocalStorage('./info');
}


function isLoggedIn(req, res, next) {
    if (localStorage.getItem("isLoggedIn")) {
        next();
    } else {
        res.redirect('/login');
    }
}

/* GET users listing. */
router.get('/', isLoggedIn, function (req, res, next) {
    res.render('worker');
});

router.get('/clients', isLoggedIn, ((req, res) => {
    workerPool.query(
        'SELECT * FROM `Customers`',
        function (err, results, fields) {
            res.render('list', {results});
        }
    );
}))


router.get('/orders/new', isLoggedIn, (((req, res) => {
    res.render('order');
})))

router.get('/orders', isLoggedIn, ((req, res) => {
    workerPool.query(
        'select o.ID, c.name, c.lastname, c.phone_number,' +
        ' c.email, ar.name, al.name, al.price, ' +
        'o.userID, DATE_FORMAT(o.date,\'%d/%m/%Y\') as orderDate, o.status\n' +
        'from Orders as o\n' +
        'join Customers as c on c.ID = o.customerID\n' +
        'join Albums as al on al.ID = albumID\n' +
        'join Artists as ar on ar.ID = al.artistID',
        function (err, results, fields) {
            res.render('list', {results});
        }
    );
}))

router.post('/orders', isLoggedIn, (req, res) => {
    const {
        customer_name,
        customer_lastname,
        customer_phone,
        customer_email,
        albumID,
        storeID,
        userID,
        date
    } = req.body;
    workerPool.query(
        'call add_order(?, ?, ?, ?, ?, ?, ?, ?)',
        [customer_name, customer_lastname, customer_phone, customer_email, albumID, storeID, userID, date]
        , function (err, result, fields) {
            console.log(err)
            res.redirect('orders');
        }
    )
})

router.get('/albums', isLoggedIn, (req, res) => {
    workerPool.query(
        'select ais.storeID, s.city, ar.name, al.name, ais.quantity\n' +
        'from Albums_in_stores as ais\n' +
        'join Stores as s on s.ID = ais.storeID\n' +
        'join Albums as al on al.ID = ais.albumID\n' +
        'join Artists as ar on ar.ID = al.artistID'
        , function (err, results, fields) {
            //res.json(results);
            res.render('list', {results});
        }
    )
})

router.get('/albums/all', isLoggedIn, (req, res) => {
    workerPool.query('select * from Albums', function (err, results) {
        res.render('list', {results});
    })
})

router.get('/artists/all', isLoggedIn, (req, res) => {
    workerPool.query('select * from Artists', function (err, results) {
        res.render('list', {results});
    })
})

router.get('/stores/all', isLoggedIn, (req, res) => {
    workerPool.query('select * from Stores', function (err, results) {
        res.render('list', {results});
    })
})
module.exports = router;