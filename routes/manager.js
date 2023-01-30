const express = require('express');
const {LocalStorage} = require("node-localstorage");
const router = express.Router();
const {managerPool} = require('../connection')
const bcrypt = require("bcrypt");
if (typeof localStorage === "undefined" || localStorage === null) {
    const LocalStorage = require('node-localstorage').LocalStorage;
    localStorage = new LocalStorage('./info');
}


function isLoggedInManager(req, res, next) {
    if (localStorage.getItem("isLoggedIn")
        && localStorage.getItem("type") !== "worker") {
        next();
    } else {
        res.redirect('/login');
    }
}

/* GET users listing. */
router.get('/', isLoggedInManager, function (req, res, next) {
    res.render('manager');
});

router.post('/artists', isLoggedInManager, ((req, res) => {
    const {name, country} = req.body;
    managerPool.query(
        'call add_artist(?, ?, @a);', [name, country],
        function (err, results, fields) {
            console.log(err)
            res.redirect('/worker/artists/all')
        }
    );
}))
router.get('/artists/new', isLoggedInManager, (((req, res) => {
    res.render('artist');
})))

router.get('/albums/new', isLoggedInManager, (((req, res) => {
    res.render('album');
})))

router.post('/albums', isLoggedInManager, ((req, res) => {
    const {name, country, album_name, album_price, year, genre} = req.body;
    managerPool.query(
        //TODO
        'call add_album(?, ?, ?, ?, ?, ?, @x, @y );',
        [name, country, album_name, album_price, year, genre],
        function (err, results, fields) {
            console.log(err)
            res.redirect('/worker/albums/all');
        }
    );
}))

router.get('/album-to-store/new', isLoggedInManager, (((req, res) => {
    res.render('album-to-store');
})))

router.post('/album-to-store', isLoggedInManager, (req, res) => {
    const {artist_name, artist_country, album_name, album_price, year, genre, store_ID, qty} = req.body;
    managerPool.query('call add_album_to_store(?, ?, ?, ?, ?, ?, ?, ?);',
        [artist_name, artist_country, album_name, album_price, year, genre, store_ID, qty],
        function (err, results, fields) {
            console.log(err)
            res.redirect('/worker/albums');
        }
    )
})

router.get('/cancel-order', isLoggedInManager, (req, res) => {
    managerPool.query('select o.ID, c.name, c.lastname, c.phone_number as number, ar.name as artist, al.name as album, al.price,userID as Worker , DATE_FORMAT(o.date,\'%d/%m/%Y\') as Datee, status from Orders as o join Customers as c on c.ID = o.customerID join Albums as al on al.ID = albumID join Artists as ar on ar.ID = al.artistID;',
        function (err, results, fields) {
            console.log(err);
            res.render('list-cancel', {results})
        })
})

router.post('/cancel-order', isLoggedInManager, (req, res) => {
    const {ID} = req.body;
    managerPool.query('call cancel_order(?)', [ID], function (err, results, fields) {
        console.log(err)
        res.redirect('cancel-order');
    })
})

module.exports = router;